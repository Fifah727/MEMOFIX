import 'package:flutter/material.dart';
import 'package:memofix/screens/login/login.dart';
import 'package:memofix/screens/login/terms.dart';
import 'package:memofix/screens/login/password.dart';
import 'package:animations/animations.dart';

class Guest extends StatefulWidget {
  const Guest({super.key});
  @override
  State<Guest> createState() => _GuestState();
}

class _GuestState extends State<Guest> {
  List<Widget> _widgets = [];
  int _indexSelected = 0;

  @override
  void initState() {
    super.initState();
    _widgets.addAll([
      Login(onChangedStep: (index) => setState(() => _indexSelected = index)),
      Terms(onChangedStep: (index) => setState(() => _indexSelected = index)),
      Password(
        onChangedStep: (index) => setState(() => _indexSelected = index),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageTransitionSwitcher(
          duration: Duration(milliseconds: 500),
          transitionBuilder: (child, animation, secondaryAnimation) =>
              FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              ),
          child: _widgets[_indexSelected],
        ),
      ),
    );
  }
}
