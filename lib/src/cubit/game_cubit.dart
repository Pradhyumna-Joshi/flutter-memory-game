import 'package:bloc/bloc.dart';
import 'package:memory_game/src/models/game.dart';
import 'package:meta/meta.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameInitial());

  final List<String> _games = [
    "assets/halloween/vampire.png",
    "assets/halloween/cyclops.png",
    "assets/halloween/ghost.png",
    "assets/halloween/monster.png",
    "assets/halloween/mummy.png",
    "assets/halloween/pumpkin.png",
    "assets/halloween/pumpkin-bag.png",
    "assets/halloween/ghost-custom.png",
  ];

  void startGame() {
    final items = generateBoard();
    emit(GameInProgress(items: items));
  }

  List<Game> generateBoard() {
    final List<String> items = [..._games, ..._games];
    items.shuffle();
    return List.generate(
      items.length,
      (index) => Game(index: index, imageURL: items[index], isComplete: false),
    );
  }

  void setFirstIndex(int index) {
    final currentState = state;
    if (currentState is GameInProgress) {
      emit(currentState.copyWith(firstIndex: index, count: 1));
    }
  }

  void setSecondIndex(int index) {
    final currentState = state;
    if (currentState is GameInProgress) {
      emit(
        currentState.copyWith(
          secondIndex: index,
          count: 0,
          moves: currentState.moves + 1,
        ),
      );
    }
  }

  void checkMatchingPair() {
    final currentState = state;
    if (currentState is GameInProgress) {
      final first = currentState.items[currentState.firstIndex];
      final second = currentState.items[currentState.secondIndex];
      print(currentState.pairs);
      if (first.imageURL == second.imageURL) {
        List<Game> items = currentState.items
            .map(
              (item) => (item.imageURL == first.imageURL)
                  ? item.copyWith(isComplete: true)
                  : item,
            )
            .toList();
        final pairs = currentState.pairs + 1;
        if (currentState.pairs == 7) {
          emit(GameCompleted(moves: currentState.moves));
        } else {
          emit(
            currentState.copyWith(
              firstIndex: -1,
              secondIndex: -1,
              items: items,
              pairs: currentState.pairs + 1,
            ),
          );
        }
      } else {
        Future.delayed(Duration(milliseconds: 800), () {
          emit(currentState.copyWith(firstIndex: -1, secondIndex: -1));
        });
      }
    }
  }

  void resetBoard() {
    startGame();
  }
}
