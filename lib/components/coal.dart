import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../santa_game.dart';
import 'santa_player.dart';

class Coal extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SantaGame> {
  Coal({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2.all(50),
        anchor: Anchor.center,
        priority: 4,
      );

  final double fallSpeed = 210;
  bool hitProcessed = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await Sprite.load('coal.png');

    add(CircleHitbox(radius: 16, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += fallSpeed * dt;

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

    if (hitProcessed) return;

    if (other is SantaPlayer) {
      hitProcessed = true;
      game.hitCoal(this);
    }
  }
}
