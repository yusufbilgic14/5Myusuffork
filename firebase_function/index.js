// Firebase Cloud Function to process notification requests
// Install: npm install firebase-admin firebase-functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

exports.processNotificationRequests = functions.firestore
  .document('notification_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const requestData = snap.data();
    
    console.log('📡 Processing notification request:', context.params.requestId);
    console.log('🎯 Target tokens:', requestData.tokens?.length);
    console.log('📦 Payload:', requestData.payload?.notification?.title);
    
    try {
      if (!requestData.tokens || requestData.tokens.length === 0) {
        console.log('❌ No tokens found in request');
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
                channel_id: 'chat_messages',
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
          
          const response = await admin.messaging().send(message);
          console.log('✅ Notification sent successfully:', response);
          return { success: true, token: token.substring(0, 20) + '...' };
        } catch (error) {
          console.error('❌ Failed to send to token:', token.substring(0, 20) + '...', error);
          return { success: false, token: token.substring(0, 20) + '...', error: error.message };
        }
      });
      
      const results = await Promise.all(promises);
      const successCount = results.filter(r => r.success).length;
      
      // Update the request document with results
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        results: results,
        successCount: successCount,
        totalTokens: requestData.tokens.length,
      });
      
      console.log(`🎉 Notification processing complete: ${successCount}/${requestData.tokens.length} sent successfully`);
      
    } catch (error) {
      console.error('❌ Error processing notification request:', error);
      
      // Mark as failed
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        error: error.message,
        successCount: 0,
      });
    }
  });