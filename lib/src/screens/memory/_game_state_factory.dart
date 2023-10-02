import 'package:flutter_memory/utils/difficulty.dart';

import '_game_state.dart';

class GameStateFactory {
  static GameState<TElement> getGameState<TElement>(
      {required List<TElement> elements, required Difficulty difficulty}) {
    return switch (difficulty) {
      Difficulty.easy => easy(elements: elements),
      Difficulty.medium => medium(elements: elements),
      Difficulty.hard => hard(elements: elements),
    };
  }

  static GameState<TElement> easy<TElement>(
      {required List<TElement> elements, int numberOfPairs = 1}) {
    return GameState(
      elements: elements,
      attemptsAllowed: GameState.baseAttempts(elements.length, numberOfPairs) +
          (elements.length / 4).floor(),
      numberOfPairs: numberOfPairs,
    );
  }

  static GameState<TElement> medium<TElement>(
      {required List<TElement> elements, int numberOfPairs = 1}) {
    return GameState(
      elements: elements,
      attemptsAllowed: GameState.baseAttempts(elements.length, numberOfPairs),
      numberOfPairs: numberOfPairs,
    );
  }

  static GameState<TElement> hard<TElement>(
      {required List<TElement> elements, int numberOfPairs = 1}) {
    return GameState(
      elements: elements,
      attemptsAllowed: GameState.baseAttempts(elements.length, numberOfPairs) -
          (elements.length / 4).floor(),
      numberOfPairs: numberOfPairs,
    );
  }
}
