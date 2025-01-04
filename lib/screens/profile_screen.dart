import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tesis_v2/models/user_%20model.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/screens/preferences_selection_screen.dart';
import 'package:tesis_v2/services/db_service.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/services/snackbar_service.dart';
import 'package:tesis_v2/utils/dimensions.dart';
import 'package:tesis_v2/utils/places_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = "/profile";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isChange = false;
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  AuthProvider? _auth;

  late UserData userDataGlobal;

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);

    List<Map<String, dynamic>> filteredPlaces;

    //Filtrar los lugares según las preferenias de lusuario
    //final List<Map<String, dynamic>> filteredPLaces = PlacesList().lugares.where((lugar) => user)
    return Scaffold(
      body: StreamBuilder<UserData>(
          stream: DBService.instance.getUserDataStream(_auth!.user!.uid),
          builder: (BuildContext context, snapshot) {
            var userData = snapshot.data;
            if (snapshot.hasData) {
              filteredPlaces = PlacesList()
                  .lugares
                  .where(
                      (lugar) => userData!.preferences.contains(lugar['type']))
                  .toList();
            } else {
              filteredPlaces = [];
            }

            return snapshot.hasData
                ? Stack(
                    children: [
                      Positioned(
                        top: (Dimensions.screenHeight * 0.4) * 0.60,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: Dimensions.screenHeight -
                              ((Dimensions.screenHeight * 0.4) * 0.60),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: Dimensions.screenWidth * 0.05,
                                right: Dimensions.screenWidth * 0.05,
                                top: Dimensions.screenHeight * 0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Mis preferencias",
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: ListView.builder(
                                          //controller: _scrollController,
                                          padding: const EdgeInsets.all(20.0),
                                          itemCount:
                                              //PlacesList().lugares.length,
                                              filteredPlaces.length,
                                          itemBuilder: (context, index) {
                                            var lugar =
                                                //PlacesList().lugares[index];
                                                filteredPlaces[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 30),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                      color: lugar['color'],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Icon(
                                                      lugar['icon'],
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Expanded(
                                                    flex: 10,
                                                    child: Text(
                                                      lugar['name'],
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: SizedBox(
                                            width:
                                                Dimensions.screenWidth * 0.75,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                NavigationService.instance
                                                    .navigatePushName(
                                                        PreferencesSelectionScreen
                                                            .routeName);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.purple,
                                              ),
                                              child: const Text(
                                                  'Editar Preferencias'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 35,
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Mis itinerarios",
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 15,
                                          left: 45,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                "Itinerario generado 1",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                "Itinerario generado 2",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: Dimensions.screenHeight * 0.3,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            children: [
                              header(userData, context),
                              userInformation(userData),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.purple, size: 30),
                  );
          }),
    );
  }

  Expanded userInformation(UserData? userData) {
    return Expanded(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: Dimensions.screenWidth * 0.08),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                child: CircleAvatar(
                  radius: Dimensions.screenWidth * 0.12,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image(
                      image: NetworkImage(userData!.image),
                      fit: BoxFit.cover,
                      //height: 80,
                      //width: 80,
                      width: Dimensions.screenWidth * 0.22,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userData.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userData.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    userData.phone!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar header(UserData? userData, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 30,
          ),
          onTap: () {
            NavigationService.instance.goBack();
          },
        ),
      ),
      title: const Text("Perfil personal"),
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: Dimensions.screenWidth * 0.04),
          child: GestureDetector(
            onTap: () {
              userDataGlobal = UserData(
                  id: userData!.id,
                  name: userData.name,
                  email: userData.email,
                  phone: userData.phone,
                  image: userData.image,
                  preferences: userData.preferences);

              nameController.text = userData.name;
              phoneController.text = userData.phone ?? '';

              editProfile(context);
            },
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.edit,
                color: Colors.purple,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void editProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Actualiza tus datos',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Recuerda que lo único que no puedes modificar es tu correo',
                //textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[200],
                  fontWeight: FontWeight.w300,
                ),
              ),
              inputForm(),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Restablecer los controladores cuando el BottomSheet se cierra
      nameController.clear();
      phoneController.clear();
      isChange = false;
    });
  }

  Widget inputForm() {
    return SizedBox(
      //height: Dimensions.screenHeight * 0.8,
      width: double.infinity,
      child: Form(
        key: formKey,
        onChanged: () {
          formKey.currentState!.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: nameTextField(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: phoneTextField(),
            ),
            updateButtom(),
          ],
        ),
      ),
    );
  }

  Widget nameTextField() {
    return Row(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Nombre:',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF27023E),
                )),
          ),
        ),

        //width: Dimensions.screenWidth * 0.6,
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: nameController,
            autocorrect: false,
            style: const TextStyle(color: Color(0xFF57419D)),
            validator: (input) {
              if (input!.isEmpty) {
                return 'Ingrese su nombre';
              }
              return null;
            },
            onChanged: (input) {
              isChange = true;
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.purple),
                borderRadius: BorderRadius.circular(50),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.purple),
                borderRadius: BorderRadius.circular(50),
              ),
              prefixIcon: const Icon(Icons.account_box_rounded),
              contentPadding: const EdgeInsets.all(1),
              hintText: "Ingresa tu nombre",
              filled: true,
              fillColor: const Color(0xFFDADAFF),
              prefixIconColor: Colors.purple,
              errorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFFF9B9B), width: 2.5),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget phoneTextField() {
    return Row(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Telefono:',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF27023E),
                )),
          ),
        ),

        //width: Dimensions.screenWidth * 0.6,
        Expanded(
          flex: 2,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: phoneController,
            autocorrect: false,
            style: const TextStyle(color: Color(0xFF57419D)),
            validator: (input) {
              if (input!.isEmpty) {
                return 'Ingrese su telefono';
              }
              return null;
            },
            onChanged: (input) {
              isChange = true;
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.purple),
                borderRadius: BorderRadius.circular(50),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.purple),
                borderRadius: BorderRadius.circular(50),
              ),
              prefixIcon: const Icon(Icons.phone_android_outlined),
              contentPadding: const EdgeInsets.all(1),
              hintText: "Número de teléfono",
              filled: true,
              fillColor: const Color(0xFFDADAFF),
              prefixIconColor: Colors.purple,
              errorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFFF9B9B), width: 2.5),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget updateButtom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80, top: 20),
      child: Center(
        //width: Dimensions.screenWidth * 0.9,
        //height: Dimensions.screenHeight * 0.055,
        child: ElevatedButton(
          style: isChange
              ? ButtonStyle(
                  backgroundColor:
                      const WidgetStatePropertyAll(Color(0xFF57419D)),
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32))))
              : ButtonStyle(
                  backgroundColor:
                      const WidgetStatePropertyAll(Color(0xFF9DB2BF)),
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)))),
          onPressed: isLoading ||
                  !isChange ||
                  isLoading ||
                  !isChange ||
                  (formKey.currentState?.validate() ?? false) == false
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });

                  if (formKey.currentState!.validate()) {
                    await DBService.instance
                        .updateUserInDB(
                      UserData(
                          id: userDataGlobal.id,
                          name: nameController.text,
                          email: userDataGlobal.email,
                          phone: phoneController.text,
                          image: userDataGlobal.image,
                          preferences: userDataGlobal.preferences),
                    )
                        .then((value) {
                      setState(() {
                        isLoading = false;
                        isChange = false;
                      });
                      SnackBarService.instance
                          .showSnackBar("Usuario actualizado con exito", true);
                      NavigationService.instance.goBack();
                    });
                  }
                },
          child: isLoading
              ? LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.white, size: 30)
              : const Text(
                  'Actualizar Perfil',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
        ),
      ),
    );
  }
}
