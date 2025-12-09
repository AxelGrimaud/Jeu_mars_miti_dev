enum DroneState { idle, patrol, alert, returnToBase }

class DroneStateMachine {
  DroneState _currentState = DroneState.idle;

  void update(double dt, dynamic sensors) {
    switch (_currentState) {
      case DroneState.idle:
        // Transition vers Patrol si batterie > 50%
        _currentState = DroneState.patrol;
        break;
      case DroneState.patrol:
        // Si obstacle détecté -> Alert
        // Si batterie < 20% -> ReturnToBase
        break;
      case DroneState.alert:
        // S'arrêter et attendre ou tourner
        break;
      case DroneState.returnToBase:
        // Se diriger vers (0,0)
        break;
    }
  }
}