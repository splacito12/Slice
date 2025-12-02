const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// Trigger when a new message is created in Firestore
exports.sendMessageNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {

    const message = snapshot.data();

    // Receiver's token
    const token = message.receiverToken;

    if (!token) {
      console.log("No FCM token found for receiver.");
      return;
    }

    // Notification content
    const payload = {
      notification: {
        title: "New Message",
        body: message.text.length > 40
          ? message.text.substring(0, 40) + "..."
          : message.text,
      },
      data: {
        chatId: context.params.chatId,
        senderId: message.senderId,
      }
    };

    try {
      // Send push notification
      await admin.messaging().sendToDevice(token, payload, {
        priority: "high",
      });
      console.log("Notification sent to:", token);
    } catch (err) {
      console.error("Error sending notification:", err);
    }
  });
