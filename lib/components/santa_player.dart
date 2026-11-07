import 'dart:async';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class SantaPlayer extends SpriteComponent with CollisionCallbacks {
  SantaPlayer({required Vector2 startPosition})
    : _basePosition = startPosition.clone(),
      super(
        position: startPosition,
        size: Vector2(100, 80),
        anchor: Anchor.center,
        priority: 5,
      );

  Vector2 _basePosition;

  double _floatTime = 0;
  final double _floatAmplitude = 6;
  final double _floatFrequency = 3;

  Vector2 movementInput = Vector2.zero();

  final double speed = 260;

  void setMovement(Vector2 input) {
    movementInput = input;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('santa.png');

    add(RectangleHitbox(position: Vector2(24, 24), size: Vector2(92, 68)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = movementInput.length > 0
        ? movementInput.normalized()
        : Vector2.zero();

    _basePosition += direction * speed * dt;

    // Efecto visual de flotación.
    _floatTime += dt;
    final floatOffset =
        math.sin(_floatTime * _floatFrequency * math.pi) * _floatAmplitude;

    // Posición final = posición base + flotación visual.
    position = Vector2(_basePosition.x, _basePosition.y + floatOffset);

    if (direction.x < 0) {
      scale.x = -1;
    } else if (direction.x > 0) {
      scale.x = 1;
    }
  }
}
