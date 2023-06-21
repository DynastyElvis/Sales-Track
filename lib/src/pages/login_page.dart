import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rive/rive.dart';
import 'package:sales_tracker/src/pages/widgets/error_message.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RiveAnimation.asset(
              'lib/res/portable-table.riv',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Color(0xff62758d),
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => signInWithGoogle(context),
              child: ListTile(
                title: Text('SIGN IN'),
                trailing: Icon(Icons.login),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser!.authentication;

      // Create a new credential
      final auth = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(auth);
    } catch (err) {
      showDialog(
        context: context,
        builder: (_) => ErrorMessage(
          messageText: 'Failed to sign in',
          errorDetails: err,
          onDismiss: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      );
    }
  }
}
