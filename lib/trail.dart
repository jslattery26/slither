import 'dart:ui';

import 'package:flame/components.dart';

// ignore: unused_import
import 'car.dart';
// ignore: unused_import
import 'head.dart';
import 'tire.dart';

class Trail extends Component with HasPaint {
  Trail({
    required this.tire,
  }) : super(priority: 1);

  final Tire tire;

  final trail = <Offset>[];
  final double _trailLength = 20;
  double savedt = 0;

  @override
  Future<void> onLoad() async {
    paint
      ..color = (tire.paint.color.withOpacity(0.9))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
  }

  @override
  void update(double dt) {
    savedt += dt;
    if (savedt > .02) {
      // _trailLength = car.chomps;
      if (trail.length > _trailLength) {
        trail.removeAt(0);
      }
      final trailPoint = tire.body.position.toOffset();
      trail.add(trailPoint);
      savedt = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPoints(PointMode.polygon, trail, paint);
  }
}
