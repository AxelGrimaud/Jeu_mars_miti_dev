import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'dart:math';
import '../entities/rover.dart';

enum RoverDirection { n, ne, e, se, s, sw, w, nw }

class RoverVisualComponent extends SpriteAnimationGroupComponent<RoverDirection>
    with ParentIsA<Rover>, HasGameReference<Forge2DGame> {
  static const int rows = 8;
  static const int columns = 1;
  static const double stepTime = 0.1;

  RoverVisualComponent()
    : super(
        anchor: Anchor.center,
        size: Vector2(8, 8),
      );

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('frame_rover_sprite_sheet_2.png');
    final frameWidth = image.width / columns;
    final frameHeight = image.height / rows;
    final frameSize = Vector2(frameWidth, frameHeight);

    final directions = [
      RoverDirection.n,
      RoverDirection.ne,
      RoverDirection.e,
      RoverDirection.se,
      RoverDirection.s,
      RoverDirection.sw,
      RoverDirection.w,
      RoverDirection.nw,
    ];

    final animations = <RoverDirection, SpriteAnimation>{};

    for (int i = 0; i < directions.length; i++) {
      final y = i * frameHeight;
      final frames = List.generate(columns, (j) {
        return Sprite(
          image,
          srcPosition: Vector2(j * frameWidth, y),
          srcSize: frameSize,
        );
      });

      animations[directions[i]] = SpriteAnimation.spriteList(
        frames,
        stepTime: stepTime,
        loop: true,
      );
    }

    this.animations = animations;
    current = RoverDirection.n;
    size = Vector2(8, 8);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (parent.body.bodyType == BodyType.dynamic) {
      // Contre-rotation pour rester droit à l'écran
      angle = -parent.body.angle;

      // Déterminer la direction selon l'angle du corps
      double heading = parent.body.angle;
      final normalizedAngle = (heading % (2 * pi));
      final positiveAngle = normalizedAngle < 0
          ? normalizedAngle + 2 * pi
          : normalizedAngle;

      final sector = ((positiveAngle + pi / 8) / (pi / 4)).floor() % 8;

      switch (sector) {
        case 0: current = RoverDirection.n; break;
        case 1: current = RoverDirection.ne; break;
        case 2: current = RoverDirection.e; break;
        case 3: current = RoverDirection.se; break;
        case 4: current = RoverDirection.s; break;
        case 5: current = RoverDirection.sw; break;
        case 6: current = RoverDirection.w; break;
        case 7: current = RoverDirection.nw; break;
      }
    }
  }
}