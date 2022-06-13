import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'slither.dart';

class Player extends PositionComponent
    with KeyboardHandler, HasGameRef<Slither> {
  Player()
      : body = Path()..addOval(const Rect.fromLTWH(0, 0, 20, 20)),
        eyes = Path()
          ..addOval(const Rect.fromLTWH(4.5, 12, 5, 5))
          ..addOval(const Rect.fromLTWH(10.5, 12, 5, 5)),
        pupils = Path()
          ..addOval(const Rect.fromLTWH(6, 14, 2, 2))
          ..addOval(const Rect.fromLTWH(12, 14, 2, 2)),
        velocity = Vector2.zero(),
        super(size: Vector2(20, 20), anchor: Anchor.center);
  final Path body;
  final Path eyes;
  final Path pupils;
  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0xffffc67c);
  final Paint innerPaint = Paint()..color = const Color(0xff9c0051);
  final Paint eyesPaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint pupilsPaint = Paint()..color = const Color(0xFF000000);
  final Paint shadowPaint = Paint()
    ..shader = Gradient.radial(
      Offset.zero,
      10,
      [const Color(0x88000000), const Color(0x00000000)],
    );

  final Vector2 velocity;
  double angularVelocity = 0;

  final double runSpeed = 150.0;
  final double jumpSpeed = 300.0;
  final double gravity = 1000.0;
  bool facingRight = true;
  int nJumpsLeft = 2;
  Vector2 direction = Vector2(0, 0);
  static const speed = 50.0;
  static const rotateSpeed = 10.0;
  bool onTarget = false;

  void moveForward() {
    // final magnitude = this.world.pxmi(-speed);
    final num currentAngle = angle + (math.pi / 2);

    velocity.x = speed * math.cos(currentAngle);
    velocity.y = speed * math.sin(currentAngle);
  }

  void rotateLeft() {
    angularVelocity = -rotateSpeed;
  }

  void rotateRight() {
    angularVelocity = rotateSpeed;
  }

  void stopTurning() {
    angularVelocity = 0;
  }

  @override
  void update(double dt) {
    moveForward();
    // if (gameRef.mouse != null) {
    //   onTarget = toRect().contains(gameRef.mouse!.toOffset());

    //   if (!onTarget) {
    //     direction = (gameRef.mouse! - position).normalized();
    //     position += direction * (speed * dt);
    //   } else {
    //     print('player$position');
    //   }
    // }
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
    angle += angularVelocity * dt;

    // if (position.y > 0) {
    //   position.y = 0;
    //   velocity.y = 0;
    //   nJumpsLeft = 2;
    // }
    // if (position.y < 0) {
    //   velocity.y += gravity * dt;
    // }
    // if (position.x < 0) {
    //   position.x = 0;
    // }
    // if (position.x > 1000) {
    //   position.x = 1000;
    // }
  }

  @override
  void render(Canvas canvas) {
    {
      final h = -position.y; // height above the ground
      canvas.save();
      canvas.translate(width / 2, height + 1 + h * 1.05);
      canvas.scale(1 - h * 0.003, 0.3 - h * 0.001);
      canvas.drawCircle(Offset.zero, 10, shadowPaint);
      canvas.restore();
    }
    canvas.drawPath(body, innerPaint);
    canvas.drawPath(body, borderPaint);
    canvas.drawPath(eyes, eyesPaint);
    canvas.drawPath(pupils, pupilsPaint);
    var thing = Path();
    thing.canvas.drawPath(pupils, pupilsPaint);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;
    final keyLeft = (event.logicalKey == LogicalKeyboardKey.arrowLeft) ||
        (event.logicalKey == LogicalKeyboardKey.keyA);
    final keyRight = (event.logicalKey == LogicalKeyboardKey.arrowRight) ||
        (event.logicalKey == LogicalKeyboardKey.keyD);
    final keyUp = (event.logicalKey == LogicalKeyboardKey.arrowUp) ||
        (event.logicalKey == LogicalKeyboardKey.keyW);

    if (isKeyDown) {
      if (keyLeft) {
        // velocity.x = -runSpeed;
        rotateLeft();
      } else if (keyRight) {
        rotateRight();
        // velocity.x = runSpeed;
      }
    } else {
      final hasLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA);
      final hasRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD);
      if (hasLeft && hasRight) {
        // Leave the current speed unchanged
      } else if (hasLeft) {
      } else if (hasRight) {
      } else {
        stopTurning();
      }
    }
    if ((velocity.x > 0) && !facingRight) {
      facingRight = true;
      flipHorizontally();
    }
    if ((velocity.x < 0) && facingRight) {
      facingRight = false;
      flipHorizontally();
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
