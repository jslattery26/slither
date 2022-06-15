import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'dots_component.dart';
import 'player_component.dart';

class Slither extends FlameGame
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
  Vector2 viewportSize = Vector2(0, 0);
  Vector2 canvasCenter = Vector2(0, 0);
  Vector2? mouse;
  late final World world;
  late final Player player;
  late CameraComponent cameraComponent;

  @override
  void onMouseMove(PointerHoverInfo info) {
    mouse = info.eventPosition.game;
    super.onMouseMove(info);
  }

  RectangleComponent viewportRimGenerator() =>
      RectangleComponent(size: viewportSize, anchor: Anchor.topLeft)
        ..paint.color = BasicPalette.blue.color
        ..paint.strokeWidth = 2.0
        ..paint.style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    viewportSize = Vector2(canvasSize.x, canvasSize.y);
    canvasCenter = Vector2(canvasSize.x / 2, canvasSize.y / 2);
    world = World()..addToParent(this);
    player = Player()..position = canvasCenter;
    world.add(player);
    world.add(DotsComponent(shapes, colors));
    print(viewportSize);
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
  }

  @override
  void render(Canvas canvas) {
    if (mouse != null) {
      canvas.drawLine(
        canvasCenter.toOffset(),
        canvasCenter.toOffset() + player.mouseFromCenter.toOffset(),
        Paint()
          ..color = BasicPalette.green.color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        canvasCenter.toOffset(),
        canvasCenter.toOffset() + player.velocity.toOffset(),
        Paint()
          ..color = BasicPalette.red.color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      // canvas.drawPath(pupils, pupilsPaint);
    }
    super.render(canvas);
  }
}
