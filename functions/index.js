// Firebase Cloud Function to process notification requests
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");
const {getFirestore} = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin SDK
initializeApp();

exports.processNotificationRequests = onDocumentCreated(
  "notification_requests/{requestId}",
  async (event) => {
    const snap = event.data;
    const requestData = snap.data();
    const requestId = event.params.requestId;
    
    logger.info("📡 Processing notification request:", requestId);
    logger.info("🎯 Target tokens:", requestData.tokens?.length);
    logger.info("📦 Payload:", requestData.payload?.notification?.title);
    
    try {
      if (!requestData.tokens || requestData.tokens.length === 0) {
        logger.warn("❌ No tokens found in request");
        return;
      }
      
      // Send notification to each token
      const promises = requestData.tokens.map(async (token) => {
        try {
          const message = {
            token: token,
            notification: {
              title: requestData.payload.notification.title,
              body: requestData.payload.notification.body,
            },
            data: requestData.payload.data,
            android: {
              notification: {
                channelId: 'chat_messages',
                priority: 'high',
              },
            },
            apns: {
              payload: {
                aps: {
                  alert: {
                    title: requestData.payload.notification.title,
                    body: requestData.payload.notification.body,
                  },
                  badge: 1,
                  sound: 'default',
                },
              },
            },
          };
          
          const response = await getMessaging().send(message);
          logger.info("✅ Notification sent successfully:", response);
          return { success: true, token: token.substring(0, 20) + '...' };
        } catch (error) {
          logger.error("❌ Failed to send to token:", token.substring(0, 20) + '...', error);
          return { success: false, token: token.substring(0, 20) + '...', error: error.message };
        }
      });
      
      const results = await Promise.all(promises);
      const successCount = results.filter(r => r.success).length;
      
      // Update the request document with results
      await getFirestore().collection('notification_requests').doc(requestId).update({
        processed: true,
        processedAt: new Date(),
        results: results,
        successCount: successCount,
        totalTokens: requestData.tokens.length,
      });
      
      logger.info(`🎉 Notification processing complete: ${successCount}/${requestData.tokens.length} sent successfully`);
      
    } catch (error) {
      logger.error("❌ Error processing notification request:", error);
      
      // Mark as failed
      await getFirestore().collection('notification_requests').doc(requestId).update({
        processed: true,
        processedAt: new Date(),
        error: error.message,
        successCount: 0,
      });
    }
  }
);