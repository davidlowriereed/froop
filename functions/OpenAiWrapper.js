const {OpenAI} = require("openai");
const functions = require("firebase-functions");

const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

exports.createThread = async () => {
  try {
    const thread = await openai.beta.threads.create();
    console.log("Thread created:", thread.id);
    return thread.id;
  } catch (error) {
    console.error("Error creating thread:", error);
    throw error;
  }
};

exports.addMessageToThread = async (threadId, role, content) => {
  try {
    const message = await openai.beta.threads.messages.create(
        threadId,
        {
          role: role,
          content: content,
        },
    );
    console.log("Message added to thread:", message.id);
    return message.id;
  } catch (error) {
    console.error("Error adding message to thread:", error);
    throw error;
  }
};
