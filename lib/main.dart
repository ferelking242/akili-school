import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/config/app_config.dart';
import 'core/localization/locales.dart';
import 'core/routing/app_router.dart';
import 'core/services/offline_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await OfflineStorage.init();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.path,
      fallbackLocale: AppLocales.fallback,
      useOnlyLangCode: true,
      child: const ProviderScope(child: AkiliApp()),
    ),
  );
}

class AkiliApp extends ConsumerWidget {
  const AkiliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(accent: theme.accent),
        darkTheme: AppTheme.dark(accent: theme.accent),
        themeMode: theme.mode,
        routerConfig: router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (ctx, child) => ResponsiveBreakpoints.builder(
          breakpoints: const [
            Breakpoint(start: 0, end: 480, name: MOBILE),
            Breakpoint(start: 481, end: 900, name: TABLET),
            Breakpoint(start: 901, end: 1920, name: DESKTOP),
            Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
          child: child!,
        ),
      ),
    );
  }
}
