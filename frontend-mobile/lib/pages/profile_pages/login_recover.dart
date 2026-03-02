import 'package:flutter/material.dart';

class LoginRecoverPage extends StatelessWidget {
  const LoginRecoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Recovery'),
      ),
      body: const Center(
        child: Text('Login recovery functionality goes here.'),
      ),
    );
  }
}