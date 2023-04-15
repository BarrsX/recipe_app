import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recipe_app/src/features/home/presentation/home_screen.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Authentication Failed: ${state.errorMessage}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red[700],
            ));
          } else if (state is AuthenticationGoogleSignInSucceeded) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationLoading ||
                state is AuthenticationGoogleSignInInProgress) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        icon: Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        icon: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<AuthenticationBloc>()
                            .add(AuthenticationStarted(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ));
                      },
                      icon: const Icon(
                        Icons.login,
                        color: Colors.white,
                      ),
                      label: const SizedBox(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        // Use custom font for button text
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          fontFamily: 'Montserrat',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        // TODO: implement forgot password functionality
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'OR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: () async {
                        context
                            .read<AuthenticationBloc>()
                            .add(AuthenticationGoogleSignInRequested());
                      },
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 32.0,
                        width: 32.0,
                      ),
                      label: const SizedBox(
                        child: Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        // Use custom font for button text
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          fontFamily: 'Montserrat',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
