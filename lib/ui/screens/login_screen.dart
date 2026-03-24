import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService auth = AuthService();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  bool codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            if (codeSent)
              TextField(controller: codeController, decoration: InputDecoration(labelText: 'Code')),
            ElevatedButton(
              child: Text(codeSent ? 'Verify Code' : 'Send Code'),
              onPressed: () async {
                if (!codeSent) {
                  final ok = await auth.requestCode(emailController.text);
                  if (ok) setState(() => codeSent = true);
                } else {
                  final res = await auth.verifyCode(emailController.text, codeController.text);
                  if (res['ok'] == true) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res['error'] ?? 'Unknown error')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}