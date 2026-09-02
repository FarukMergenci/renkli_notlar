import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'data/services/notification_service.dart';
import 'providers/category_provider.dart';
import 'providers/note_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/core/app_theme.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Turkish date formatting
  await initializeDateFormatting('tr_TR', null);

  // Initialize local notifications
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  runApp(const RenkliNotlarApp());
}

class RenkliNotlarApp extends StatelessWidget {
  const RenkliNotlarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Renkli Notlar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('tr', 'TR'),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
