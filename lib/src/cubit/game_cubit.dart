import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:memory_game/src/models/game.dart';

part 'game_state.dart';

enum GameTheme { halloween, sports, fruits }

extension GameThemeExtension on GameTheme {
  String get folder {
    switch (this) {
      case GameTheme.halloween:
        return 'halloween';
      case GameTheme.sports:
        return 'sports';
      case GameTheme.fruits:
        return 'fruits';
    }
  }

  List<String> get images {
    switch (this) {
      case GameTheme.halloween:
        return [
          "assets/halloween/vampire.png",
          "assets/halloween/cyclops.png",
          "assets/halloween/ghost.png",
          "assets/halloween/monster.png",
          "assets/halloween/mummy.png",
          "assets/halloween/pumpkin.png",
          "assets/halloween/pumpkin-bag.png",
          "assets/halloween/ghost-custom.png",
        ];
      case GameTheme.sports:
        return [
          "assets/sports/americanfootball.png",
          "assets/sports/basketball.png",
          "assets/sports/basketballjersey.png",
          "assets/sports/bowling.png",
          "assets/sports/footballjersey.png",
          "assets/sports/pingpong.png",
          "assets/sports/skating.png",
          "assets/sports/trophy.png",
        ];
      case GameTheme.fruits:
        return [
          "assets/fruits/grape.png",
          "assets/fruits/mango.png",
          "assets/fruits/orange.png",
          "assets/fruits/papaya.png",
          "assets/fruits/pear.png",
          "assets/fruits/pineapple.png",
          "assets/fruits/strawberry.png",
          "assets/fruits/watermelon.png",
        ];
    }
  }
}

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameInitial());

  /// Start a new game with the chosen [theme] and [pairCount].
  void startGame({int pairCount = 8, GameTheme theme = GameTheme.halloween}) {
    final items = generateBoard(pairCount: pairCount, theme: theme);
    emit(GameInProgress(items: items, totalPairs: pairCount, theme: theme));
  }

  List<Game> generateBoard({
    int pairCount = 8,
    GameTheme theme = GameTheme.halloween,
  }) {
    final all = theme.images;
    final selected = all.take(pairCount).toList();
    final doubled = [...selected, ...selected];
    doubled.shuffle();
    return List.generate(
      doubled.length,
      (index) => Game(index: index, imageURL: doubled[index], isComplete: false),
    );
  }

  void setFirstIndex(int index) {
    final s = state;
    if (s is GameInProgress) {
      if (s.firstIndex != -1 && s.secondIndex != -1) return;
      emit(s.copyWith(firstIndex: index, count: 1));
    }
  }

  void setSecondIndex(int index) {
    final s = state;
    if (s is GameInProgress) {
      if (s.firstIndex != -1 && s.secondIndex != -1) return;
      if (index == s.firstIndex) return;
      emit(s.copyWith(secondIndex: index, count: 0, moves: s.moves + 1));
    }
  }

  void checkMatchingPair() {
    final s = state;
    if (s is GameInProgress) {
      final first = s.items[s.firstIndex];
      final second = s.items[s.secondIndex];
      if (first.imageURL == second.imageURL) {
        final updated = s.items
            .map((i) => i.imageURL == first.imageURL ? i.copyWith(isComplete: true) : i)
            .toList();
        if (s.pairs == s.totalPairs - 1) {
          emit(GameCompleted(moves: s.moves));
        } else {
          emit(s.copyWith(
            firstIndex: -1,
            secondIndex: -1,
            items: updated,
            pairs: s.pairs + 1,
          ));
        }
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          emit(s.copyWith(firstIndex: -1, secondIndex: -1));
        });
      }
    }
  }

  void resetBoard() {
    final s = state;
    final pairCount = s is GameInProgress ? s.totalPairs : 8;
    final theme = s is GameInProgress ? s.theme : GameTheme.halloween;
    startGame(pairCount: pairCount, theme: theme);
  }
}
