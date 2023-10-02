enum Difficulty {
  easy,
  medium,
  hard;

  @override
  String toString() {
    return switch (this) {
      _ => name.toUpperCase(),
    };
  }
}

extension DifficultyExtensions on Difficulty {
  increase() {
    return switch (this) {
      Difficulty.easy => Difficulty.medium,
      Difficulty.medium => Difficulty.hard,
      Difficulty.hard => Difficulty.hard,
    };
  }

  decrease() {
    return switch (this) {
      Difficulty.easy => Difficulty.easy,
      Difficulty.medium => Difficulty.easy,
      Difficulty.hard => Difficulty.medium,
    };
  }
}
