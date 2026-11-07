import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:santa_gift_rush/components/coal.dart';
import 'package:santa_gift_rush/components/gift.dart';
import 'package:santa_gift_rush/components/santa_player.dart';

class SantaGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  static const double gameWidth = 960;
  static const double gameHeight = 540;

  final Random random = Random();

  double _spawnAccumulator = 0;
  final double _spawnInterval = 0.9;

  late SantaPlayer santa;

  late TextComponent scoreText;
  int score = 0;

  late TextComponent livesText;
  TextComponent? gameOverText;

  int lives = 3;
  bool isGameOver = false;

  SantaGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      );

  @override
  Color backgroundColor() {
    // Fondo base azul medianoche.
    // Esto se verá incluso antes de dibujar la imagen de fondo.
    return const Color(0xFF0B1B3B);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Queremos trabajar con (0, 0) en la esquina superior izquierda.
    camera.viewfinder.anchor = Anchor.topLeft;

    final background = SpriteComponent(
      sprite: await loadSprite('background.png'),
      position: Vector2.zero(),
      size: Vector2(gameWidth, gameHeight),
      anchor: Anchor.topLeft,
      priority: 0,
    );

    world.add(background);

    santa = SantaPlayer(startPosition: Vector2(gameWidth / 2, gameHeight / 2));
    world.add(santa);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 20),
      priority: 20,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(scoreText);

    livesText = TextComponent(
      text: 'Lives: 3',
      position: Vector2(20, 58),
      priority: 20,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(livesText);
  }

  void collectGift(Gift gift) {
    gift.removeFromParent();

    score += 10;
    scoreText.text = 'Score: $score';
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    santa.setMovement(_directionFromKeyboard(keysPressed));
    return KeyEventResult.handled;
  }

  Vector2 _directionFromKeyboard(Set<LogicalKeyboardKey> keysPressed) {
    final direction = Vector2.zero();

    final left =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final right =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    final up =
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);
    final down =
        keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS);

    if (left) direction.x = -1;
    if (right) direction.x = 1;
    if (up) direction.y = -1;
    if (down) direction.y = 1;

    return direction;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return; //ADD

    _spawnAccumulator += dt;

    if (_spawnAccumulator >= _spawnInterval) {
      _spawnAccumulator = 0;
      spawnObject(); //CHANGE NAME FUNCTION
    }
  }

  void spawnObject() {
    //SE CAMBIA spawnGift
    final x = 30 + random.nextDouble() * (gameWidth - 60);

    final isGift = random.nextDouble() < 0.75;

    if (isGift) {
      world.add(Gift(startPosition: Vector2(x, -30)));
    } else {
      world.add(Coal(startPosition: Vector2(x, -30)));
    }
  }

  void hitCoal(Coal coal) {
    coal.removeFromParent();

    lives -= 1;
    livesText.text = 'Lives: $lives';

    if (lives <= 0) {
      triggerGameOver();
    }
  }

  void triggerGameOver() {
    isGameOver = true;
    santa.setMovement(Vector2.zero());

    gameOverText = TextComponent(
      text: 'GAME OVER',
      position: Vector2(gameWidth / 2, gameHeight / 2),
      anchor: Anchor.center,
      priority: 30,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(gameOverText!);
  }
}
