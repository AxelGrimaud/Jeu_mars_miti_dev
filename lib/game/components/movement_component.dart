import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../entities/rover.dart';

class MovementComponent extends Component with ParentIsA<Rover> {
  final double maxSpeed = 10.0;      // Vitesse max en unités/seconde
  final double acceleration = 8.0;   // Accélération
  final double deceleration = 6.0;   // Décélération
  final double turnSpeed = 3.0;      // Vitesse de rotation en rad/s

  Vector2 _targetDirection = Vector2.zero();
  double _currentVelocity = 0.0;
  double _turnDirection = 0.0;

  double get currentSpeed => _currentVelocity.abs();

  Vector2 get currentVelocityVector {
    if (_currentVelocity == 0) return Vector2.zero();
    final body = parent.body;
    final forward = body.worldVector(Vector2(0, -1));
    return forward * _currentVelocity;
  }

  void move(Vector2 direction) {
    _targetDirection = direction;
  }

  void turn(double direction) {
    _turnDirection = direction;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final body = parent.body;
    final targetVelocity = _targetDirection.y * maxSpeed;

    // Interpolation douce vers la vitesse cible
    if (targetVelocity.abs() > _currentVelocity.abs() ||
        (targetVelocity > 0 && _currentVelocity < 0) ||
        (targetVelocity < 0 && _currentVelocity > 0)) {
      // Accélération ou changement de direction
      if (targetVelocity > _currentVelocity) {
        _currentVelocity += acceleration * dt;
        if (_currentVelocity > targetVelocity) _currentVelocity = targetVelocity;
      } else {
        _currentVelocity -= acceleration * dt;
        if (_currentVelocity < targetVelocity) _currentVelocity = targetVelocity;
      }
    } else {
      // Décélération
      if (_currentVelocity > targetVelocity) {
        _currentVelocity -= deceleration * dt;
        if (_currentVelocity < targetVelocity) _currentVelocity = targetVelocity;
      } else if (_currentVelocity < targetVelocity) {
        _currentVelocity += deceleration * dt;
        if (_currentVelocity > targetVelocity) _currentVelocity = targetVelocity;
      }
    }

    // Appliquer le mouvement
    if (_currentVelocity.abs() > 0.01) {
      final forward = body.worldVector(Vector2(0, -1));
      final displacement = forward * _currentVelocity * dt;
      final newPosition = body.position + displacement;
      body.setTransform(newPosition, body.angle);
    } else {
      _currentVelocity = 0;
    }

    // Appliquer la rotation
    if (_turnDirection != 0) {
      final newAngle = body.angle + _turnDirection * turnSpeed * dt;
      body.setTransform(body.position, newAngle);
    }

    // Réinitialiser les vélocités physiques
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
  }
}