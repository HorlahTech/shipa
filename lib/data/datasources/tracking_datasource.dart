import 'dart:async';
import 'dart:math';

import 'package:shipa/data/models/delivery_model.dart';

abstract class TrackingDataSource {
  Stream<DeliveryModel> watchDelivery();
  Future<DeliveryModel> getDelivery();
  void dispose();
}

class SimulatedTrackingDataSource implements TrackingDataSource {
  StreamController<DeliveryModel>? _controller;
  Timer? _timer;
  int _routeIndex = 0;

  static final List<Map<String, double>> _routeCoordinates = [
    {'lat': 6.5085, 'lng': 3.3840},
    {'lat': 6.5120, 'lng': 3.3825},
    {'lat': 6.5160, 'lng': 3.3810},
    {'lat': 6.5195, 'lng': 3.3790},
    {'lat': 6.5230, 'lng': 3.3760},
    {'lat': 6.5265, 'lng': 3.3730},
    {'lat': 6.5300, 'lng': 3.3700},
    {'lat': 6.5325, 'lng': 3.3660},
    {'lat': 6.5350, 'lng': 3.3620},
    {'lat': 6.5380, 'lng': 3.3585},
    {'lat': 6.5420, 'lng': 3.3550},
    {'lat': 6.5460, 'lng': 3.3520},
    {'lat': 6.5500, 'lng': 3.3490},
    {'lat': 6.5550, 'lng': 3.3460},
    {'lat': 6.5600, 'lng': 3.3440},
    {'lat': 6.5650, 'lng': 3.3430},
    {'lat': 6.5700, 'lng': 3.3420},
    {'lat': 6.5800, 'lng': 3.3480},
    {'lat': 6.5900, 'lng': 3.3500},
    {'lat': 6.5950, 'lng': 3.3510},
    {'lat': 6.6018, 'lng': 3.3515},
  ];

  static DeliveryModel get _mockDelivery => DeliveryModel(
    orderId: 'ORD-682834513',
    courier: const CourierModel(
      id: 'courier_001',
      name: 'Presley Williams',
      role: 'Courier',
      avatarUrl: null,
      phoneNumber: '+2348012345678',
    ),
    courierLocation: LocationModel(
      latitude: _routeCoordinates[0]['lat']!,
      longitude: _routeCoordinates[0]['lng']!,
      bearing: 135.0,
      speed: 45.0,
      timestamp: DateTime.now(),
    ),
    destination: LocationModel(
      latitude: _routeCoordinates.last['lat']!,
      longitude: _routeCoordinates.last['lng']!,
      bearing: null,
      speed: null,
      timestamp: DateTime.now(),
    ),
    status: 'on_delivery',
    etaMinutes: 25,
    deliveryTime: null,
    destinationAddress: 'Akobo, Ibadan',
    routePoints: _routeCoordinates
        .map(
          (c) => LocationModel(
            latitude: c['lat']!,
            longitude: c['lng']!,
            bearing: null,
            speed: null,
            timestamp: DateTime.now(),
          ),
        )
        .toList(),
  );

  static Map<String, double> _interpolate(
    Map<String, double> from,
    Map<String, double> to,
    double t,
  ) {
    return {
      'lat': from['lat']! + (to['lat']! - from['lat']!) * t,
      'lng': from['lng']! + (to['lng']! - from['lng']!) * t,
    };
  }

  static double _calculateBearing(
    Map<String, double> from,
    Map<String, double> to,
  ) {
    final lat1 = from['lat']! * pi / 180;
    final lat2 = to['lat']! * pi / 180;
    final dLng = (to['lng']! - from['lng']!) * pi / 180;
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  @override
  Future<DeliveryModel> getDelivery() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDelivery;
  }

  @override
  Stream<DeliveryModel> watchDelivery() {
    _controller = StreamController<DeliveryModel>.broadcast();
    _routeIndex = 0;

    _controller!.add(_mockDelivery);

    final totalSegments =
        SimulatedTrackingDataSource._routeCoordinates.length - 1;
    const stepsPerSegment = 10;
    int step = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_controller == null || _controller!.isClosed) {
        timer.cancel();
        return;
      }

      final totalSteps = totalSegments * stepsPerSegment;
      if (step > totalSteps) {
        timer.cancel();
        return;
      }

      final segmentIndex = min(step ~/ stepsPerSegment, totalSegments - 1);
      final t = (step == totalSteps)
          ? 1.0
          : (step % stepsPerSegment) / stepsPerSegment;

      final from = _routeCoordinates[segmentIndex];
      final to = _routeCoordinates[min(segmentIndex + 1, totalSegments)];
      final interpolated = _interpolate(from, to, t);
      final bearing = _calculateBearing(from, to);

      final isLastStep = step == totalSteps;
      final remainingSteps = totalSteps - step;
      final etaMinutes = isLastStep
          ? 0
          : max(1, (remainingSteps * 1.5 / 60).ceil());

      final updated = DeliveryModel(
        orderId: _mockDelivery.orderId,
        courier: _mockDelivery.courier,
        courierLocation: LocationModel(
          latitude: interpolated['lat']!,
          longitude: interpolated['lng']!,
          bearing: bearing,
          speed: isLastStep ? 0.0 : 45.0,
          timestamp: DateTime.now(),
        ),
        destination: _mockDelivery.destination,
        status: isLastStep ? 'delivered' : 'on_delivery',
        etaMinutes: etaMinutes,
        deliveryTime: isLastStep ? DateTime.now() : null,
        destinationAddress: _mockDelivery.destinationAddress,
        routePoints: isLastStep
            ? [
                LocationModel(
                  latitude: interpolated['lat']!,
                  longitude: interpolated['lng']!,
                  bearing: null,
                  speed: null,
                  timestamp: DateTime.now(),
                ),
              ]
            : _routeCoordinates
                  .sublist(segmentIndex + 1)
                  .map(
                    (c) => LocationModel(
                      latitude: c['lat']!,
                      longitude: c['lng']!,
                      bearing: null,
                      speed: null,
                      timestamp: DateTime.now(),
                    ),
                  )
                  .toList(),
      );

      _controller!.add(updated);
      step++;
    });

    return _controller!.stream;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.close();
    _controller = null;
  }
}
