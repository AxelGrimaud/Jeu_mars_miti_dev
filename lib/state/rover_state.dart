import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoverData {
  final double speed;
  final double fuel;
  final double battery;
  final List<double> lidarDistances;

  RoverData({
    this.speed = 0.0,
    this.fuel = 100.0,
    this.battery = 100.0,
    this.lidarDistances = const [],
  });

  RoverData copyWith({
    double? speed,
    double? fuel,
    double? battery,
    List<double>? lidarDistances,
  }) {
    return RoverData(
      speed: speed ?? this.speed,
      fuel: fuel ?? this.fuel,
      battery: battery ?? this.battery,
      lidarDistances: lidarDistances ?? this.lidarDistances,
    );
  }
}

class RoverNotifier extends Notifier<RoverData> {
  @override
  RoverData build() {
    return RoverData();
  }

  void updateData({double? speed, double? fuel, List<double>? lidarDistances}) {
    state = state.copyWith(
      speed: speed,
      fuel: fuel,
      lidarDistances: lidarDistances,
    );
  }
}

final roverProvider = NotifierProvider<RoverNotifier, RoverData>(
  RoverNotifier.new,
);