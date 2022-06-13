import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

class DotsComponent extends Component {
  DotsComponent(this.shapes, this.shapeColors)
      : assert(
          shapes.length == shapeColors.length,
          'The shapes and shapeColors lists have to be of the same length',
        );

  final List<Shape> shapes;
  final List<Color> shapeColors;

  final Random random = Random();
  final List<Vector2> points = [];
  final List<Color> pointColors = [];
  static const pointSize = 3;

  @override
  void update(double dt) {
    if (points.length < 200) {
      generatePoint();
    }
  }

  void generatePoint() {
    final point = Vector2(
      random.nextDouble() * 800,
      random.nextDouble() * 600,
    );
    points.add(point);
    pointColors.add(const Color(0xff444444));
    for (var i = 0; i < shapes.length; i++) {
      if (shapes[i].containsPoint(point)) {
        pointColors.last = shapeColors[i];
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    const d = pointSize / 2;
    final paint = Paint();
    for (var i = 0; i < points.length; i++) {
      final x = points[i].x;
      final y = points[i].y;
      paint.color = pointColors[i];
      canvas.drawRect(Rect.fromLTRB(x - d, y - d, x + d, y + d), paint);
    }
  }
}
