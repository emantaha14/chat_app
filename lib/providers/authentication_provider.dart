import 'dart:convert';


import 'package:chat_app/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;

  bool get isSuccessful => _isSuccessful;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;

  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // check if user exists
  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    if(documentSnapshot.exists){
      return true;
    }
    else{
      return false;
    }
  }

  // get user data from firestore

  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
   _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
   notifyListeners();
  }

  // save user data to shared preferences
  Future<void> saveUserDataToSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(Constants.userModel, jsonEncode(userModel?.toMap()));
  }

  // get data from shared preferences
  Future<void> getUserDataFromSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> mapData = jsonDecode(sharedPreferences.getString(Constants.userModel) ?? '') ;
      _userModel = UserModel.fromMap(mapData);
      _uid = _userModel?.uid;
      notifyListeners();
  }

  // sign in with phone number

  Future<void> signInWithPhoneNumber(
      {required String phoneNumber, required BuildContext context}) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential).then((value) {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isSuccessful = true;
            _isLoading = false;
            notifyListeners();
          });
        },
        verificationFailed: (error) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          print('errrrrrrrrrrrrrrrrrrror');
          print(error.toString());
          showSnackBar(context, error.toString());
        },
        codeSent: (verificationId, forceResendingToken) {
          _isLoading = false;
          notifyListeners();

          // navigate to otp screen
          Navigator.of(context).pushNamed(Constants.otpScreen, arguments: {
            Constants.verificationId: verificationId,
            // 'forceResendingToken': forceResendingToken,
            Constants.phoneNumber: phoneNumber,
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {});
  }

  // verify otp code

  Future<void> verifyOTPCode(
      {required String verificationId,
      required String otpCode,
      required BuildContext context,
      required Function onSuccess}) async {
    _isLoading = true;
    notifyListeners();

    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();

      // fetch user data from firestore
      // await fetchUserData(_uid);

      // navigate to home screen
      Navigator.of(context).pushReplacementNamed(Constants.homeScreen);
    }).catchError((error) {
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, error.toString());
    });
  }
}
