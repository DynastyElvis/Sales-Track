import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/pages/widgets/error_message.dart';
import 'package:url_launcher/url_launcher.dart';

class PasswordPage extends StatefulWidget {
  PasswordPage({Key? key}) : super(key: key);

  @override
  State createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  String? errorMessage;
  final passwordInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff62758d),
      body: Container(
        alignment: Alignment.center,
        child: Card(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildTitleText(),
                Divider(),
                buildHelpText(),
                SizedBox(height: 5),
                buildAskForPassword(),
                Divider(),
                buildPasswordInput(),
                Divider(),
                buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitleText() {
    return Text(
      'Enter Password',
      style: TextStyle(fontSize: 20),
    );
  }

  Widget buildHelpText() {
    return Text(
      "A password verification is required to access this app for the first time only."
      "You will not be asked for any password again!",
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[700],
      ),
    );
  }

  Widget buildPasswordInput() {
    return TextFormField(
      maxLength: 6,
      obscureText: true,
      controller: passwordInput,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      style: TextStyle(letterSpacing: 10),
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: Icon(Icons.password),
        labelStyle: TextStyle(letterSpacing: 1),
        border: OutlineInputBorder(),
      ),
      onFieldSubmitted: (text) {
        verifyPassword(context, passwordInput.text);
      },
    );
  }

  Widget buildAskForPassword() {
    return OutlinedButton(
      onPressed: askForPassword,
      child: Text("But I do not have the password!"),
    );
  }

  Widget buildActions() {
    return Row(
      children: [
        Spacer(),
        ElevatedButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: Text('Cancel'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => verifyPassword(context, passwordInput.text),
          icon: Icon(Icons.verified),
          label: Text('Verify'),
        ),
      ],
    );
  }

  void verifyPassword(BuildContext context, String password) async {
    try {
      final repository = Repository.of(context);
      await repository.registerAsVerified(password);
    } catch (err) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorMessage(
            messageText: 'Please enter the correct password',
            errorDetails: err,
            onDismiss: () => Navigator.of(context).pop(),
          );
        },
      );
    }
  }

  void askForPassword() async {
    User user = FirebaseAuth.instance.currentUser!;
    final mailtoLink = Mailto(
      to: ['dipu.sudipta@gmail.com'],
      cc: [user.email!],
      subject: 'Password for Sales Tracker',
      body: 'Please send me the password for Sales Tracker app. My email is "${user.email!}"',
    );
    await launch('$mailtoLink');
  }
}
