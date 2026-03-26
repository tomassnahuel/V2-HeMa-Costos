/*
import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import 'code_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> sendCode() async {
    setState(() {
      loading = true;
      error = null;
    });

    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        loading = false;
        error = "Ingresá un email";
      });
      return;
    }

    final ok = await AuthService.requestCode(email);

    setState(() => loading = false);

    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CodeScreen(email: email),
        ),
      );
    } else {
      setState(() {
        error = "Error enviando código";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ingresar")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 20),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : sendCode,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Enviar código"),
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hemacostos/services/session.dart';
import 'package:hemacostos/ui/theme/app_theme.dart';
import 'package:hemacostos/utils/device.dart';
import '/services/auth_service.dart';
import 'code_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

      bool codeSent = false;
      String? emailSent;
      final codeController = TextEditingController();

  final emailController = TextEditingController();
  final _focusNode = FocusNode();
  bool loading = false;
  String? error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {

    codeController.dispose();

    emailController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  /*Future<void> sendCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => error = "Ingresá tu email para continuar");
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => error = "El email no parece válido");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final ok = await AuthService.requestCode(email);
    setState(() => loading = false);

    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CodeScreen(email: email)),
      );
    } else {
      setState(() => error = "No pudimos enviar el código. Intentá de nuevo.");
    }
  }*/
//-------------------------------------------------------------------
  Future<void> sendCode() async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
    setState(() => error = "Ingresá tu email para continuar");
    return;
  }

  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    setState(() => error = "El email no parece válido");
    return;
  }

  setState(() {
    loading = true;
    error = null;
  });

  final ok = await AuthService.requestCode(email);

  setState(() => loading = false);

  if (ok) {
    setState(() {
      codeSent = true;
      emailSent = email;
    });
  } else {
    setState(() => error = "No pudimos enviar el código.");
  }
}

Future<void> verifyCode() async {
  final code = codeController.text.trim();

  if (code.length != 6) {
    setState(() => error = "Código inválido");
    return;
  }

  setState(() {
    loading = true;
    error = null;
  });

  final deviceId = await getDeviceId();

  final res = await AuthService.verifyCode(
    email: emailSent!,
    code: code,
    deviceId: deviceId,
  );

  setState(() => loading = false);

  if (res["ok"] == true) {
    await SessionService.saveSession(emailSent!, deviceId);
    Navigator.pushReplacementNamed(context, "/home");
  } else {
    setState(() => error = mapError(res["error"]));
  }
}

void editEmail() {
  setState(() {
    codeSent = false;
    codeController.clear();
    error = null;
  });
}

Future<void> resendCode() async {
  if (emailSent == null) return;

  setState(() => loading = true);

  await AuthService.requestCode(emailSent!);

  setState(() => loading = false);
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

//------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                _HeroSection(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: /*_FormSection(
                      emailController: emailController,
                      focusNode: _focusNode,
                      loading: loading,
                      error: error,
                      onSubmit: sendCode,
                    ),*/
                    _FormSection(
                      emailController: emailController,
                      codeController: codeController,
                      focusNode: _focusNode,
                      loading: loading,
                      error: error,
                      codeSent: codeSent,
                      emailSent: emailSent,
                      onSubmit: sendCode,
                      onVerify: verifyCode,
                      onEditEmail: editEmail,
                      onResend: resendCode,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero superior con gradiente ──────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,   // #F6C1CC
            Color(0xFFFADDDF),
            AppColors.background,     // #FFF7F4
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Círculo decorativo
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Transform.scale(
                        scale: 1.7,
                        child: Image.asset(
                          'assets/images/hemacostos_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'HeMa Costos',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // Título
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Calculá con\n',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    TextSpan(
                      text: 'precisión.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryDark,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresá para continuar',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sección del formulario ───────────────────────────────────────────────────

/*class _FormSection extends StatelessWidget {
  final TextEditingController emailController;
  final FocusNode focusNode;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  const _FormSection({
    required this.emailController,
    required this.focusNode,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });*/

  class _FormSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController codeController;
  final FocusNode focusNode;
  final bool loading;
  final String? error;
  final bool codeSent;
  final String? emailSent;
  final VoidCallback onSubmit;
  final VoidCallback onVerify;
  final VoidCallback onEditEmail;
  final VoidCallback onResend;
  

  const _FormSection({
  required this.emailController,
  required this.codeController,
  required this.focusNode,
  required this.loading,
  required this.error,
  required this.codeSent,
  required this.emailSent,
  required this.onSubmit,
  required this.onVerify,
  required this.onEditEmail,
  required this.onResend,
});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          /*'TU EMAIL',*/
          codeSent ? 'INGRESÁ EL CÓDIGO' : 'TU EMAIL',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 10),

        // Input
        /*TextField(
          controller: emailController,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'hola@mipasteleria.com',
            hintStyle: GoogleFonts.dmSans(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.surfaceVariant,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
        ),*/

        // Input dinámico
    codeSent
      ? TextField(
        controller: codeController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onVerify(),
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '123456',
          hintStyle: GoogleFonts.dmSans(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )
    : TextField(
        controller: emailController,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onSubmit(),
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'hola@mipasteleria.com',
          hintStyle: GoogleFonts.dmSans(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.surfaceVariant,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),

        const SizedBox(height: 8),

        // Hint debajo del campo
        /*Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Te enviamos un código de un solo uso',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),*/

if (!codeSent)
  Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      'Te enviamos un código de un solo uso',
      style: GoogleFonts.dmSans(
        fontSize: 12,
        color: AppColors.textMuted,
      ),
    ),
  ),

if (codeSent) ...[
  Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      "Código enviado a $emailSent",
      style: GoogleFonts.dmSans(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),
  ),

  const SizedBox(height: 12),

  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton(
        onPressed: onEditEmail,
        child: const Text("Cambiar email"),
      ),
      TextButton(
        onPressed: onResend,
        child: const Text("Reenviar código"),
      ),
    ],
  ),
],

        // Error message
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10, left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          error!,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 24),

        // Botón principal
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            /*onPressed: loading ? null : onSubmit,*/
            onPressed: loading
                ? null
                : codeSent
                    ? onVerify
                    : onSubmit,
            //-----------------
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        /*'Enviar código',*/
                        codeSent ? 'Verificar código' : 'Enviar código',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      /*const Icon(Icons.arrow_forward_rounded, size: 18),*/
                      Icon(
                        codeSent ? Icons.check_rounded : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 28),

        // Divisor "sin contraseñas"
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.surfaceVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'sin contraseñas',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.surfaceVariant)),
          ],
        ),

        const SizedBox(height: 20),

        // Badges de confianza
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TrustBadge(label: 'Seguro'),
            const SizedBox(width: 8),
            _TrustBadge(label: 'Sin registro'),
            const SizedBox(width: 8),
            _TrustBadge(label: 'Rápido'),
          ],
        ),
      ],
    );
  }
}

// ─── Badge de confianza ───────────────────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
  final String label;
  const _TrustBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceVariant, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}