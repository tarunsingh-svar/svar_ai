import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'core/config/environment.dart';
import 'core/config/revenuecat_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initServices();

  // Sentry is opt-in: with no DSN configured the app runs exactly as before.
  if (Environment.sentryDsn.isEmpty) {
    runApp(const MyApp());
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = Environment.sentryDsn;
      options.environment = Environment.sentryEnvironment;
      // Notes are private by definition. Never attach user data, request
      // bodies, or screenshots to a crash report.
      options.sendDefaultPii = false;
      options.attachScreenshot = false;
      options.tracesSampleRate = 0.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

Future<void> _initServices() async {
  // 🔒 Initialize Supabase safely using environment config
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // 💳 Initialize RevenueCat (no-op on web). Must run after Supabase so the
  // SDK can be tied to the signed-in user id when a session already exists.
  await RevenueCatConfig.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: 'SVAR AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialBinding: InitialBinding(),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
