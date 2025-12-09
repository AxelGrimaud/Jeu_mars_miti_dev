import 'dart:ui';
import 'package:flame/components.dart';

class ScrollingBackground extends PositionComponent with HasGameReference {
  late Sprite _backgroundSprite;
  Vector2 _offset = Vector2.zero();
  Vector2 _velocity = Vector2.zero();

  final double scrollMultiplier = 15.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _backgroundSprite = await game.loadSprite('mars_surface.png');
    priority = -10;
  }

  void updateVelocity(Vector2 velocity) {
    _velocity = velocity;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _offset += _velocity * scrollMultiplier * dt;

    if (_backgroundSprite.image.width > 0) {
      final spriteWidth = _backgroundSprite.image.width.toDouble();
      final spriteHeight = _backgroundSprite.image.height.toDouble();

      _offset.x = _offset.x % spriteWidth;
      _offset.y = _offset.y % spriteHeight;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final screenSize = game.size;
    final spriteWidth = _backgroundSprite.image.width.toDouble();
    final spriteHeight = _backgroundSprite.image.height.toDouble();

    if (spriteWidth <= 0 || spriteHeight <= 0) return;

    final tilesX = (screenSize.x / spriteWidth).ceil() + 2;
    final tilesY = (screenSize.y / spriteHeight).ceil() + 2;

    final startX = -spriteWidth + (_offset.x % spriteWidth);
    final startY = -spriteHeight + (_offset.y % spriteHeight);

    for (int x = 0; x < tilesX; x++) {
      for (int y = 0; y < tilesY; y++) {
        _backgroundSprite.render(
          canvas,
          position: Vector2(startX + x * spriteWidth, startY + y * spriteHeight),
          size: Vector2(spriteWidth, spriteHeight),
        );
      }
    }
  }
}