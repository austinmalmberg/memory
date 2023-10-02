import 'dart:math';

import 'package:flutter/material.dart';

class GameState<TElement> extends ChangeNotifier {
  late List<int> _board;

  int get length => elements.length * 2 * numberOfPairs;

  /// The elements used to generate the board.
  final List<TElement> elements;

  /// The number of pairs of each [TElement].
  final int numberOfPairs;

  /// The attempts allowed per game.
  final int attemptsAllowed;

  RunState runState = RunState.normal;

  /// True when the [runState] is not [RunState.normal].
  bool get gameOver => runState != RunState.normal;

  int get remaining => attemptsAllowed - strikes;

  int _strikes = 0;
  int get strikes => _strikes;

  bool victory() => _board.every((element) => element < 0);
  bool defeat() => remaining == 0;

  GameState({
    required this.elements,
    required this.attemptsAllowed,
    this.numberOfPairs = 1,
  }) : assert(attemptsAllowed > 0) {
    _board = _initBoard(elements, numberOfPairs);
  }

  static int baseAttempts(int numberOfElements, int numberOfPairs) =>
      ((numberOfElements - 1) / numberOfPairs).floor();

  static List<int> _initBoard<TElement>(List<TElement> elements, int pairs,
      [Random? rng]) {
    rng ??= Random();

    List<int> result = List.generate(
        elements.length * 2 * pairs, (index) => (index % elements.length) + 1);

    result.shuffle(rng);

    return result;
  }

  /// Attempts to create a match and returns whether the [TElement] at both indexes match.
  ///
  /// Throws a [StateError] if the [runState] is not [RunState.normal].
  /// Throws a [ArgumentError] if either index has already been matched.
  bool match(int a, int b) {
    if (runState != RunState.normal) {
      throw StateError('Game not running.');
    } else if (_board[a] < 0) {
      throw ArgumentError.value(a, 'a', 'a has already been matched.');
    } else if (_board[b] < 0) {
      throw ArgumentError.value(b, 'b', 'b has already been matched.');
    }

    bool isMatch = _board[a] == _board[b];

    if (isMatch) {
      debugPrint(
          'Match found at indexes $a and $b. Strikes remaining: $remaining');

      _board[a] *= -1;
      _board[b] *= -1;

      if (victory()) {
        debugPrint('Victory!');

        runState = RunState.victory;
      }
    } else {
      ++_strikes;

      debugPrint(
          'No match at indexes $a and $b. Strikes remaining: $remaining');

      if (defeat()) {
        debugPrint('Game over!');

        runState = RunState.defeat;
      }
    }

    notifyListeners();

    return isMatch;
  }

  bool isFound(int index) => _board[index] < 0;

  /// Returns the [TElement] at the [index].
  TElement elementAt(int index) => elements[_board[index].abs() - 1];

  void reset() {
    _board = _initBoard(elements, numberOfPairs);
    runState = RunState.normal;
    _strikes = 0;

    notifyListeners();
  }
}

enum RunState {
  normal,
  victory,
  defeat,
}
