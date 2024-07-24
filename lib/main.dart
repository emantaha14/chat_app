import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app/authentication/login_screen.dart';
import 'package:chat_app/main_screens/home_screen.dart';
import 'package:chat_app/providers/authentication_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication/opt_screen.dart';
import 'authentication/user_information_screen.dart';
import 'constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthenticationProvider(),
        )
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.deepPurple,
        ),
        dark: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
              title: 'Adaptive Theme Demo',
              theme: theme,
              darkTheme: darkTheme,
              home: const UserInformationScreen(),
              initialRoute: Constants.loginScreen,
              routes: {
                Constants.loginScreen : (context) => const LoginScreen(),
                Constants.otpScreen : (context) => const OPTScreen(),
                Constants.userInformationScreen : (context) => const UserInformationScreen(),
                Constants.homeScreen : (context) => const HomeScreen(),
              },
            ));
  }
}
