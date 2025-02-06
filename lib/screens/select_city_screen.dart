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
          ElevatedButton(
            onPressed: () {
              String rutas = """
Generation 0: Best route [Folie des Visites, Seven Squares Paris, Parque De Diversão, Flaneur, thanina thannina, Aventure Fantastique] with distance: 19.019284750809778
Generation 1: Best route [Flaneur, Seven Squares Paris, Folie des Visites, Parque De Diversão, thanina thannina, Aventure Fantastique] with distance: 20.514320404231565
Generation 2: Best route [thanina thannina, Seven Squares Paris, Folie des Visites, Parque De Diversão, Aventure Fantastique, Flaneur] with distance: 21.467484680523906
Generation 3: Best route [Folie des Visites, Parque De Diversão, thanina thannina, Flaneur, Aventure Fantastique, Seven Squares Paris] with distance: 16.6329220398447
Generation 4: Best route [Parque De Diversão, thanina thannina, Flaneur, Aventure Fantastique, Seven Squares Paris, Folie des Visites] with distance: 16.632922039844694
Generation 5: Best route [Parque De Diversão, thanina thannina, Flaneur, Aventure Fantastique, Seven Squares Paris, Folie des Visites] with distance: 16.632922039844694
Generation 6: Best route [Aventure Fantastique, Flaneur, Parque De Diversão, thanina thannina, Seven Squares Paris, Folie des Visites] with distance: 18.42741384426158
Generation 7: Best route [Folie des Visites, Parque De Diversão, thanina thannina, Flaneur, Aventure Fantastique, Seven Squares Paris] with distance: 16.6329220398447
Generation 8: Best route [Parque De Diversão, thanina thannina, Flaneur, Aventure Fantastique, Seven Squares Paris, Folie des Visites] with distance: 16.632922039844694
Generation 9: Best route [Flaneur, Parque De Diversão, thanina thannina, Seven Squares Paris, Folie des Visites, Aventure Fantastique] with distance: 18.427413844261576
Generation 10: Best route [thanina thannina, Seven Squares Paris, Folie des Visites, Aventure Fantastique, Flaneur, Parque De Diversão] with distance: 18.427413844261576
Generation 11: Best route [Seven Squares Paris, Folie des Visites, Aventure Fantastique, Flaneur, Parque De Diversão, thanina thannina] with distance: 18.42741384426158
Generation 12: Best route [Seven Squares Paris, Folie des Visites, thanina thannina, Flaneur, Aventure Fantastique, Parque De Diversão] with distance: 21.3884752513871
Generation 13: Best route [Folie des Visites, thanina thannina, Flaneur, Aventure Fantastique, Parque De Diversão, Seven Squares Paris] with distance: 21.3884752513871
Generation 14: Best route [Flaneur, Aventure Fantastique, Parque De Diversão, Seven Squares Paris, Folie des Visites, thanina thannina] with distance: 21.388475251387096
Generation 15: Best route [Aventure Fantastique, Parque De Diversão, Seven Squares Paris, Folie des Visites, thanina thannina, Flaneur] with distance: 21.388475251387096
Generation 16: Best route [thanina thannina, Flaneur, Seven Squares Paris, Folie des Visites, Aventure Fantastique, Parque De Diversão] with distance: 19.182837658331767
Generation 17: Best route [Folie des Visites, Aventure Fantastique, Parque De Diversão, thanina thannina, Flaneur, Seven Squares Paris] with distance: 19.1828376583317
Generation 18: Best route [Seven Squares Paris, Folie des Visites, Parque De Diversão, thanina thannina, Flaneur, Aventure Fantastique] with distance: 16.632922039844697
Generation 19: Best route [Flaneur, Aventure Fantastique, Seven Squares Paris, Folie des Visites, Parque De Diversão, thanina thannina] with distance: 16.632922039844697
La mejor ruta encontrada con fitness: 16.632922039844694, [Parque De Diversão, thanina thannina, Flaneur, Aventure Fantastique, Seven Squares Paris, Folie des Visites]
""";

              debugPrint(rutas);
            },
            child: Text('aplastame weeee'),
          )
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
