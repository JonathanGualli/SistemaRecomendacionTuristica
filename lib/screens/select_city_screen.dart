import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/utils/colors.dart';
import 'package:tesis_v2/utils/dimensions.dart';

class SelectCityScreen extends StatefulWidget {
  const SelectCityScreen({super.key});

  static const routeName = "/selectCity";

  @override
  State<SelectCityScreen> createState() => _SelectCityScreenState();
}

class _SelectCityScreenState extends State<SelectCityScreen> {
  AuthProvider? _auth;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Selecciona una ciudad",
            style: GoogleFonts.lato(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: loginPageUI(context),
        ),
      ),
    );
  }

  Widget loginPageUI(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.screenWidth * 0.08,
        vertical: Dimensions.screenHeight * 0.05,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Selecciona tu destino",
            style: GoogleFonts.lato(
              fontSize: 22,
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
          //SizedBox(height: Dimensions.screenHeight * 0.05),
          cityOption(
            context,
            "Paris",
            "assets/paris.png",
            Colors.blueAccent,
            () {
              Navigator.pushNamed(context, '/home', arguments: 'Paris');
            },
          ),
          //SizedBox(height: Dimensions.screenHeight * 0.05),
          cityOption(
            context,
            "Londres",
            "assets/londres.png",
            Colors.redAccent,
            () {
              Navigator.pushNamed(context, '/home', arguments: 'Londres');
            },
          ),
          logOutButtom(),
        ],
      ),
    );
  }

  Widget cityOption(BuildContext context, String cityName, String assetPath,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              assetPath,
              height: Dimensions.screenWidth * 0.4,
            ),
            const SizedBox(height: 10),
            Text(
              cityName,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget logOutButtom() {
    return ElevatedButton(
      onPressed: () async {
        //await _auth!.signInWithGoogle();
        await _auth!.logoutUser();
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
            Icons.logout,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }
}
