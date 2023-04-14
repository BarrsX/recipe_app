import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/features/auth/presentation/bloc/auth_state.dart';

import 'src/features/auth/data/repository/auth_repository.dart';
import 'src/features/auth/presentation/bloc/auth_bloc.dart';
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
      if (state is AuthenticationSucceeded) {
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
            '/home': (context) => HomeScreen(),
          },
          theme: ThemeData(
            primarySwatch: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
        ),
      ),
    );
  }
}
