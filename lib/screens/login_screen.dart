import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/utils/colors.dart';
import 'package:tesis_v2/utils/dimensions.dart';
import 'package:tesis_v2/services/snackbar_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthProvider? _auth;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    SnackBarService.instance.buildContext = context;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A4A8A), Color(0xFF9BA3EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: loginPageUI(context),
        ),
      ),
    );
  }

  Widget loginPageUI(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.screenWidth * 0.1,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            titulo(),
            const SizedBox(height: 20),
            imageLogin(),
            const SizedBox(height: 20),
            loginWithSocialNetworks(),
            const SizedBox(height: 20),
            loginWithGuestButton(context),
          ],
        ),
      ),
    );
  }

  Widget titulo() {
    return const Text(
      "Sistema de Recomendación Turística\nCentrado en el Clima",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A4A8A),
      ),
    );
  }

  Widget imageLogin() {
    return Image.asset(
      "assets/logo.png",
      height: Dimensions.screenWidth * 0.4,
    );
  }

  Widget loginWithSocialNetworks() {
    return Column(
      children: [
        const Text(
          "Inicia sesión con",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A8A),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [googleButton(), facebookButton()],
        ),
      ],
    );
  }

  Widget googleButton() {
    return ElevatedButton(
      onPressed: () async {
        await _auth!.signInWithGoogle();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[400],
        minimumSize: const Size(140, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.g_mobiledata, color: Colors.white, size: 32),
          SizedBox(width: 8),
          Text("", style: TextStyle(color: Colors.white, fontSize: 16))
        ],
      ),
    );
  }

  Widget facebookButton() {
    return ElevatedButton(
      onPressed: () async {
        await _auth!.signInWithFacebook();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        minimumSize: const Size(140, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.facebook, color: Colors.white),
          SizedBox(width: 8),
          Text("", style: TextStyle(color: Colors.white, fontSize: 16))
        ],
      ),
    );
  }

  Widget loginWithGuestButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await _auth!.showGuestLoginConfirmationDialog(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[700],
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 10),
          Text("Ingresar como Invitado", style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }
}
