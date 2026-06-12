// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

class NotificationHelper {
  static Future<void> requestPermission() async {
    try {
      if (html.Notification.supported) {
        await html.Notification.requestPermission();
      }
    } catch (e) {
      // Browser doesn't support or blocked
    }
  }

  static void showNotification(String title, String body) {
    try {
      if (html.Notification.supported && html.Notification.permission == 'granted') {
        html.Notification(title, body: body);
      }
    } catch (e) {
      // Fallback
    }
  }
}
