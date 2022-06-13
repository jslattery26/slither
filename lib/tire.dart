import 'dart:math' as math;

import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';

import 'padracing_game.dart';
import 'trail.dart';

class Tire extends BodyComponent<PadRacingGame> {
  Tire({
    required this.pressedKeys,
    required this.cameraComponent,
    this.isTurnableTire = false,
  }) : super(
          paint: Paint()
            ..color = Colors.white
            ..strokeWidth = 0.2
            ..style = PaintingStyle.stroke,
          priority: 2,
        );

  static const double _backTireMaxDriveForce = 300.0;
  static const double _frontTireMaxDriveForce = 600.0;
  static const double _backTireMaxLateralImpulse = 8.5;
  static const double _frontTireMaxLateralImpulse = 7.5;

  final size = Vector2(0.5, 1.25);
  late final RRect _renderRect = RRect.fromLTRBR(
    -size.x,
    -size.y,
    size.x,
    size.y,
    const Radius.circular(0.3),
  );

  final Set<LogicalKeyboardKey> pressedKeys;
  final CameraComponent cameraComponent;
  late final double _maxDriveForce =
      isFrontTire ? _frontTireMaxDriveForce : _backTireMaxDriveForce;
  late final double _maxLateralImpulse =
      isFrontTire ? _frontTireMaxLateralImpulse : _backTireMaxLateralImpulse;

  // Make mutable if ice or something should be implemented
  final double _currentTraction = 1.0;
  final bool isTurnableTire;
  final bool isFrontTire = true;
  final bool isLeftTire = true;

  final double _lockAngle = 0.6;
  final double _turnSpeedPerSecond = 4;

  final Paint _black = BasicPalette.blue.paint();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameRef.cameraWorld.add(Trail(tire: this));
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(20, 30) + Vector2(15, 0);
    final body = world.createBody(def)..userData = this;

    final polygonShape = PolygonShape()..setAsBoxXY(0.5, 1.25);
    body.createFixtureFromShape(polygonShape, 1.0).userData = this;
    return body;
  }

  @override
  void update(double dt) {
    cameraComponent.viewfinder.position = body.position;
    if (body.isAwake || pressedKeys.isNotEmpty) {
      _updateTurn(dt);
      _updateFriction();
      if (!gameRef.isGameOver) {
        _moveForward();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_renderRect, _black);
    canvas.drawRRect(_renderRect, paint);
  }

  void _updateFriction() {
    final impulse = _lateralVelocity
      ..scale(-body.mass)
      ..clampScalar(-_maxLateralImpulse, _maxLateralImpulse)
      ..scale(_currentTraction);
    body.applyLinearImpulse(impulse);
    body.applyAngularImpulse(
      0.1 * _currentTraction * body.getInertia() * -body.angularVelocity,
    );

    final currentForwardNormal = _forwardVelocity;
    final currentForwardSpeed = currentForwardNormal.length;
    currentForwardNormal.normalize();
    final dragForceMagnitude = -2 * currentForwardSpeed;
    body.applyForce(
      currentForwardNormal..scale(_currentTraction * dragForceMagnitude),
    );
  }

  void _moveForward() {
    const desiredSpeed = 25;
    final currentForwardNormal = body.worldVector(Vector2(0.0, 1.0));
    final currentSpeed = _forwardVelocity.dot(currentForwardNormal);
    var force = 0.0;
    if (desiredSpeed < currentSpeed) {
      force = -_maxDriveForce;
    } else if (desiredSpeed > currentSpeed) {
      force = _maxDriveForce;
    }

    if (force.abs() > 0) {
      body.applyForce(currentForwardNormal..scale(_currentTraction * force));
    }
  }

  void _updateTurn(double dt) {
    if (gameRef.playerMouse != null) {
      //   getAngle(p1, p2){
      // var d1 = this.getDistance(p1, new Point(0, canvas.height));
      // var d2 = this.getDistance(p2, new Point(0, canvas.height));
      //     return ((Math.atan2(p2.y - p1.y, p2.x - p1.x)));
      final badmouse = gameRef.playerMouse!.eventPosition.game;
      final angleWeWant = math.atan2(
        badmouse.y - body.position.y,
        badmouse.x - body.position.x,
      );
      // badmouse.sub(gameRef.canvasSize / 2);

      print(angleWeWant);
      print(angleWeWant * 100 * dt);
      // var desiredTorque = 0.0;
      // if (pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      //   desiredTorque = -15.0;
      // }
      // if (pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      //   desiredTorque += 15.0;
      // }

      body.applyTorque(angleWeWant * 100 * dt);
    }
  }

  // Cached Vectors to reduce unnecessary object creation.
  final Vector2 _worldLeft = Vector2(1.0, 0.0);
  final Vector2 _worldUp = Vector2(0.0, -1.0);

  Vector2 get _lateralVelocity {
    final currentRightNormal = body.worldVector(_worldLeft);
    return currentRightNormal
      ..scale(currentRightNormal.dot(body.linearVelocity));
  }

  Vector2 get _forwardVelocity {
    final currentForwardNormal = body.worldVector(_worldUp);
    return currentForwardNormal
      ..scale(currentForwardNormal.dot(body.linearVelocity));
  }
}
