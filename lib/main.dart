import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/features/auth/data/repository/auth_repository.dart';
import 'src/features/auth/presentation/bloc/auth_bloc.dart';
import 'src/features/auth/presentation/bloc/auth_state.dart';
import 'src/features/auth/presentation/login_screen.dart';
import 'src/features/home/presentation/home_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();

  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        AuthenticationBloc(repository: authenticationRepository);
    authenticationBloc.stream.listen((state) {
      if (state is AuthenticationSucceeded || state is AuthenticationGoogleSignInSucceeded) {
        navigatorKey.currentState!.pushReplacementNamed('/home');
      }
    });

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>(
          create: (_) => AuthenticationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (_) => authenticationBloc,
          ),
        ],
        child: MaterialApp(
          title: 'Meal Search App',
          initialRoute: '/login',
          navigatorKey: navigatorKey,
          routes: {
            '/login': (context) => BlocProvider<AuthenticationBloc>(
                  create: (_) => authenticationBloc,
                  child: LoginScreen(),
                ),
            '/home': (context) => const HomeScreen(),
          },
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.red[800],
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                color: Colors.white,
              ),
              titleLarge: TextStyle(
                color: Colors.white,
              ),
              titleMedium: TextStyle(
                color: Colors.white,
              ),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: const ColorScheme.dark().copyWith(
                primary: Colors.red[800], secondary: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
