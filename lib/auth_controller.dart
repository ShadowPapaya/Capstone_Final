import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'login_page.dart';
import 'welcome_page.dart';
import 'welcome_innovation.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController{
  //AuthController.instance..
  static AuthController instance= Get.find();
  //email, password, name...
  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onReady(){
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    //our user would be notified
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  _initialScreen(User? user){
    if(user==null){
      print("Login page");
      Get.offAll(()=>LoginPage());
    }else{
      Get.offAll(()=>WelcomePage1(email:user.email.toString()));
    }
  }

  void register(String email, password)async{
    try {
    await  auth.createUserWithEmailAndPassword(email: email, password: password);
    }catch(e){
      Get.snackbar("About User", "User message",
      backgroundColor: Colors.redAccent,
      snackPosition: SnackPosition.BOTTOM,
      titleText: Text(
        "Account creation failed",
            style: TextStyle(
          color: Colors.white
      ),
      ),
        messageText: Text(
          e.toString(),
            style: TextStyle(
                color: Colors.white
            )
        )
      );
    }
  }
  void login(String email, password)async{
    try {
      await  auth.signInWithEmailAndPassword(email: email, password: password);
    }catch(e){
      Get.snackbar("About Login", "Login message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text(
            "Login failed",
            style: TextStyle(
                color: Colors.white
            ),
          ),
          messageText: Text(
              e.toString(),
              style: TextStyle(
                  color: Colors.white
              )
          )
      );
    }
  }
  void logOut()async{
    await auth.signOut();
  }

}