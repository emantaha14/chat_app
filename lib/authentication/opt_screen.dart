import 'package:chat_app/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class OPTScreen extends StatefulWidget {
  const OPTScreen({super.key});

  @override
  State<OPTScreen> createState() => _OPTScreenState();
}

class _OPTScreenState extends State<OPTScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final authProvider = context.watch<AuthenticationProvider>();

    final defaultPinTheme = PinTheme(
        width: 56,
        height: 60,
        textStyle: GoogleFonts.openSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.transparent)));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Verification',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Enter the 6-digit code sent the number',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  phoneNumber,
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 68,
                  child: Pinput(
                    length: 6,
                    controller: controller,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    onCompleted: (pin) {
                      setState(() {
                        otpCode = pin;
                      });
                      verifyOTPCode(verificationId: verificationId, otpCode: otpCode!,);
                    },


                    focusedPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                authProvider.isLoading? const CircularProgressIndicator():
                    const SizedBox.shrink(),
               authProvider.isSuccessful? Container(
                 height: 50,
                 width: 50,
                 decoration: const BoxDecoration(
                   color: Colors.green,
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(
                   Icons.done,
                   color : Colors.white,
                   size: 30,
                 ),
               ): const SizedBox.shrink(),
                authProvider.isLoading? const SizedBox.shrink():
                Text(
                  'Didn\'t receive the code ?',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                authProvider.isLoading? const SizedBox.shrink():
                TextButton(
                    onPressed: () {
                      // TODO resend otp code
                    },
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.openSans(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
        verificationId: verificationId,
        otpCode: otpCode,
        context: context,
        onSuccess: () async{
          // 1- check if user exists in firestore
          bool userExists = await authProvider.checkUserExists();

          if(userExists){
            // 2- if user exists, navigate to home screen
            // * get user information from firestore
            await authProvider.getUserDataFromFireStore();
            // 5- save user information to local storage
            await authProvider.saveUserDataToSharedPref();
            navigate(userExists: true);
          }
          else{
            // 4- if user doesn't exist, navigate to user information screen
            navigate(userExists: false);
          }
        });
  }
  void navigate({required bool userExists}){
    if(userExists){
      Navigator.of(context).pushNamedAndRemoveUntil(
        Constants.homeScreen,
        (route) => false,
      );
    }
    else{
      Navigator.of(context).pushNamed(Constants.userInformationScreen);
    }
  }
}
