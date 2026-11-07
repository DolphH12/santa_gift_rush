# Creando tu primer videojuego de Flutter
## By Dolph Hincapié | DolphWare

## **Objetivo:**
### **La misión:** crear desde cero un juego 2D donde **Dash disfrazado de Santa, montado en un trineo**, se mueve por la pantalla, recoge regalos que **caen verticalmente desde arriba** y evita trozos de carbón que también **caen desde arriba hacia abajo**. La estructura está pensada para la charla: **explicamos → copiamos → ejecutamos → vemos el cambio**.

---

## 🪜 SECCIÓN 1: Configurar el Proyecto

### Paso 1.1: Crear Proyecto Flutter

```bash
flutter create santa_gift_rush
cd santa_gift_rush
```

---

### Paso 1.2: Agregar dependencias en `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.38.2
```

---

### Paso 1.3: Agregar los assets

Dentro de tu proyecto crea la carpeta:

```
santa_gift_rush/
├── assets/
│   └── images/
│       ├── background.png
│       ├── santa.png
│       ├── gift.png
│       └── coal.png
└── lib/
    └── main.dart
```

### **Recursos gráficos que vamos a usar**

- `background.png`: fondo navideño del escenario.
- `santa.png`: Dash vestido de Santa, montado en trineo, PNG transparente.
- `gift.png`: regalo, PNG transparente.
- `coal.png`: carbón, PNG transparente.

Luego en el `pubspec.yaml`, debajo de `flutter:`, registra:

```yaml
flutter:
  assets:
    - assets/images/
```


## 🪜 SECCIÓN 2: Crear el Juego Principal

### Paso 2.1: Crear archivo **`lib/santa_game.dart`**

```dart
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class SantaGame extends FlameGame {
  // Tamaño lógico fijo del juego.
  // Nos ayuda a trabajar con coordenadas más fáciles de explicar.
  static const double gameWidth = 960;
  static const double gameHeight = 540;

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
  }
}

```

### Paso 2.2 **— Reemplazar `lib/main.dart`**

```jsx
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'santa_game.dart';

void main() {
  runApp(GameWidget(game: SantaGame()));
}
```


---

## 🪜 SECCIÓN 3: **Agregar el escenario navideño**

### Paso 3.1: En `lib/**santa_game**.dart`

```dart
@override
  Future<void> onLoad() async {
    await super.onLoad();

    //CODIGO IGUAL

    // Encima del color base dibujamos la imagen de fondo.
    final background = SpriteComponent(
      sprite: await loadSprite('background.png'),
      position: Vector2.zero(),
      size: Vector2(gameWidth, gameHeight),
      anchor: Anchor.topLeft,
      priority: 0,
    );

    world.add(background);
  }
```

✅ Hasta aquí ya tienes un juego vacío corriendo.

---


## **🛷 SECCIÓN 4: Agregar a Santa**

### **Paso 4.1 — Crear `lib/components/santa_player.dart`**

```dart
import 'dart:async';

import 'package:flame/components.dart';

class SantaPlayer extends SpriteComponent {
  SantaPlayer({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2(100, 80),
        anchor: Anchor.center,
        priority: 5,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('santa.png');
  }
}
```

En el **`lib/santa_game.dart`**

```dart
@override
  Future<void> onLoad() async {
    
    //CODIGO SIN CAMBIOS

    santa = SantaPlayer(startPosition: Vector2(gameWidth / 2, gameHeight / 2));
    world.add(santa);
  }
```

Agregamos flotación al personaje en **`lib/components/santa_player.dart`**

```dart
SantaPlayer({required Vector2 startPosition})
      : _basePosition = startPosition.clone(), //NUEVA LINEA
        super(
          position: startPosition,
          size: Vector2(140, 120),
          anchor: Anchor.center,
          priority: 5,
        );

// Posición real del personaje.
// La flotación solo se suma visualmente encima.
final Vector2 _basePosition;

// Variables para la animación de flotación.
double _floatTime = 0;
final double _floatAmplitude = 6;
final double _floatFrequency = 3;

@override
  void update(double dt) {
    super.update(dt);

    // Efecto visual de flotación.
    _floatTime += dt;
    final floatOffset = math.sin(_floatTime * _floatFrequency * math.pi) * _floatAmplitude;

    // Posición final = posición base + flotación visual.
    position = Vector2(_basePosition.x, _basePosition.y + floatOffset);

  }
```


## **⌨️ SECCIÓN 5: Movimiento del personaje**

### Paso 5.1: **Actualizar** **`lib/components/santa_player.dart`**

```dart
// Dirección actual que llega desde el teclado.
Vector2 movementInput = Vector2.zero();

// Velocidad del personaje.
final double speed = 260;

/// Actualiza la dirección según el teclado.
void setMovement(Vector2 input) {
  movementInput = input;
}

@override
void update(double dt) {
	super.update(dt);
	
	// Normalizamos la dirección para que la diagonal no sea más rápida.
	final direction = movementInput.length > 0
	    ? movementInput.normalized()
	    : Vector2.zero();
	
	_basePosition += direction * speed * dt;
	
	//CODIGO IGUAL
	
	// Solo giramos horizontalmente cuando cambia el movimiento horizontal.
	if (direction.x < 0) {
	  scale.x = -1;
	} else if (direction.x > 0) {
	  scale.x = 1;
	}
}
```

### Paso 5.2: **Actualizar** **`lib/santa_game.dart`**

```dart
class SantaGame extends FlameGame with KeyboardEvents { //ADD KEYBOARD

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

  final left = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
      keysPressed.contains(LogicalKeyboardKey.keyA);
  final right = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
      keysPressed.contains(LogicalKeyboardKey.keyD);
  final up = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
      keysPressed.contains(LogicalKeyboardKey.keyW);
  final down = keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
      keysPressed.contains(LogicalKeyboardKey.keyS);

  if (left) direction.x = -1;
  if (right) direction.x = 1;
  if (up) direction.y = -1;
  if (down) direction.y = 1;

  return direction;
}
```

---

## **🎁 SECCIÓN 6: Regalos cayendo verticalmente desde arriba**

### **Paso 6.1 — Crear `lib/components/gift.dart`**

```dart
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Regalo coleccionable.
///
/// Solo cae desde arriba hacia abajo.
class Gift extends SpriteComponent {
  Gift({required Vector2 startPosition})
      : super(
          position: startPosition,
          size: Vector2.all(52),
          anchor: Anchor.center,
          priority: 4,
        );

  // Velocidad vertical fija.
  final double fallSpeed = 190;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await Sprite.load('gift.png');
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
}
```

### **Paso 6.2 — Actualizar `lib/santa_game.dart`**

```dart
final Random random = Random();

double _spawnAccumulator = 0;
final double _spawnInterval = 0.9;

@override
void update(double dt) {
  super.update(dt);

  _spawnAccumulator += dt;

  if (_spawnAccumulator >= _spawnInterval) {
    _spawnAccumulator = 0;
    spawnGift();
  }
}

void spawnGift() {
  final x = 30 + random.nextDouble() * (gameWidth - 60);

  final gift = Gift(
    startPosition: Vector2(x, -30),
  );

  world.add(gift);
}
```

---


## **💥 SECCIÓN 7: Colisiones y puntuación**

### **Paso 7.1 — Actualizar `lib/components/gift.dart`**

```dart
class Gift extends SpriteComponent with CollisionCallbacks, HasGameReference<SantaGame><SantaGame> { //COLISIONES Y REFERENCIA AL JUEGO

bool collected = false;

@override
Future<void> onLoad() async {
  
  //MISMO CODIGO

  add(
    CircleHitbox(
      radius: 18,
      anchor: Anchor.center,
    ),
  );
}

@override
void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
  super.onCollisionStart(intersectionPoints, other);

  if (collected) return;

  if (other is SantaPlayer) {
    collected = true;
    game.collectGift(this);
  }
}
```

### **Paso 7.2 — Actualizar `lib/components/santa_player.dart`**

```dart
class SantaPlayer extends SpriteComponent with CollisionCallbacks {

@override
Future<void> onLoad() async {
  
  //MISMO CODIGO

  // Hitbox manual para ajustar mejor la colisión al trineo/personaje.
  add(
    RectangleHitbox(
      position: Vector2(24, 24),
      size: Vector2(92, 68),
    ),
  );
}
```

### **Paso 7.3 — Actualizar `lib/santa_game.dart`**

```dart
class SantaGame extends FlameGame with KeyboardEvents, HasCollisionDetection { //COLISIONES

late TextComponent scoreText;
int score = 0;

@override
Future<void> onLoad() async {
  
  //MISMO CODIGO

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
}

void collectGift(Gift gift) {
  gift.removeFromParent();

  score += 10;
  scoreText.text = 'Score: $score';
}
```

---

## **🪨 SECCIÓN 8 — Carbón, vidas y Game Over**

### **Paso 8.1 — Crear `lib/components/coal.dart`**

```dart
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../santa_game.dart';
import 'santa_player.dart';

class Coal extends SpriteComponent with CollisionCallbacks, HasGameReference<SantaGame> {
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

    add(
      CircleHitbox(
        radius: 16,
        anchor: Anchor.center,
      ),
    );
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
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (hitProcessed) return;

    if (other is SantaPlayer) {
      hitProcessed = true;
      game.hitCoal(this);
    }
  }
}
```

### **Paso 8.2 — Actualizar `lib/santa_game.dart`**

```dart
late TextComponent livesText;
TextComponent? gameOverText;

int lives = 3;
bool isGameOver = false;

@override
Future<void> onLoad() async {
  
  //MISMO CODIGO

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

void spawnObject() { //SE CAMBIA spawnGift
  final x = 30 + random.nextDouble() * (gameWidth - 60);

  final isGift = random.nextDouble() < 0.75;

  if (isGift) {
    world.add(
      Gift(
        startPosition: Vector2(x, -30),
      ),
    );
  } else {
    world.add(
      Coal(
        startPosition: Vector2(x, -30),
      ),
    );
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

```