import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import '/services/session.dart';
import '/utils/device.dart';

class CodeScreen extends StatefulWidget {
  final String email;

  const CodeScreen({super.key, required this.email});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final codeController = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> verify() async {
    setState(() {
      loading = true;
      error = null;
    });

    final code = codeController.text.trim();

    if (code.length != 6) {
      setState(() {
        loading = false;
        error = "Código inválido";
      });
      return;
    }

    final deviceId = await getDeviceId();

    final res = await AuthService.verifyCode(
      email: widget.email,
      code: code,
      deviceId: deviceId,
    );

    setState(() => loading = false);

    if (res["ok"] == true) {
      await SessionService.saveSession(widget.email, deviceId);

      Navigator.pushReplacementNamed(context, "/home");
    } else {
      final err = res["error"];

      setState(() {
        error = mapError(err);
      });
    }
  }

  String mapError(String? err) {
    switch (err) {
      case "invalid_code":
        return "Código incorrecto";
      case "temporarily_blocked":
        return "Intentá más tarde";
      case "device_conflict":
        return "Licencia en otro dispositivo";
      default:
        return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verificar código")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Código enviado a ${widget.email}"),

            const SizedBox(height: 20),

            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Código",
              ),
            ),

            const SizedBox(height: 20),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : verify,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Verificar"),
            ),
          ],
        ),
      ),
    );
  }
}