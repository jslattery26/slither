// import 'dart:ui';

// import 'package:flame/components.dart';
// import 'package:flame/experimental.dart';
// import 'package:flutter/material.dart' hide Image, Gradient;
// import 'package:flutter/services.dart';

// import 'game_colors.dart';
// import 'padracing_game.dart';
// import 'trail.dart';

// class Head extends ShapeComponent with HasGameRef<PadRacingGame> {
//   Head({required this.cameraComponent})
//       : super(
//           priority: 3,
//           paint: Paint()..color = GameColors.blue.color,
//         );

//   final CameraComponent cameraComponent;
//   // final size = const Size(5, 5);
//   // final scale = 10.0;
//   double chomps = 20;
//   int speed = 25;
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     gameRef.cameraWorld.add(Trail(car: this));
//   }

//   @override
//   void update(double dt) {
//     if (gameRef.pressedKeySets[0].contains(LogicalKeyboardKey.keyQ)) {
//       chomps += 5;
//       gameRef.pressedKeySets[0].remove(LogicalKeyboardKey.keyQ);
//     }
//     if (gameRef.pressedKeySets[0].contains(LogicalKeyboardKey.space)) {
//       speed = 50;
//     } else {
//       speed = 25;
//     }

//     _goForward(dt);
//     _updateTurn(dt);
//   }

//   void _goForward(double dt) {
//     position = Vector2(position.x + 1, position.y + 1) * 25 * dt;
//   }

//   void _updateTurn(double dt) {
//     if (gameRef.pressedKeySets[0].contains(LogicalKeyboardKey.arrowRight)) {
//       // position.rotate();
//       transform.position.rotate(2 * dt);
//     }
//     if (gameRef.pressedKeySets[0].contains(LogicalKeyboardKey.arrowLeft)) {
//       position.rotate(-2 * dt);
//     }
//   }

//   @override
//   void render(Canvas canvas) {
//     final bodyPaint = Paint()..color = paint.color;
//     final path = Path();
//     path.addOval(Rect.fromCircle(center: const Offset(0, 0), radius: 2));
//     canvas.drawPath(path, bodyPaint);
//     super.render(canvas);
//   }

//   @override
//   void onRemove() {}
// }
