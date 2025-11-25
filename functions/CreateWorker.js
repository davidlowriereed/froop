const {createThread, addMessageToThread} = require("./OpenAiWrapper");
const admin = require("firebase-admin");

exports.handleNewChannel = async (channelId, messages) => {
  try {
    const threadId = await createThread();

    for (const msg of messages) {
      await addMessageToThread(threadId, "user", msg.text);
    }

    // Store the new thread ID in Firestore
    await admin.firestore().collection("froopChat").doc("data")
        .collection("channels").doc(channelId)
        .update({threadId: threadId});

    return threadId;
  } catch (error) {
    console.error("Error handling new channel:", error);
    throw error;
  }
};
