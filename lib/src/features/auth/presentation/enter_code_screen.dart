// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class EnterCodeScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const EnterCodeScreen({
    required Key key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {},
      child: Scaffold(
        appBar: AppBar(
          title: Text('Enter Code'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verification code has been sent to ${widget.phoneNumber}.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Container(
                width: 200,
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Code',
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () => _onSubmit(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length == 6) {
      BlocProvider.of<AuthenticationBloc>(context).add(
        AuthenticationPhoneCodeEntered(
          verificationId: widget.verificationId,
          code: code,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid code.')),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
