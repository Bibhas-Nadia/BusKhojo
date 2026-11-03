import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const BusFinderApp());
}

/// Handles all runtime permissions in one place.
class AppPermissions {
  /// Asked on first launch: location, microphone, notification.
  static Future<void> requestBasic() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await [
        Permission.location,
        Permission.microphone,
        Permission.notification,
      ].request();
    } catch (e) {
      debugPrint('Permission error: $e');
    }
  }

  /// Call this ONLY when the user chooses "run in background".
  /// Android requires normal location to be granted first.
  static Future<void> requestBackground() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      if (await Permission.location.isGranted) {
        await Permission.locationAlways.request();
      }
      await Permission.ignoreBatteryOptimizations.request();
    } catch (e) {
      debugPrint('Background permission error: $e');
    }
  }

  /// Call this when the user wants to set an alarm (opens system setting).
  static Future<void> requestAlarm() async {
    if (!Platform.isAndroid) return;
    try {
      await Permission.scheduleExactAlarm.request();
    } catch (e) {
      debugPrint('Alarm permission error: $e');
    }
  }
}

class BusFinderApp extends StatelessWidget {
  const BusFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppPermissions.requestBasic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.inversePrimary,
        title: const Text('Bus Finder'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 140,
              height: 140,
              errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.directions_bus, size: 120, color: colors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Bus Finder',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Welcome!'),
          ],
        ),
      ),
    );
  }
}
