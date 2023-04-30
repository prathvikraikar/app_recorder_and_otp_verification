import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_record_app/videorecording.dart';

class MobileOtpVerification extends StatefulWidget {
  @override
  _MobileOtpVerificationState createState() => _MobileOtpVerificationState();
}

class _MobileOtpVerificationState extends State<MobileOtpVerification> {
  final _auth = FirebaseAuth.instance;
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  late String _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile OTP Verification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                hintText: 'OTP Code',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _verifyPhoneNumber(_phoneNumberController.text);
              },
              child: Text('Send OTP'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _signInWithPhoneNumber(_otpController.text);
              },
              child: Text('Verify OTP'),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => VideoRecorder()));
                },
                child: Text('NEXT'))
          ],
        ),
      ),
    );
  }

  void _verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _signInWithPhoneNumber(String otpCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpCode,
      );
      await _auth.signInWithCredential(credential);
      // Handle sign-in success here
    } catch (e) {
      print(e.message);
      // Handle sign-in failure here
    }
  }
}
