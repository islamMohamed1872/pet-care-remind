import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const String currentTimeZone = 'Africa/Cairo';
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    await requestNotificationPermissions(); // Request notification permissions
    await requestOverlayPermission(); // Request overlay permission
  }

  Future<void> requestOverlayPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {

      await Permission.systemAlertWindow.request();


      if (!await Permission.systemAlertWindow.isGranted) {
        debugPrint('Overlay permission denied. Please enable it manually in settings.');

      }
    }

    if (await Permission.systemAlertWindow.isGranted) {
      debugPrint('Overlay permission granted');
    } else {
      debugPrint('Overlay permission denied');
    }
  }

  Future<void> requestNotificationPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.notification.isGranted) {
      debugPrint('Notification permissions granted');
    } else {
      debugPrint('Notification permissions denied');
    }
  }
  Future<void> showInstantNotification(String title, String description) async {
    try {
      await _notificationsPlugin.show(
        0,
        title,
        description,
        _notificationDetails(title,description),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
  Future<void> scheduleDailyNotification(DateTime selectedTime, String title, String description) async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(selectedTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        0,
        title,
        description,
        scheduledTime,
        _notificationDetails(title,description),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  NotificationDetails _notificationDetails(String title, String message) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'test_channel', // Channel ID
      'Test Notifications', // Channel name
      channelDescription: 'Channel for test notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      ticker: 'ticker',
      icon: 'paw',
      color: Color(0xFF008000),
      enableLights: true,
      ledColor: Color(0xFF008000),
      ledOnMs: 1000,
      ledOffMs: 500,
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('green_background'),
        largeIcon: DrawableResourceAndroidBitmap('paw'),
        contentTitle: '<font color="#008000"><b>title</b></font>',
        htmlFormatContentTitle: true,
        summaryText: '<font color="#FFFFFF">message</font>',
        htmlFormatSummaryText: true,
      ),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }



  void onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped with payload: ${response.payload}');
  }
}

void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint('Background notification tapped with payload: ${response.payload}');
}