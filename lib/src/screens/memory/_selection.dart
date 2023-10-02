import 'package:flutter/material.dart';

class Selection extends ChangeNotifier {
  int? _first;
  int? _second;

  Selection(int? first, int? second)
      : _first = first,
        _second = second;

  int? get first => _first;
  int? get second => _second;

  bool madePair() => second != null;

  void add(int? value) {
    if (second != null) {
      _first = value;
      _second = null;
    } else if (first == null) {
      _first = value;
    } else {
      _second = value;
    }

    notifyListeners();
  }

  void reset() {
    _first = null;
    _second = null;

    notifyListeners();
  }

  bool contains(int index) => [first, second].contains(index);
}
