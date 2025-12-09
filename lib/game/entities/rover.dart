import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../components/movement_component.dart';
import '../components/fuel_component.dart';
import '../components/lidar_component.dart';
import '../components/rover_visual_component.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/rover_state.dart';

class Rover extends BodyComponent with KeyboardHandler {
  final WidgetRef ref;

  Rover(this.ref, {Vector2? position}) : super(priority: 1, renderBody: false) {
    initialPosition = position ?? Vector2.zero();
  }

  late Vector2 initialPosition;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final movement = firstChild<MovementComponent>();
    if (movement == null) return false;

    // Mouvement avant/arrière
    final isMovingForward =
        keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.keyZ);
    final isMovingBackward = keysPressed.contains(LogicalKeyboardKey.keyS);

    if (isMovingForward && !isMovingBackward) {
      movement.move(Vector2(0, 1));
    } else if (isMovingBackward && !isMovingForward) {
      movement.move(Vector2(0, -1));
    } else {
      movement.move(Vector2.zero());
    }

    // Rotation gauche/droite
    final isTurningLeft =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.keyQ);
    final isTurningRight = keysPressed.contains(LogicalKeyboardKey.keyD);

    if (isTurningLeft && !isTurningRight) {
      movement.turn(-1);
    } else if (isTurningRight && !isTurningLeft) {
      movement.turn(1);
    } else {
      movement.turn(0);
    }

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isMounted) {
      final movementComp = firstChild<MovementComponent>();
      final fuelComp = firstChild<FuelComponent>();
      final lidarComp = firstChild<LidarComponent>();

      final speed = movementComp?.currentSpeed ?? 0.0;

      // Mise à jour de l'état Riverpod (différée pour éviter les erreurs)
      Future(() {
        if (!isMounted) return;
        ref
            .read(roverProvider.notifier)
            .updateData(
              speed: speed,
              fuel: fuelComp?.fuel ?? 0.0,
              lidarDistances: lidarComp?.lastDistances ?? [],
            );
      });
    }
  }

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(2, 2);
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5
      ..restitution = 0.1;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = initialPosition
      ..linearDamping = 1.0
      ..angularDamping = 1.0;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ajouter les composants
    add(RoverVisualComponent());
    add(MovementComponent());
    add(FuelComponent());
    add(LidarComponent());
  }
}