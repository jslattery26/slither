import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' as forge;
import 'dots_component.dart';
import 'player_component.dart';
import 'wall_component.dart';

class Slither extends forge.Forge2DGame
    with HasKeyboardHandlerComponents, MouseMovementDetector {
  final shapes = [
    Circle(Vector2(50, 30), 20),
    Circle(Vector2(700, 500), 50),
    Rectangle.fromLTRB(100, 30, 260, 100),
    RoundedRectangle.fromLTRBR(40, 300, 120, 550, 30),
    Polygon([Vector2(10, 70), Vector2(180, 200), Vector2(220, 150)]),
    Polygon([
      Vector2(400, 160),
      Vector2(550, 400),
      Vector2(710, 350),
      Vector2(540, 170),
      Vector2(710, 100),
      Vector2(710, 320),
      Vector2(730, 315),
      Vector2(750, 60),
      Vector2(590, 30),
    ]),
  ];
  final colors = [
    const Color(0xFFFFFF88),
    const Color(0xFFff88FF),
    const Color(0xFF88FFFF),
    const Color(0xFF88FF88),
    const Color(0xFFaaaaFF),
    const Color(0xFFFF8888),
  ];

  final redPoints = List<Vector2>.empty(growable: true);
  Box? nearestBox;

  Vector2 viewportSize = Vector2(0, 0);

  Vector2? mouse;
  @override
  late final forge.World world;
  late CameraComponent cameraComponent;

  @override
  void onMouseMove(PointerHoverInfo info) {
    mouse = info.eventPosition.game;

    final rayStart = screenToWorld(
      camera.viewport.effectiveSize / 2 -
          Vector2(camera.viewport.effectiveSize.x / 4, 0),
    );

    final redRayTarget = info.eventPosition.game + Vector2(0, 2);
    fireRedRay(rayStart, redRayTarget);

    super.onMouseMove(info);
  }

  void fireRedRay(Vector2 rayStart, Vector2 rayTarget) {
    redPoints.clear();
    redPoints.add(worldToScreen(rayStart));

    final nearestCallback = NearestBoxRayCastCallback();
    world.raycast(nearestCallback, rayStart, rayTarget);

    if (nearestCallback.nearestPoint != null) {
      redPoints.add(worldToScreen(nearestCallback.nearestPoint!));
    } else {
      redPoints.add(worldToScreen(rayTarget));
    }
    nearestBox = nearestCallback.box;
  }

  RectangleComponent viewportRimGenerator() =>
      RectangleComponent(size: viewportSize, anchor: Anchor.topLeft)
        ..paint.color = BasicPalette.blue.color
        ..paint.strokeWidth = 2.0
        ..paint.style = PaintingStyle.stroke;

  @override
  @override
  Future<void> onLoad() async {
    viewportSize = Vector2(canvasSize.x, canvasSize.y);
    world = forge.World()..addToParent(this);
    final player = Player()
      ..position = Vector2(canvasSize.x / 2, canvasSize.x / 2);
    cameraComponent = CameraComponent(
      viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
        ..position = Vector2(0, 0)
        ..add(viewportRimGenerator()),
      world: world,
    )
      ..viewfinder.zoom = 2
      ..viewfinder.anchor = Anchor.center
      ..follow(player);

    add(cameraComponent);
    world.add(player);
    // world.addAll(createWalls(Vector2(500, 500)));
    world.add(DotsComponent(shapes, colors));
  }

  List<Wall> createWalls(Vector2 size) {
    final topCenter = NotifyingVector2(size.x / 2, 0);
    final bottomCenter = NotifyingVector2(size.x / 2, size.y);
    final leftCenter = NotifyingVector2(0, size.y / 2);
    final rightCenter = NotifyingVector2(size.x, size.y / 2);

    final filledSize = size.clone() + Vector2.all(5);
    return [
      Wall(topCenter, NotifyingVector2(filledSize.x, 5)),
      Wall(leftCenter, NotifyingVector2(5, filledSize.y)),
      // Wall(Vector2(52.5, 240), Vector2(5, 380)),
      // Wall(Vector2(200, 50), Vector2(300, 5)),
      // Wall(Vector2(72.5, 300), Vector2(5, 400)),
      // Wall(Vector2(180, 100), Vector2(220, 5)),
      // Wall(Vector2(350, 105), Vector2(5, 115)),
      // Wall(Vector2(310, 160), Vector2(240, 5)),
      // Wall(Vector2(211.5, 400), Vector2(283, 5)),
      // Wall(Vector2(351, 312.5), Vector2(5, 180)),
      // Wall(Vector2(430, 302.5), Vector2(5, 290)),
      // Wall(Vector2(292.5, 450), Vector2(280, 5)),
      Wall(bottomCenter, NotifyingVector2(filledSize.y, 5)),
      Wall(rightCenter, NotifyingVector2(5, filledSize.y)),
    ];
  }
}

class Box extends forge.BodyComponent {
  final Vector2 position;

  Box(this.position);

  @override
  forge.Body createBody() {
    final shape = forge.PolygonShape()..setAsBoxXY(2.0, 4.0);
    final fixtureDef = forge.FixtureDef(shape, userData: this);
    final bodyDef = forge.BodyDef(position: position);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class NearestBoxRayCastCallback extends forge.RayCastCallback {
  Box? box;
  Vector2? nearestPoint;
  Vector2? normalAtInter;

  @override
  double reportFixture(
    forge.Fixture fixture,
    Vector2 point,
    Vector2 normal,
    double fraction,
  ) {
    nearestPoint = point.clone();
    normalAtInter = normal.clone();
    box = fixture.userData as Box?;

    // Returning fraction implies that we care only about
    // fixtures that are closer to ray start point than
    // the current fixture
    return fraction;
  }
}
