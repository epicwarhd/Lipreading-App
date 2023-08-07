import 'package:flutter/material.dart';

class UserFirebaseInfo extends ChangeNotifier {
  String _uid = '';

  String get uid => _uid;

  void setUser(id) {
    _uid = id;
  }
}
