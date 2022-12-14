import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../mainScreens/home_Screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialoge.dart';
import 'auth_screen.dart';

class LoginScren extends StatefulWidget {
  const LoginScren({super.key});

  @override
  State<LoginScren> createState() => _LoginScrenState();
}

class _LoginScrenState extends State<LoginScren> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  formValidation() {
    if (emailcontroller.text.isNotEmpty && passwordcontroller.text.isNotEmpty) {
      logInNow();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please fill in all required fields.",
            );
          });
    }
  }

  logInNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return const LoadingDialog(
          message: "Checking details",
        );
      },
    );
    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
            email: emailcontroller.text.trim(),
            password: passwordcontroller.text.trim())
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });
    if (currentUser != null) {
      readDataAndSetAdtaLocaly(currentUser!);
    }
  }

  Future readDataAndSetAdtaLocaly(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get()
        .then((sanapShot) async {
      if (sanapShot.exists) {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!.setString("email", sanapShot.data()!["email"]);
        await sharedPreferences!.setString("name", sanapShot.data()!["name"]);
        await sharedPreferences!
            .setString("photoUrl", sanapShot.data()!["photoUrl"]);
        //geting cart from firebase
        List<String> userCartList =
            sanapShot.data()!["userCart"].cast<String>();
        await sharedPreferences!.setStringList("userCart", userCartList);

        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const HomeScreen()));
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const AuthScreen()));

        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "No account found",
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Image.asset(
                "images/login.png",
                height: 270,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  icondata: Icons.email,
                  controller: emailcontroller,
                  hint: "Email",
                  isObsecre: false,
                ),
                CustomTextField(
                  icondata: Icons.lock,
                  controller: passwordcontroller,
                  hint: "Password",
                  isObsecre: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    formValidation();
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 20)),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
