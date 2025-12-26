part of 'game_cubit.dart';

@immutable
sealed class GameState {
  const GameState();
}

final class GameInitial extends GameState {
  const GameInitial();
}

final class GameInProgress extends GameState {
  final int firstIndex;
  final int secondIndex;
  final int count;
  final int moves;
  final int pairs;
  final List<Game> items;

  const GameInProgress({
    this.firstIndex = -1,
    this.secondIndex = -1,
    this.count = 0,
    this.moves = 0,
    this.pairs = 0,
    required this.items,
  });

  GameInProgress copyWith({
    int? firstIndex,
    int? secondIndex,
    int? count,
    int? moves,
    int? pairs,
    List<Game>? items,
  }) {
    return GameInProgress(
      firstIndex: firstIndex ?? this.firstIndex,
      secondIndex: secondIndex ?? this.secondIndex,
      count: count ?? this.count,
      moves: moves ?? this.moves,
      pairs: pairs ?? this.pairs,
      items: items ?? this.items,
    );
  }
}

final class GameCompleted extends GameState {
  final int moves;
  const GameCompleted({required this.moves});
}

final class GameError extends GameState {
  final String error;
  const GameError({required this.error});
}
