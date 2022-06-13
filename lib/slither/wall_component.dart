import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

class Wall extends PositionComponent {
  Wall(this.position, this.size) : super(priority: 3);

  @override
  final NotifyingVector2 position;
  @override
  final NotifyingVector2 size;

  final Random rng = Random();
  late final Image _image;

  late final _renderPosition = -size.toOffset() / 2;
  late final _scaledRect = (size * scale.x).toRect();
  late final _renderRect = _renderPosition & size.toSize();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = position;
    size = size;
    scale = Vector2(10.0, 10.0);
    // paint.color = ColorExtension.fromRGBHexString('#14F596');

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final drawSize = _scaledRect.size.toVector2();
    final center = (drawSize / 2).toOffset();
    const step = 1.0;

    canvas.drawRect(
      Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y),
      BasicPalette.black.paint(),
    );

    for (var x = 0; x < 30; x++) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y),
        Paint()
          ..color = BasicPalette.blue.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = step,
      );

      drawSize.x -= step;
      drawSize.y -= step;
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(
      _scaledRect.width.toInt(),
      _scaledRect.height.toInt(),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(
      _image,
      _scaledRect,
      _renderRect,
      Paint()
        ..color = BasicPalette.blue.color
        ..style = PaintingStyle.stroke,
    );
  }

  late Rect asRect = Rect.fromCenter(
    center: position.toOffset(),
    width: size.x,
    height: size.y,
  );
}
