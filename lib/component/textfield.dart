import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BuildInput extends StatelessWidget {
  BuildInput(
      {Key? key,
      this.keyName,
      required this.controllers,
      required this.obsText,
      this.kyType,
      this.brd,
      this.hnt,
      this.actType})
      : super(key: key);

  String? keyName;
  TextInputType? kyType;
  TextInputAction? actType;
  bool obsText = false;
  InputBorder? brd;
  String? hnt;
  TextEditingController controllers = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: actType,
      keyboardType: kyType,
      controller: controllers,
      decoration:
          InputDecoration(labelText: keyName, border: brd, hintText: hnt),
      obscureText: obsText,
    );
  }
}
