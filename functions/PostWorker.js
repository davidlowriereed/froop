const {addMessageToThread} = require("./OpenAiWrapper");

exports.handleNewMessage = async (threadId, message) => {
  try {
    const messageId = await addMessageToThread(threadId, "user", message.text);
    console.log("Message appended to thread:", messageId);
  } catch (error) {
    console.error("Error appending message to thread:", error);
    throw error;
  }
};
