import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tesis_v2/screens/login_screen.dart';
import 'package:tesis_v2/screens/select_city_screen.dart';
import 'package:tesis_v2/services/db_service.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/services/snackbar_service.dart';

enum AuthStatus {
  notAuthenticated,
  authenticating,
  authenticated,
  userNotFound,
  registering,
  error,
}

const List<String> scopes = <String>['email', 'profile', 'openid'];

class AuthProvider extends ChangeNotifier {
  User? user;

  static AuthProvider instance = AuthProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthStatus? status;

  AuthProvider() {
    _checkCurrentUserIsAuthenticated();
  }

  Future<void> _authoLogin() async {
    if (user != null) {
      return NavigationService.instance
          .navigateToReplacementName(SelectCityScreen.routeName);
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    // ignore: await_only_futures
    user = await _auth.currentUser;
    if (user != null) {
      notifyListeners();
      await _authoLogin();
    } else {
      //notifyListeners();
      return NavigationService.instance
          .navigateToReplacementName(LoginScreen.routeName);
    }
  }

  Future<void> signInWithGoogle() async {
    status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // being interactive sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      // create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      //finally lets sign in
      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      user = result.user;

      if (await DBService.instance.existUserInDatabase(user!.uid)) {
        // ignore: avoid_print
        print('El usuario ${user!.displayName} ya existe');
      } else {
        String phoneNumber = user!.phoneNumber ?? 'SN';

        await DBService.instance.createdUserInDB(
          user!.uid,
          user!.displayName!,
          user!.email!,
          phoneNumber,
          user!.photoURL!,
        );
      }
      SnackBarService.instance
          .showSnackBar("Bienvenido, ${user!.displayName}", true);
      status = AuthStatus.authenticated;
      notifyListeners();
      await NavigationService.instance
          .navigateToReplacementName(SelectCityScreen.routeName);
    } catch (e) {
      status = AuthStatus.notAuthenticated;
      user = null;
      SnackBarService.instance.showSnackBar("Error Registering user", false);
      // ignore: avoid_print
      print("**************** $e");
    }
    notifyListeners();
  }

  Future<void> signInWithFacebook() async {
    status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // Iniciar el flujo de inicio de sesión interactivo
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Obtener detalles de autenticación de la solicitud
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Crear una credencial para el usuario
      final UserCredential result = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
      user = result.user;

      if (await DBService.instance.existUserInDatabase(user!.uid)) {
        print('El usuario ${user!.displayName} ya existe');
      } else {
        String phoneNumber = user!.phoneNumber ?? 'SN';

        await DBService.instance.createdUserInDB(
          user!.uid,
          user!.displayName!,
          user!.email!,
          phoneNumber,
          user!.photoURL!,
        );
      }
      SnackBarService.instance.showSnackBar("Sesión iniciada", true);
      status = AuthStatus.authenticated;
      notifyListeners();
      await NavigationService.instance
          .navigateToReplacementName(SelectCityScreen.routeName);
    } catch (e) {
      status = AuthStatus.notAuthenticated;
      user = null;
      SnackBarService.instance.showSnackBar("Error al iniciar sesión", false);
      print("**************** $e");
    }
    notifyListeners();
  }

  Future<void> showGuestLoginConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // No se puede cerrar el diálogo haciendo clic afuera
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  '¿Entrar como invitado?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Recuerda, si ingresas como invitado, TUS DATOS NO SE GUARDARÁN.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el diálogo
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Cierra el diálogo
                          await signInAsGuest(); // Inicia sesión como invitado
                        },
                        child: const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> signInAsGuest() async {
    status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // Iniciar sesión de forma anónima
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        // Usuario ingresado como invitado
        SnackBarService.instance.showSnackBar("Sesión iniciada", true);
        status = AuthStatus.authenticated;
        notifyListeners();
        await NavigationService.instance
            .navigateToReplacementName(SelectCityScreen.routeName);
        print('Usuario ingresado como invitado con ID: ${user.uid}');
      } else {
        print('Error: No se pudo iniciar sesión como invitado');
      }
    } catch (e) {
      status = AuthStatus.notAuthenticated;
      user = null;
      SnackBarService.instance.showSnackBar("Error al iniciar sesión", false);
      print("**************** $e");
    }
  }

  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      //await FacebookAuth.i.logOut();
      user = null;
      status = AuthStatus.notAuthenticated;
      //GlobalVariables.instance.index = 1;
/*       SnackBarService.instance
          .showSnackBar("Sesion cerrada exitosamente", true); */
      await NavigationService.instance
          .navigateToReplacementName(LoginScreen.routeName);
    } catch (e) {
      SnackBarService.instance.showSnackBar("Error al cerrar sesión", false);
    }
    notifyListeners();
  }
}
