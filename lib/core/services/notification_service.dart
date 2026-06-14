import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:local_notifier/local_notifier.dart';
import '../constants/app_colors.dart';

// Conditional import for HTML5 Web Notifications
import '../utils/notification_helper_stub.dart'
    if (dart.library.html) '../utils/notification_helper_web.dart' as helper;

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    _initFcm();
  }

  Future<void> _initNotifications() async {
    // 1. Web browser permissions
    if (kIsWeb) {
      await helper.NotificationHelper.requestPermission();
    } 
    // 2. Windows setup
    else if (GetPlatform.isWindows) {
      await localNotifier.setup(
        appName: 'TastePoint POS',
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
    }
    // 3. Mobile Native permissions and setup
    else if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
      );

      if (GetPlatform.isAndroid) {
        final androidPlugin = _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      }
    }
  }

  Future<void> _initFcm() async {
    // Request permission for push notifications
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted FCM permission');
      
      // Get the token (can be sent to server to target this device)
      if (!kIsWeb) {
        String? token = await _fcm.getToken();
        print("FCM Token: $token");
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        if (message.notification != null) {
          showNotification(
            message.notification!.title ?? 'New Alert',
            message.notification!.body ?? '',
          );
        }
      });
    }
  }

  // Mandatory static handler for background messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  Future<void> requestWebPermission() async {
    if (kIsWeb) {
      await helper.NotificationHelper.requestPermission();
    }
  }

  void showNotification(String title, String body) {
    // Trigger OS level native notification if Web
    if (kIsWeb) {
      helper.NotificationHelper.showNotification(title, body);
    } 
    // Trigger Windows local notification
    else if (GetPlatform.isWindows) {
      _showWindowsNotification(title, body);
    }
    // Trigger native mobile notifications
    else if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      _showNativeMobileNotification(title, body);
    }

    // Always show a beautiful, premium, in-app notification card (heads-up banner)
    _showInAppNotification(title, body);
  }

  void _showWindowsNotification(String title, String body) {
    LocalNotification notification = LocalNotification(
      title: title,
      body: body,
      silent: false,
    );
    notification.show();
  }

  Future<void> _showNativeMobileNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'tastepoint_pos_channel',
        'TastePoint Alerts',
        channelDescription: 'Alerts for orders and inventory levels',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _localNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      // Ignore native exceptions on unsupported environments
    }
  }

  void _showInAppNotification(String title, String body) {
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.85),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 16,
      borderWidth: 1,
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      icon: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_active_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      mainButton: TextButton(
        onPressed: () {
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
        },
        child: const Text(
          'DISMISS',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
