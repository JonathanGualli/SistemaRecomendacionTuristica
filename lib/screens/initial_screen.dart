import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/services/snackbar_service.dart';
import 'package:tesis_v2/utils/colors.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  static const routeName = "/initial";

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  AuthProvider? _auth;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    SnackBarService.instance.buildContext = context;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hola soy el inicio'),
            logoutButton(),
          ],
        ),
      ),
    );
  }

  Widget logoutButton() {
    return ElevatedButton(
      onPressed: () {
        _auth!.logoutUser();
      },
      style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colores.azul),
          fixedSize: const WidgetStatePropertyAll(Size(150, 44)),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Serrar sesión"),
        ],
      ),
    );
  }
}
