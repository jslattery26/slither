import 'dart:collection';
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
          ..addOval(const Rect.fromLTWH(12, 4.5, 5, 5))
          ..addOval(const Rect.fromLTWH(12, 10.5, 5, 5)),
        pupils = Path()
          ..addOval(const Rect.fromLTWH(14, 6, 2, 2))
          ..addOval(const Rect.fromLTWH(14, 12, 2, 2)),
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
  Vector2 mouseFromCenter = Vector2(0, 0);
  Vector2 previousPosition = Vector2(0, 0);
  double mouseAngle = 0.0;
  double dif = 0.0;

  static const speed = 100.0;
  static const rotateSpeed = 10.0;
  bool onTarget = false;

  final _trailLength = 100;
  Queue<BodyPart> bodyTrail = Queue<BodyPart>();
  double chomps = 1;

  void moveForward() {
    velocity.x = speed * math.cos(angle);
    velocity.y = speed * math.sin(angle);
  }

  void rotateLeftConst() {
    if (mouseAngle < rotateSpeed) {
      angularVelocity = -mouseAngle;
    } else {
      angularVelocity = -rotateSpeed;
    }
  }

  void rotateRightConst() {
    if (mouseAngle > rotateSpeed) {
      angularVelocity = -mouseAngle;
    } else {
      angularVelocity = rotateSpeed;
    }
  }

  void stopTurning() {
    angularVelocity = 0;
  }

  @override
  void update(double dt) {
    moveForward();

    if (gameRef.mouse != null) {
      mouseFromCenter = gameRef.mouse! -
          Vector2(
            gameRef.canvasSize.x / 2,
            gameRef.canvasSize.y / 2,
          );
      mouseAngle = mouseFromCenter.angleToSigned(velocity) * (180 / math.pi);
      if (mouseAngle == 0) {
        stopTurning();
      } else if (mouseAngle < 0) {
        rotateRightConst();
      } else if (mouseAngle > 0) {
        rotateLeftConst();
      }
      //allow arrow keys to be used
      // if (this.cursors.left.isDown) {
      //   this.head.body.rotateLeft(this.rotationSpeed);
      // } else if (this.cursors.right.isDown) {
      //   this.head.body.rotateRight(this.rotationSpeed);
      // }
      //decide whether rotating left or right will angle the head towards
      //the mouse faster, if arrow keys are not used

      // if (dif < 0 && dif > -180 || dif > 180) {
      //   rotateLeft();
      // } else if (dif > 0 && dif < 180 || dif < -180) {
      //   rotateRight();
      // } else {
      //   print('not turning');
      //   stopTurning();
      // }
    }
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    angle += angularVelocity * dt;

    if (bodyTrail.length > _trailLength) {
      gameRef.world.remove(bodyTrail.last);
      bodyTrail.removeLast();
    }
    bodyTrail.addFirst(
      BodyPart()
        ..position.x = position.x - (1 * math.cos(angle))
        ..position.y = position.y - (1 * math.sin(angle))
        ..angle = angle,
    );
    gameRef.world.add(bodyTrail.first);
    // // final d = bodyTrail.length / 2;
    // for (var i = bodyTrail.length - 1; i >= 1; i--) {
    //   bodyTrail.elementAt(i).position.x = bodyTrail.elementAt(i - 1).x -
    //       (math.cos(bodyTrail.elementAt(i).angle));
    //   bodyTrail.elementAt(i).position.y = bodyTrail.elementAt(i - 1).y -
    //       (math.sin(bodyTrail.elementAt(i).angle));
    // }
    // for (var i = 0; i < bodyTrail.length; i++) {
    //   bodyTrail.elementAt(i).position.x =
    //       position.x - (5 * i * math.cos(angle));
    //   bodyTrail.elementAt(i).position.y =
    //       position.y - (5 * i * math.sin(angle));
    //   if (bodyTrail.elementAt(i).parent == null) {
    //     gameRef.world.add(
    //       bodyTrail.elementAt(i),
    //     );
    //   }
    // }
  }

  double invertAngle(double angle) {
    return (angle + math.pi) % (2 * math.pi);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(body, innerPaint);
    canvas.drawPath(body, innerPaint);
    canvas.drawPath(body, borderPaint);

    canvas.drawPath(eyes, eyesPaint);
    canvas.drawPath(pupils, pupilsPaint);

    // bodyTrail.forEach((element) {
    //   element.addToParent(this);
    // });
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
    final keySpace = event.logicalKey == LogicalKeyboardKey.space;

    if (isKeyDown) {
      if (keySpace) {
        chomps += 1;
        print(chomps);
      }
      if (keyLeft) {
        // velocity.x = -runSpeed;
        rotateLeftConst();
      } else if (keyRight) {
        rotateRightConst();
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
    return super.onKeyEvent(event, keysPressed);
  }
}

class BodyPart extends PositionComponent {
  BodyPart()
      : body = Path()..addOval(const Rect.fromLTWH(0, 0, 20, 20)),
        super(size: Vector2(20, 20), anchor: Anchor.center);
  final Path body;
  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0xffffc67c);
  final Paint innerPaint = Paint()..color = const Color(0xff9c0051);

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    canvas.drawPath(body, innerPaint);
    canvas.drawPath(body, borderPaint);
  }
}
