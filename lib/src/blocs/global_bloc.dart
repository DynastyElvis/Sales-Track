import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_tracker/src/blocs/repository.dart';

class GlobalBloc extends StatefulWidget {
  static GlobalBlocState of(BuildContext context) =>
      context.findAncestorStateOfType<GlobalBlocState>()!;

  final Widget child;

  GlobalBloc({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  GlobalBlocState createState() => GlobalBlocState();
}

class GlobalBlocState extends State<GlobalBloc> {
  Repository? _repository;

  Repository get repository => _repository!;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((event) {
      _repository = event != null ? Repository(user: event) : null;
      notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void notify() {
    if (mounted) setState(() {});
  }
}
