import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:memory_game/src/cubit/game_cubit.dart';
import 'package:memory_game/src/screens/splash.dart';
import 'package:memory_game/src/widgets/memory_card.dart';

class Home extends StatefulWidget {
  final int pairCount;
  final GameTheme theme;
  const Home({super.key, this.pairCount = 8, this.theme = GameTheme.halloween});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    context.read<GameCubit>().startGame(
      pairCount: widget.pairCount,
      theme: widget.theme,
    );
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// 2x4 grid (4 pairs) → 2 columns, 4x4 (8 pairs) → 4 columns
  int get _crossAxisCount => widget.pairCount == 4 ? 2 : 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<GameCubit, GameState>(
            listener: (context, state) {
              if (state is GameCompleted) {
                _confettiController.play();
                _showGameOverDialog(context, state.moves);
              }
            },
            builder: (context, state) {
              if (state is! GameInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = state.items;
              return Column(
                children: [
                  _buildHeader(state.moves, state.pairs, state.totalPairs),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = _crossAxisCount;
                          final rows = items.length ~/ cols;
                          const spacing = 16.0;

                          // Card width based on number of columns
                          final cardWidth =
                              (constraints.maxWidth - spacing * (cols - 1)) / cols;

                          // Total height if cards were perfectly square
                          final squareGridHeight =
                              rows * cardWidth + spacing * (rows - 1);

                          double aspectRatio;
                          double verticalPad;

                          if (squareGridHeight <= constraints.maxHeight) {
                            // Cards fit as squares → centre the grid vertically
                            aspectRatio = 1.0;
                            verticalPad =
                                (constraints.maxHeight - squareGridHeight) / 2;
                          } else {
                            // Square cards overflow → shrink height so all rows fit
                            final cardHeight =
                                (constraints.maxHeight - spacing * (rows - 1)) /
                                rows;
                            aspectRatio = cardWidth / cardHeight;
                            verticalPad = 0;
                          }

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: verticalPad),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cols,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: aspectRatio,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final isFlipped =
                                    item.isComplete ||
                                    index == state.firstIndex ||
                                    index == state.secondIndex;

                                return MemoryCard(
                                  item: item,
                                  isFlipped: isFlipped,
                                  onTap: () {
                                    if (item.isComplete) return;
                                    if (state.firstIndex != -1 &&
                                        state.secondIndex != -1)
                                      return;
                                    if (index == state.firstIndex) return;

                                    if (state.count == 0) {
                                      context
                                          .read<GameCubit>()
                                          .setFirstIndex(index);
                                    } else {
                                      context
                                          .read<GameCubit>()
                                          .setSecondIndex(index);
                                      context
                                          .read<GameCubit>()
                                          .checkMatchingPair();
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int moves, int pairs, int totalPairs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 8.0),
      child: Column(
        children: [
          // AppBar-style row: back | title (centred) | spacer
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _confettiController.stop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white70,
                iconSize: 22,
                tooltip: 'Back to Home',
              ),
              const Expanded(
                child: Text(
                  "MEMORY GAME",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              // Mirror spacer so title stays perfectly centred
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("MOVES", moves.toString()),
              _buildStatCard("PAIRS", "$pairs / $totalPairs"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, int moves) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purpleAccent.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "🎉 You Won! 🎉",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Completed in $moves moves",
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  // Play Again button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        _confettiController.stop();
                        Navigator.pop(context);
                        context.read<GameCubit>().resetBoard();
                      },
                      child: const Text(
                        "PLAY AGAIN",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Back to Home button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        _confettiController.stop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "HOME",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
