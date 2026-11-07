import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:santa_gift_rush/components/santa_player.dart';

import '../santa_game.dart';

class Gift extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SantaGame> {
  Gift({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2.all(52),
        anchor: Anchor.center,
        priority: 4,
      );

  // Velocidad vertical fija.
  final double fallSpeed = 190;

  bool collected = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await Sprite.load('gift.png');

    add(CircleHitbox(radius: 18, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Movimiento solo vertical.
    position.y += fallSpeed * dt;

    // Si sale por abajo, lo eliminamos.
    if (position.y > 540 + 60) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (collected) return;

    if (other is SantaPlayer) {
      collected = true;
      game.collectGift(this);
    }
  }
}
