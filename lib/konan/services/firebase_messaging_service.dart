import 'package:cnmci/konan/services/process_firebase_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notifications_service.dart';

class FirebaseMessagingService{
  // Private contructor :
  FirebaseMessagingService._internal();

  // Singleton
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  // factory
  factory FirebaseMessagingService.instance() => _instance;

  //
  LocalNotificationsService? _localNotificationsService;

  // Initialize
  Future<void> init({required LocalNotificationsService localNotificationsService}) async {
    _localNotificationsService = localNotificationsService;

    // Handle FCM
    _handlePushNotificationToken();

    /*_requestPermission();*/

    // Handler for background messaging :
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // listen for Foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notifications TAP :
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _handlePushNotificationToken() async{
    try {
      final token = await FirebaseMessaging.instance.getToken();
      // Listen for TOKEN Refresh :
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmtoken) {
        //print('Refresh Token : $fcmtoken');
      }).onError((handleError) {
        //print('Error Token : $handleError');
      });
    }
    catch (e) {
      // No specified type, handles all
      //print('Something really unknown: $e');
    }
  }

  Future<void> _requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true
    );
  }

  void _onForegroundMessage(RemoteMessage message){
    FirebaseProcessMessage().process(message);
    /*print('Foreground Message received : ${message.data.toString()}');
    final notificationData = message.notification;
    if(notificationData != null){
      _localNotificationsService?.showNotification(
          notificationData.title, notificationData.body,
          message.data.toString());
    }*/
  }

  //
  void _onMessageOpenedApp(RemoteMessage message){
    //print('Foreground Message received : ${message.data.toString()}');
    FirebaseProcessMessage().process(message);
  }
}

// Background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //print('Message : ${message.data.toString()}');
  FirebaseProcessMessage().process(message);
}