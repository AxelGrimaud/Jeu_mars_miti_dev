import 'package:flame/components.dart';

class FuelComponent extends Component {
  double fuel = 100.0;
  final double consumptionRate = 5.0; // Unités par seconde en mouvement

  bool get hasFuel => fuel > 0;

  void consume(double dt) {
    if (fuel > 0) {
      fuel -= consumptionRate * dt;
      if (fuel < 0) fuel = 0;
    }
  }

  void refuel(double amount) {
    fuel += amount;
    if (fuel > 100) fuel = 100;
  }
}