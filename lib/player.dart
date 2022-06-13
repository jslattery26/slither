import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'padracing_game.dart';

// This component class represents the player character in game.
class Player extends Component
    with CollisionCallbacks, HasGameRef<PadRacingGame> {}
