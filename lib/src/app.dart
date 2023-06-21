import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_tracker/src/blocs/global_bloc.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/pages/home_page.dart';
import 'package:sales_tracker/src/pages/login_page.dart';
import 'package:sales_tracker/src/pages/password_page.dart';

class SalesTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlobalBloc(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        title: 'Sales Tracker',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.idTokenChanges(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return buildLoading();
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.data == null) {
                  return LoginPage();
                }
                return withUserVerification(context);
            }
          },
        ),
      ),
    );
  }

  Widget withUserVerification(BuildContext context) {
    return StreamBuilder<bool?>(
      stream: Repository.of(context).userVerified,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return buildLoading();
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              FirebaseAuth.instance.signOut();
            }
            if (snapshot.data == true) {
              return HomePage();
            }
            return PasswordPage();
        }
      },
    );
  }

  Widget buildLoading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
