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
      backgroundColor: const Color(0xFFF5F5FA),
      body: Align(
        alignment: Alignment.center,
        child: loginPageUI(context),
      ),
    );
  }

  Widget loginPageUI(context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.screenWidth * 0.16,
        //vertical: Dimensions.screenHeight * 0.05,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titulo(),
            imageLogin(),
            loginWithSocialNetoworks(),
            loginWIthGuest(context)
          ],
        ),
      ),
    );
  }

  ElevatedButton loginWIthGuest(context) {
    return ElevatedButton(
      onPressed: () async {
        await _auth!.showGuestLoginConfirmationDialog(context);
      },
      style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.grey),
          fixedSize: const WidgetStatePropertyAll(Size(260, 44)),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
          Text(
            "Ingresar como invitado",
            style: TextStyle(fontSize: 15, color: Colors.white),
          )
        ],
      ),
    );
  }

  Text titulo() {
    return const Text(
      "Sistema de recomendación turística",
      style: TextStyle(
          fontSize: 25, color: Colors.purple, fontWeight: FontWeight.bold),
    );
  }

  Widget imageLogin() {
    return //Padding(
        //padding: const EdgeInsets.only(bottom: 23),
        //child:
        Center(
      child: Image.asset(
        "assets/logo.png",
        height: Dimensions.screenWidth * 0.5,
      ),
    );
  }

  Widget loginWithSocialNetoworks() {
    return SizedBox(
      height: Dimensions.screenHeight * 0.2,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Iniciar sesión con: ",
            style: TextStyle(
                color: Colores.morado,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [googleButton(), facebookButton()],
          ),
          /* const Center(
            child: Text("- O -",
                style: TextStyle(
                    color: Colores.morado,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ), */
        ],
      ),
    );
  }

  Widget googleButton() {
    return ElevatedButton(
      onPressed: () async {
        await _auth!.signInWithGoogle();
      },
      style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colores.morado),
          fixedSize: const WidgetStatePropertyAll(Size(122, 44)),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.g_mobiledata_rounded,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget facebookButton() {
    return ElevatedButton(
      onPressed: () async {
        await _auth!.signInWithFacebook();
      },
      style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colores.azul),
          fixedSize: const WidgetStatePropertyAll(Size(122, 44)),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.facebook_sharp,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
