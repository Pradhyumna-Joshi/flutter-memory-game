import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_game/src/models/game.dart';

class MemoryCard extends StatelessWidget {
  final Game item;
  final bool isFlipped;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.item,
    required this.isFlipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnim,
            child: child,
            builder: (context, widget) {
              final isUnder = (ValueKey(isFlipped) != widget?.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0;
              final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: widget,
              );
            },
          );
        },
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        child: isFlipped ? _buildFront() : _buildBack(),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(item.imageURL, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey(false),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5), width: 2),
      ),
      child: const Center(
        child: Icon(
          Icons.question_mark_rounded,
          color: Colors.white60,
          size: 40,
        ),
      ),
    );
  }
}
