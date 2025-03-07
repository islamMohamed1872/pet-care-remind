import 'dart:math';
import 'package:flutter/material.dart';

void showBubblesAnimation(BuildContext context) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => BubbleAnimationWidget(overlayEntry: overlayEntry),
  );

  Overlay.of(context).insert(overlayEntry);
}

class BubbleAnimationWidget extends StatefulWidget {
  final OverlayEntry overlayEntry;
  const BubbleAnimationWidget({Key? key, required this.overlayEntry})
      : super(key: key);

  @override
  _BubbleAnimationWidgetState createState() => _BubbleAnimationWidgetState();
}

class _BubbleAnimationWidgetState extends State<BubbleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> bubbles = [];
  final Random random = Random();
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {});
    });

    _controller.forward().whenComplete(() {
      widget.overlayEntry.remove();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    _generateBubbles();
  }

  void _generateBubbles() {
    bubbles.clear();
    for (int i = 0; i < 10; i++) {
      bubbles.add(
        Bubble(
          left: random.nextDouble() * screenWidth, // Random horizontal position
          startBottom: random.nextDouble() * screenHeight * 0.2, // Random start height at bottom
          size: random.nextDouble() * 30 + 20, // Random bubble size
          animation: Tween<double>(begin: 0, end: random.nextDouble() * 0.5 + 0.5) // Different heights
              .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: bubbles.map((bubble) {
          return Positioned(
            left: bubble.left,
            bottom: bubble.startBottom + (screenHeight * bubble.animation.value), // Start at different heights
            child: Opacity(
              opacity: 1 - bubble.animation.value,
              child: Container(
                width: bubble.size,
                height: bubble.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.4),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Bubble {
  final double left;
  final double startBottom;
  final double size;
  final Animation<double> animation;

  Bubble({required this.left, required this.startBottom, required this.size, required this.animation});
}
