import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_game/src/cubit/game_cubit.dart';
import 'package:memory_game/src/models/game.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  void initState() {
    context.read<GameCubit>().startGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Memory game")),
      body: Center(
        child: BlocConsumer<GameCubit, GameState>(
          listener: (context, state) {
            if (state is GameCompleted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("🎉 Game Completed"),
                  content: Text("You finished in ${state.moves} moves"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<GameCubit>().resetBoard();
                      },
                      child: Text("Play Again"),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is! GameInProgress) {
              return SizedBox();
            }
            final items = state.items;
            return Column(
              children: [
                Text("Moves : ${state.moves}", style: TextStyle(fontSize: 20)),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () {
                          if (state.count == 0) {
                            context.read<GameCubit>().setFirstIndex(index);
                          } else {
                            context.read<GameCubit>().setSecondIndex(index);
                            context.read<GameCubit>().checkMatchingPair();
                          }
                        },
                        child: Card(
                          child: Center(
                            child:
                                item.isComplete ||
                                    (index == state.firstIndex ||
                                        index == state.secondIndex)
                                ? Image(
                                    width: 60,
                                    height: 60,
                                    image: AssetImage(item.imageURL),
                                    fit: BoxFit.contain,
                                  )
                                : SizedBox.shrink(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
