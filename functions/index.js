const functions = require("firebase-functions");
const admin = require("firebase-admin");
const dotenv = require("dotenv");
const fetch = require("node-fetch");
const cheerio = require("cheerio");
const {OpenAI} = require("openai");

dotenv.config();

admin.initializeApp();

const db = admin.firestore();

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

exports.generateLinkPreview = functions.https.onCall(async (data, context) => {
  try {
    const url = new URL(data.url);
    url.protocol = "https:";
    const secureUrl = url.toString();

    const response = await fetch(secureUrl);
    const html = await response.text();
    const $ = cheerio.load(html);

    const preview = {
      title: $("meta[property=\"og:title\"]")
          .attr("content") || $("title").text() || "",
      description: $("meta[property=\"og:description\"]")
          .attr("content") || $("meta[name=\"description\"]")
          .attr("content") || "",
      image: $("meta[property=\"og:image\"]")
          .attr("content") || "",
      siteName: $("meta[property=\"og:site_name\"]")
          .attr("content") || "",
      favicon: $("link[rel=\"shortcut icon\"]")
          .attr("href") || $("link[rel=\"icon\"]")
          .attr("href") || "/favicon.ico",
      url: url,
    };

    // Ensure favicon is a full URL
    if (preview.favicon && !preview.favicon.startsWith("http")) {
      preview.favicon = new URL(preview.favicon, url).href;
    }

    // Remove undefined values...
    // Cache the result...

    return preview;
  } catch (error) {
    console.error("Error generating link preview:", error);
    throw new functions.https.HttpsError(
        "internal", "Failed to generate preview", error.message);
  }
});

exports.sendFriendRequestNotification = functions.firestore
    .document("friendRequests/{friendRequestId}")
    .onCreate(async (snapshot, context) => {
      const friendRequest = snapshot.data();
      const senderId = friendRequest.fromUserID;
      const recipientId = friendRequest.toUserID;

      const senderSnapshot = await admin.firestore()
          .doc(`users/${senderId}`).get();
      const sender = senderSnapshot.data();
      const senderName = `${sender.firstName} ${sender.lastName}`;

      const recipientSnapshot = await admin
          .firestore().doc(`users/${recipientId}`).get();
      const recipient = recipientSnapshot.data();

      const notification = {
        notification: {
          title: "New Friend Request in Froop!",
          body: `${senderName} has sent you a friend request!`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          selectedTab: ".person",
        },
        token: recipient.fcmToken,
        apns: {
          payload: {
            aps: {
              notification: {
                title: "You have a New Friend Request in Froop!",
                body: `${senderName} has sent you a friend request!`,
              },
              badge: recipient.badgeCount ? recipient.badgeCount + 1 : 1,
              Category: "FLUTTER_NOTIFICATION_CLICK",
            },
          },
        },
      };

      await recipientSnapshot.ref.update({
        badgeCount: admin.firestore.FieldValue.increment(1),
      });

      return admin.messaging().send(notification);
    });

exports.sendFriendAcceptedNotification = functions.firestore
    .document("users/{userId}/friends/friendList")
    .onUpdate(async (change, context) => {
      const friendListBefore = change.before.data();
      const friendListAfter = change.after.data();

      // Get the user who accepted the friend request
      const acceptedFriendUIDs = friendListAfter.friendUIDs.filter((uid) =>
        !friendListBefore.friendUIDs.includes(uid));

      // If no new friendUIDs found, return
      if (!acceptedFriendUIDs.length) {
        return null;
      }

      for (let i = 0; i < acceptedFriendUIDs.length; i++) {
        const friendSnapshot = await admin.firestore()
            .doc(`users/${acceptedFriendUIDs[i]}`).get();
        const friend = friendSnapshot.data();

        const userSnapshot = await admin.firestore()
            .doc(`users/${context.params.userId}`)
            .get();
        const user = userSnapshot.data();

        const notification = {
          notification: {
            title: "Friend Invitation Accepted in Froop!",
            body: `${friend.firstName} ${friend.lastName}
              has accepted your friend request!`,
          },
          data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            selectedTab: ".person",
          },
          token: user.fcmToken,
          apns: {
            payload: {
              aps: {
                notification: {
                  title: "Friend Invitation Accepted in Froop!",
                  body: `${friend.firstName} ${friend.lastName} has accepted
                      your friend request!`,
                },
                badge: user.badgeCount ? user.badgeCount + 1 : 1,
                Category: "FLUTTER_NOTIFICATION_CLICK",
              },
            },
          },
        };

        await userSnapshot.ref.update({
          badgeCount: admin.firestore.FieldValue.increment(1),
        });

        await admin.messaging().send(notification);
      }

      return null;
    });

exports.newUserJoinedNotification = functions.firestore
    .document("users/{userId}")
    .onCreate(async (snapshot, context) => {
      const newUser = snapshot.data();
      const invitationSnapshot = await admin.firestore()
          .doc(`smsInvitations/${newUser.phoneNumber}`).get();

      if (!invitationSnapshot.exists) {
        console.log("No invitation exists for this phone number.");
        return null;
      }

      const invitation = invitationSnapshot.data();
      const senderUid = invitation.senderUid;
      const senderSnapshot = await admin.firestore()
          .doc(`users/${senderUid}`).get();

      const sender = senderSnapshot.data();

      const notification = {
        notification: {
          title: "Friend Joined Froop",
          body: `${newUser.firstName} ${newUser.lastName} has joined
        Froop and has been added to your Friends list!`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          selectedTab: ".person",
        },
        token: sender.fcmToken,
        apns: {
          payload: {
            aps: {
              notification: {
                title: "Friend Joined Froop",
                body: `${newUser.firstName} ${newUser.lastName} has
              joined Froop and has been added to your Friends
              list!`,
              },
              badge: sender.badgeCount ? sender.badgeCount + 1 : 1,
              category: "FLUTTER_NOTIFICATION_CLICK",
            },
          },
        },
      };

      await senderSnapshot.ref.update({
        badgeCount: admin.firestore.FieldValue.increment(1),
      });

      return admin.messaging().send(notification);
    });

/**
 * Formats a Firestore timestamp into a human-readable string.
 *
 * @param {firebase.firestore.Timestamp} timestamp -
 * The Firestore timestamp to format.
 * @return {string} - The formatted date string.
 */
function formatDate(timestamp) {
  const days = ["Sunday", "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday"];
  const date = timestamp.toDate();
  const dayName = days[date.getDay()];
  const formattedDate = date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
  return `${dayName}, ${formattedDate}`;
}

exports.newFroopInvitationNotification = functions.firestore
    .document("users/{userId}/froopDecisions/" +
            "froopLists/myInvitesList/{invitationId}")
    .onCreate(async (snapshot, context) => {
      const invitation = snapshot.data();
      const recipientRef = admin.firestore().doc(
          `users/${context.params.userId}`);

      const recipientSnapshot = await recipientRef.get();
      const recipient = recipientSnapshot.data();

      // Fetch the froopHost's user data
      const hostRef = admin.firestore().doc(`users/${invitation.froopHost}`);
      const hostSnapshot = await hostRef.get();
      const host = hostSnapshot.data();
      const hostName = `${host.firstName} ${host.lastName}`;

      // Fetch the Froop event details
      const froopRef = admin.firestore().doc(
          `users/${invitation.froopHost}/myFroops/${invitation.froopId}`);
      const froopSnapshot = await froopRef.get();
      const froop = froopSnapshot.data();
      const froopName = froop.froopName;
      const froopStartTime = formatDate(froop.startTime);

      const notification = {
        notification: {
          title: "New Froop Invitation",
          body: `${hostName} has invited you to their Froop: ${froopName}
              that will begin at ${froopStartTime}`,
        },
        token: recipient.fcmToken,
        apns: {
          payload: {
            aps: {
              alert: {
                title: "New Froop Invitation",
                body: `${hostName} has invited you to their Froop:
                  ${froopName} that will begin at ${froopStartTime}`,
              },
              badge: recipient.badgeCount ? recipient.badgeCount + 1 : 1,
              category: "FLUTTER_NOTIFICATION_CLICK",
            },
          },
        },
      };

      await recipientRef.update({
        badgeCount: admin.firestore.FieldValue.increment(1),
      });

      return admin.messaging().send(notification);
    });

exports.froopInvitationAcceptedNotification = functions.firestore
    .document("users/{userId}/froopDecisions/froopLists/" +
            "myConfirmedList/{confirmationId}")
    .onCreate(async (snapshot, context) => {
      const confirmation = snapshot.data();
      const hostRef = admin.firestore().doc(`users/${confirmation.froopHost}`);

      const hostSnapshot = await hostRef.get();
      const host = hostSnapshot.data();

      // Fetch the user's data who accepted the invitation
      const userRef = admin.firestore().doc(`users/${context.params.userId}`);
      const userSnapshot = await userRef.get();
      const user = userSnapshot.data();
      const userName = `${user.firstName} ${user.lastName}`;

      const notification = {
        notification: {
          title: "Froop Invitation Accepted",
          body: `Your Froop invitation has been accepted by ${userName}!`,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: host.fcmToken,
        apns: {
          payload: {
            aps: {
              notification: {
                title: "Froop Invitation Accepted",
                body: `Your Froop invitation has been accepted by ${userName}!`,
              },
              badge: host.badgeCount ? host.badgeCount + 1 : 1,
              category: "FLUTTER_NOTIFICATION_CLICK",
            },
          },
        },
      };

      await hostRef.update({
        badgeCount: admin.firestore.FieldValue.increment(1),
      });

      return admin.messaging().send(notification);
    });

exports.froopInvitationDeclinedNotification = functions.firestore
    .document("users/{userId}/froopDecisions/froopLists" +
            "/myDeclinedList/{declinationId}")
    .onCreate(async (snapshot, context) => {
      const declination = snapshot.data();
      const hostRef = admin.firestore().doc(`users/${declination.froopHost}`);

      const hostSnapshot = await hostRef.get();
      const host = hostSnapshot.data();

      // Fetch the user's data who declined the invitation
      const userRef = admin.firestore().doc(`users/${context.params.userId}`);
      const userSnapshot = await userRef.get();
      const user = userSnapshot.data();
      const userName = `${user.firstName} ${user.lastName}`;

      const notification = {
        notification: {
          title: "Froop Invitation Declined",
          body: `Your Froop invitation has been declined by ${userName}.`,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: host.fcmToken,
        apns: {
          payload: {
            aps: {
              notification: {
                title: "Froop Invitation Declined",
                body: `Your Froop invitation has been declined by ${userName}.`,
              },
              badge: host.badgeCount ? host.badgeCount + 1 : 1,
              category: "FLUTTER_NOTIFICATION_CLICK",
            },
          },
        },
      };

      await hostRef.update({
        badgeCount: admin.firestore.FieldValue.increment(1),
      });

      return admin.messaging().send(notification);
    });

exports.scheduleNotificationOnFroopCreate = functions.firestore
    .document("users/{userId}/myFroops/{froopId}")
    .onWrite((change, context) => {
      const userId = context.params.userId;
      const froopId = context.params.froopId;

      sendFroopNotifications(userId, froopId);
    });

exports.handleFroopNotifications = functions.https.onRequest((req, res) => {
  // this function is called by a Cloud Task
  // extract froopId and userId from the req.body
  const userId = req.body.userId;
  const froopId = req.body.froopId;

  sendFroopNotifications(userId, froopId);

  res.sendStatus(200);
});

const sendFroopNotifications = (userId, froopId) => {
  const confirmedListRef = db.collection(
      `users/${userId}/myFroops/${froopId}/invitedFriends`)
      .doc("confirmedList");

  confirmedListRef.get().then((doc) => {
    if (doc.exists) {
      const confirmedUsers = doc.data().uid;
      confirmedUsers.forEach((userUID) => {
        db.collection("users").doc(userUID).get().then((userDoc) => {
          if (userDoc.exists) {
            const fcmToken = userDoc.data().fcmToken;
            const message = {
              notification: {
                title: "Your Froop is about to start",
                body: `Your Froop starts in 30 minutes!`,
              },
              token: fcmToken,
            };

            admin.messaging().send(message)
                .then((response) => {
                  console.log("Successfully sent message:", response);
                })
                .catch((error) => {
                  console.log("Error sending message:", error);
                });
          } else {
            console.log("No such user document!");
          }
        }).catch((error) => {
          console.log("Error getting user document:", error);
        });
      });
    } else {
      console.log("No such document!");
    }
  }).catch((error) => {
    console.log("Error getting document:", error);
  });
};

const {CloudTasksClient} = require("@google-cloud/tasks");

exports.scheduleNotificationOnFroopCreate = functions.firestore
    .document("users/{userId}/myFroops/{froopId}")
    .onCreate((snapshot, context) => {
      const froopData = snapshot.data();
      const userId = context.params.userId;
      const froopId = context.params.froopId;

      const client = new CloudTasksClient();
      const parent = client.queuePath("your-gcp-project-id",
          "us-central1", "your-queue-name");

      const task = {
        httpRequest: {
          httpMethod: "POST",
          url: "https://us-central1-your-gcp-project-id.cloudfunctions.net/handleFroopNotifications",
          body: Buffer.from(JSON.stringify({
            userId: userId,
            froopId: froopId,
          })).toString("base64"),
        },
        scheduleTime: {
          seconds: froopData.startTime.seconds - 30 * 60,
        },
      };

      const request = {
        parent: parent,
        task: task,
      };

      client.createTask(request)
          .then((response) => {
            console.log(`Created task ${response[0].name}`);
          })
          .catch((error) => {
            console.error(`Error creating task: ${error}`);
          });
    });

exports.activeFroopPinDrop = functions.firestore
    .document("users/{userId}/myFroops/{froopId}/annotations/{annotationId}")
    .onCreate(async (snapshot, context) => {
      const pinData = snapshot.data();
      const creatorSnapshot = await admin.firestore().doc(
          `users/${pinData.creatorUID}`).get();

      if (!creatorSnapshot.exists) {
        console.log("Creator user document does not exist");
        return;
      }

      const creator = creatorSnapshot.data();

      // get the confirmedList document
      const confirmedListRef = db.collection(
          "users/${context.params.userId}/myFroops/" +
        "${context.params.froopId}/invitedFriends")
          .doc("confirmedList");

      confirmedListRef.get().then((doc) => {
        if (doc.exists) {
          const confirmedUsers = doc.data().uid;
          confirmedUsers.forEach((userUID) => {
          // Get user document
            db.collection("users").doc(userUID).get().then((userDoc) => {
              if (userDoc.exists) {
                const fcmToken = userDoc.data().fcmToken;
                const message = {
                  notification: {
                    title: "New Pin in Froop!",
                    body: `${creator.firstName} ${creator.lastName} just
                      added a Pin to the Froop Map.`,
                  },
                  token: fcmToken,
                };

                admin.messaging().send(message)
                    .then((response) => {
                      console.log("Successfully sent message:", response);
                    })
                    .catch((error) => {
                      console.log("Error sending message:", error);
                    });
              } else {
                console.log("No such user document!");
              }
            }).catch((error) => {
              console.log("Error getting user document:", error);
            });
          });
        } else {
          console.log("No such document!");
        }
      }).catch((error) => {
        console.log("Error getting document:", error);
      });
    });

exports.froopImageAdded = functions.firestore
    .document("users/{userId}/myFroops/{froopId}")
    .onUpdate(async (change, context) => {
      const newValue = change.after.data();
      const previousValue = change.before.data();

      // check if the froopImages array has changed
      if (JSON.stringify(newValue.froopImages) !==
      JSON.stringify(previousValue.froopImages)) {
        console.log("froopImages array has been updated");

        // get the confirmedList document
        const confirmedListRef = db.collection(
            "users/${context.params.userId}/myFroops/" +
                      "${context.params.froopId}/invitedFriends")
            .doc("confirmedList");

        confirmedListRef.get().then((doc) => {
          if (doc.exists) {
            const confirmedUsers = doc.data().uid;

            confirmedUsers.forEach((userUID) => {
            // Get user document
              db.collection("users").doc(userUID).get().then((userDoc) => {
                if (userDoc.exists) {
                  const fcmToken = userDoc.data().fcmToken;
                  const message = {
                    notification: {
                      title: "New Image in Froop!",
                      body: `A new image has been uploaded to the Froop.`,
                    },
                    token: fcmToken,
                  };

                  admin.messaging().send(message)
                      .then((response) => {
                        console.log("Successfully sent message:", response);
                      })
                      .catch((error) => {
                        console.log("Error sending message:", error);
                      });
                } else {
                  console.log("No such user document!");
                }
              }).catch((error) => {
                console.log("Error getting user document:", error);
              });
            });
          } else {
            console.log("No such document!");
          }
        }).catch((error) => {
          console.log("Error getting document:", error);
        });
      }
    });

exports.sendChatNotification = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      const message = snapshot.data();
      const recipientId = message.receiverId;
      const senderId = message.senderId;

      try {
      // Fetch the recipient's FCM token
        const recipientDoc = await admin.firestore().collection("users")
            .doc(recipientId).get();
        const fcmToken = recipientDoc.data().fcmToken;

        // Fetch the sender's name
        const senderDoc = await admin.firestore()
            .collection("users").doc(senderId).get();
        const sender = senderDoc.data();
        const senderName = `${sender.firstName} ${sender.lastName}`;

        // Construct the notification message
        const payload = {
          notification: {
            title: `New message from: ${senderName}`,
            body: message.text, // Customize your message body
          // Add other notification payload as needed
          },
          data: {
          // Add custom data for handling notification tap
            chatId: context.params.chatId,
          // Other data as needed
          },
        };

        // Send the notification
        return admin.messaging().sendToDevice(fcmToken, payload);
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    });

// Firestore trigger for new messages
exports.onMessageCreateSummary = functions.firestore
    .document("froopChat/data/channels/{channelId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
      const newMessage = snap.data();
      const channelId = context.params.channelId;

      try {
      // Retrieve all messages for context
        const messagesSnapshot = await admin.firestore()
            .collection("froopChat").doc("data").collection("channels")
            .doc(channelId).collection("messages")
            .orderBy("timeStamp", "asc")
            .get();

        const messages = messagesSnapshot.docs.map((doc) => doc.data());
        const contextText = messages.map((msg) =>
          `${msg.ownerUid}: ${msg.text}`).join("\n");

        const response = await openai.chat.completions.create({
          model: "gpt-4o-2024-05-13", // or "gpt-4-0613"
          messages: [
            {role: "system", content:
                "You are a helpful assistant. Please summarize" +
                "the following conversation."},
            {role: "user", content: contextText +
                `\n${newMessage.ownerUid}: ${newMessage.text}`},
          ],
          max_tokens: 150,
        });

        const gptResponse = response.choices[0].message.content.trim();

        // Store the summary back in Firestore
        await admin.firestore().collection("froopChat")
            .doc("data").collection("channels")
            .doc(channelId).collection("gptResponses").add({
              text: gptResponse,
              timeStamp: admin.firestore.FieldValue.serverTimestamp(),
            });

        console.log("GPT response stored successfully");
      } catch (error) {
        console.error("Error processing new message:", error);
      }
    });

exports.onMessageCreateMultiSummary = functions.firestore
    .document("froopChat/data/channels/{channelId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
      try {
        // Retrieve all channels
        const channelsSnapshot = await admin.firestore()
            .collection("froopChat").doc("data").collection("channels").get();

        // Collect all messages from all channels
        const allMessages = {};
        for (const channelDoc of channelsSnapshot.docs) {
          const channelId = channelDoc.id;
          const messagesSnapshot = await channelDoc.ref.collection("messages")
              .orderBy("timeStamp", "asc").get();

          const messages = messagesSnapshot.docs.map((doc) => doc.data());
          allMessages[channelId] = messages.map((msg) =>
            `${msg.ownerUid}: ${msg.text}`).join("\n");
        }

        // Format all messages for the GPT Assistant
        const contextText = Object.values(allMessages).join("\n\n");

        // Query GPT Assistant to summarize the conversations
        const response = await openai.chat.completions.create({
          model: "gpt-4o-2024-05-13", // or "gpt-4-0613"
          messages: [
            {role: "system", content:
                "You are a helpful assistant." +
                "Please summarize the following conversations."},
            {role: "user", content: contextText},
          ],
          max_tokens: 150,
        });

        const gptResponse = response.choices[0].message.content.trim();

        // Store the summary back in Firestore
        await admin.firestore().collection("froopChat")
            .doc("data").collection("gptSummary")
            .add({
              summary: gptResponse,
              timeStamp: admin.firestore.FieldValue.serverTimestamp(),
            });

        console.log("GPT response stored successfully");
      } catch (error) {
        console.error("Error processing new message:", error);
      }
    });

exports.onMessageCreateMultiSummaryKM = functions.firestore
    .document("froopChat/data/channels/{channelId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
      try {
        // Retrieve all channels
        const channelsSnapshot = await admin.firestore()
            .collection("froopChat").doc("data").collection("channels").get();

        // Collect all messages from all channels
        const allMessages = {};
        for (const channelDoc of channelsSnapshot.docs) {
          const channelId = channelDoc.id;
          const messagesSnapshot = await channelDoc.ref.collection("messages")
              .orderBy("timeStamp", "asc").get();

          const messages = messagesSnapshot.docs.map((doc) => doc.data());
          allMessages[channelId] = messages.map((msg) =>
            `${msg.ownerUid}: ${msg.text}`).join("\n");
        }

        // Format all messages for the GPT Assistant
        const contextText = Object.values(allMessages).join("\n\n");

        // Query GPT Assistant to summarize the conversations
        const response = await openai.chat.completions.create({
          model: "gpt-4o-2024-05-13", // or "gpt-4-0613"
          messages: [
            {role: "system", content:
                "You are the GPT assistant for the Kitchen Manager" +
                "at TGI Fridays. Your responsibilities include overseeing" +
                "kitchen operations, ensuring food safety compliance," +
                "managing kitchen staff, coordinating with front-of-house" +
                "operations, maintaining inventory, and ensuring quality" +
                "control. Assist the Kitchen Manager by providing timely" +
                "advice, making informed decisions, and offering solutions" +
                "to streamline kitchen workflow. Stay focused on maintaining" +
                "high standards and efficiency in the kitchen." +
                "Please summarize the following conversations."},
            {role: "user", content: contextText},
          ],
          max_tokens: 150,
        });

        const gptResponse = response.choices[0].message.content.trim();

        // Store the summary back in Firestore
        await admin.firestore().collection("froopChat")
            .doc("data").collection("gptSummaryKM")
            .add({
              summary: gptResponse,
              timeStamp: admin.firestore.FieldValue.serverTimestamp(),
            });

        console.log("GPT response stored successfully");
      } catch (error) {
        console.error("Error processing new message:", error);
      }
    });

exports.onMessageCreateMultiSummaryPM = functions.firestore
    .document("froopChat/data/channels/{channelId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
      try {
        // Retrieve all channels
        const channelsSnapshot = await admin.firestore()
            .collection("froopChat").doc("data").collection("channels").get();

        // Collect all messages from all channels
        const allMessages = {};
        for (const channelDoc of channelsSnapshot.docs) {
          const channelId = channelDoc.id;
          const messagesSnapshot = await channelDoc.ref.collection("messages")
              .orderBy("timeStamp", "asc").get();

          const messages = messagesSnapshot.docs.map((doc) => doc.data());
          allMessages[channelId] = messages.map((msg) =>
            `${msg.ownerUid}: ${msg.text}`).join("\n");
        }

        // Format all messages for the GPT Assistant
        const contextText = Object.values(allMessages).join("\n\n");

        // Query GPT Assistant to summarize the conversations
        const response = await openai.chat.completions.create({
          model: "gpt-4o-2024-05-13", // or "gpt-4-0613"
          messages: [
            {role: "system", content:
                "You are the GPT assistant for the Procurement Manager at" +
                "TGI Fridays. Your responsibilities include managing the" +
                "purchasing of food supplies and kitchen equipment, ensuring" +
                "timely ordering, receipt, and storage of ingredients and" +
                "materials, managing vendor relationships, and negotiating" +
                "contracts. Assist the Procurement Manager" +
                "by providing timely" +
                "updates, offering alternative solutions for supply issues," +
                    "and ensuring efficient inventory management. Focus on" +
                    "maintaining good vendor relationships and ensuring the" +
                    "kitchen is well-stocked with quality ingredients." +
                "Please summarize the following conversations."},
            {role: "user", content: contextText},
          ],
          max_tokens: 150,
        });

        const gptResponse = response.choices[0].message.content.trim();

        // Store the summary back in Firestore
        await admin.firestore().collection("froopChat")
            .doc("data").collection("gptSummaryPM")
            .add({
              summary: gptResponse,
              timeStamp: admin.firestore.FieldValue.serverTimestamp(),
            });

        console.log("GPT response stored successfully");
      } catch (error) {
        console.error("Error processing new message:", error);
      }
    });

exports.onMessageCreateMultiSummaryHC = functions.firestore
    .document("froopChat/data/channels/{channelId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
      try {
        // Retrieve all channels
        const channelsSnapshot = await admin.firestore()
            .collection("froopChat").doc("data").collection("channels").get();

        // Collect all messages from all channels
        const allMessages = {};
        for (const channelDoc of channelsSnapshot.docs) {
          const channelId = channelDoc.id;
          const messagesSnapshot = await channelDoc.ref.collection("messages")
              .orderBy("timeStamp", "asc").get();

          const messages = messagesSnapshot.docs.map((doc) => doc.data());
          allMessages[channelId] = messages.map((msg) =>
            `${msg.ownerUid}: ${msg.text}`).join("\n");
        }

        // Format all messages for the GPT Assistant
        const contextText = Object.values(allMessages).join("\n\n");

        // Query GPT Assistant to summarize the conversations
        const response = await openai.chat.completions.create({
          model: "gpt-4o-2024-05-13", // or "gpt-4-0613"
          messages: [
            {role: "system", content:
                "You are the GPT assistant for the Head Cook at" +
                "TGI Fridays. Your responsibilities include leading" +
                "the kitchen team in preparing and cooking food," +
                "ensuring food quality and consistency, assisting in" +
                "menu planning, developing new recipes, training junior" +
                "kitchen staff, and maintaining cleanliness and" +
                "organization in the kitchen. Assist the Head Cook by" +
                "providing recipe suggestions, offering advice on" +
                "food preparation, and ensuring that the kitchen" +
                "operates smoothly and efficiently. Focus on maintaining" +
                "high standards and fostering a collaborative" +
                "kitchen environment." +
                "Please summarize the following conversations with" +
                "relevant bullet point items that a head" +
                "cook would want to know.."},
            {role: "user", content: contextText},
          ],
          max_tokens: 150,
        });

        const gptResponse = response.choices[0].message.content.trim();

        // Store the summary back in Firestore
        await admin.firestore().collection("froopChat")
            .doc("data").collection("gptSummaryHC")
            .add({
              summary: gptResponse,
              timeStamp: admin.firestore.FieldValue.serverTimestamp(),
            });

        console.log("GPT response stored successfully");
      } catch (error) {
        console.error("Error processing new message:", error);
      }
    });
