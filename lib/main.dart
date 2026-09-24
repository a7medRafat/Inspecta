import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:inspecta/app.dart';
import 'package:inspecta/core/framework/app_info.dart';
import 'package:inspecta/core/framework/orientation_helper.dart';
import 'package:inspecta/firebase_options.dart';
import 'package:inspecta/injection.dart';

bool _crashlyticsEnabled = false;

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await OrientationHelper.lockToPortrait();
      await AppInfo.init();
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _crashlyticsEnabled = !kIsWeb;
      } catch (e) {
        debugPrint('Firebase not configured: $e');
      }
      await setupDependencies();

      FlutterError.onError = _crashlyticsEnabled
          ? FirebaseCrashlytics.instance.recordFlutterError
          : FlutterError.presentError;

      runApp(const App());
    },
    (error, stack) {
      if (_crashlyticsEnabled) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      } else {
        debugPrint('Uncaught error: $error\n$stack');
      }
    },
  );
}
