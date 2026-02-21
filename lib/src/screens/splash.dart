import 'package:flutter/material.dart';
import 'package:memory_game/src/cubit/game_cubit.dart';
import 'package:memory_game/src/screens/home.dart';

enum BoardSize { small, large }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  BoardSize _selectedSize = BoardSize.large;
  GameTheme _selectedTheme = GameTheme.halloween;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Title
              const Text(
                "MEMORY",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(
                      color: Colors.deepPurpleAccent,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const Text(
                "GAME",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.purpleAccent,
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Decorative icon — preview image from selected theme
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    _themePreviewImage(_selectedTheme),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const Spacer(),

              // ─── Theme Selection ───────────────────────────────────────────
              _SectionLabel(label: "THEME"),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  children: [
                    _ThemeButton(
                      emoji: "🎃",
                      label: "Halloween",
                      isSelected: _selectedTheme == GameTheme.halloween,
                      onTap: () => setState(() => _selectedTheme = GameTheme.halloween),
                    ),
                    const SizedBox(width: 10),
                    _ThemeButton(
                      emoji: "🏆",
                      label: "Sports",
                      isSelected: _selectedTheme == GameTheme.sports,
                      onTap: () => setState(() => _selectedTheme = GameTheme.sports),
                    ),
                    const SizedBox(width: 10),
                    _ThemeButton(
                      emoji: "🍎",
                      label: "Fruits",
                      isSelected: _selectedTheme == GameTheme.fruits,
                      onTap: () => setState(() => _selectedTheme = GameTheme.fruits),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Board Size Selection ──────────────────────────────────────
              _SectionLabel(label: "BOARD SIZE"),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SizeOptionButton(
                        label: "2 × 4",
                        subtitle: "Easy",
                        isSelected: _selectedSize == BoardSize.small,
                        onTap: () => setState(() => _selectedSize = BoardSize.small),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SizeOptionButton(
                        label: "4 × 4",
                        subtitle: "Classic",
                        isSelected: _selectedSize == BoardSize.large,
                        onTap: () => setState(() => _selectedSize = BoardSize.large),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Play Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      final pairCount = _selectedSize == BoardSize.small ? 4 : 8;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => Home(
                            pairCount: pairCount,
                            theme: _selectedTheme,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "PLAY",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _themePreviewImage(GameTheme theme) {
    switch (theme) {
      case GameTheme.halloween:
        return 'assets/halloween/pumpkin.png';
      case GameTheme.sports:
        return 'assets/sports/trophy.png';
      case GameTheme.fruits:
        return 'assets/fruits/strawberry.png';
    }
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.purpleAccent.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.purpleAccent : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.purpleAccent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.purpleAccent : Colors.white54,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeOptionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeOptionButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purpleAccent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purpleAccent : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.purpleAccent : Colors.white70,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.purpleAccent.withValues(alpha: 0.8)
                    : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
