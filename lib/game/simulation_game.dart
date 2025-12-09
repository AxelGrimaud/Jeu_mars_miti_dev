import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';

import 'entities/rover.dart';
import 'components/movement_component.dart';
import 'components/scrolling_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimulationGame extends Forge2DGame
    with PanDetector, HasKeyboardHandlerComponents {
  final WidgetRef ref;
  late Rover rover;
  late ScrollingBackground scrollingBackground;

  SimulationGame(this.ref) : super(gravity: Vector2.zero(), zoom: 10);

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Si l'utilisateur fait glisser, on arrête de suivre le rover
    camera.stop();
    camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugMode = false;

    // Créer les murs de l'arène
    final boundaryParams = createBoundaries(this);
    boundaryParams.forEach(world.add);

    // Créer le fond défilant
    scrollingBackground = ScrollingBackground();
    camera.backdrop.add(scrollingBackground);

    // Créer le rover
    rover = Rover(ref, position: Vector2.zero());
    await world.add(rover);

    // La caméra suit le rover
    camera.follow(rover);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Mettre à jour le défilement du fond selon la vélocité du rover
    if (rover.isMounted) {
      final movementComp = rover.firstChild<MovementComponent>();
      if (movementComp != null) {
        scrollingBackground.updateVelocity(movementComp.currentVelocityVector);
      }
    }
  }

  List<BodyComponent> createBoundaries(Forge2DGame game) {
    final topLeft = Vector2(-20, -20);
    final bottomRight = Vector2(20, 20);
    final topRight = Vector2(20, -20);
    final bottomLeft = Vector2(-20, 20);

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomRight, bottomLeft),
      Wall(bottomLeft, topLeft),
    ];
  }
}

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end) : super(renderBody: false);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape)..friction = 0.3;
    final bodyDef = BodyDef()..position = Vector2.zero();

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}