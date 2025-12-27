import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService{
  // Private Constructor :
  LocalNotificationsService.internal();

  // Singleton Service :
  static final LocalNotificationsService _instance = LocalNotificationsService.internal();

  // Factory Constructor to return singleton instance
  factory LocalNotificationsService.intance() => _instance;

  // Main plugin instance for handling notifications
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  // Android specific initialisation settings using app launcher icon
  final _androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS specific initialisation
  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true
  );

  // android channel configuration
  final _androidChannel = const AndroidNotificationChannel(
    'channel_id', // id
    'channel name', // title
    description: 'Statut de la commande', // description
    importance: Importance.max,
  );

  // Flag to track Initialization status :
  bool _isFlutterLocalNotificationsInitialized = false;

  // Counter for generating unique notification IDs
  int _notificationIdCounter = 0;

  // Initialize the local NOTIFICATION :
  Future<void> init() async {
    // check if already initialized to prevent redundant setup
    if(_isFlutterLocalNotificationsInitialized){
      return;
    }

    // Craete plugin instance
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Combine platform specific settings
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings
    );

    // Initialize plugin with settings
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response){
        // Handle notification in forground
        print('Foreground notification LOCAL : ${response.payload}');
      }
    );

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(_androidChannel);

    // Mark initialization as complete
    _isFlutterLocalNotificationsInitialized = true;
  }

  // Show a local Notification  with given title , body and paylod :
  Future<void> showNotification(String? title, String? body, String? payload) async {
    // Android specific notification detail
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
        _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high
    );

    // iOS specific notification detail
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();

    // combine platform-specific detail
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails
    );

    // Display the notification
    await _flutterLocalNotificationsPlugin.show(
        _notificationIdCounter++,
        title,
        body,
        notificationDetails,
      payload: payload,
    );
  }
}