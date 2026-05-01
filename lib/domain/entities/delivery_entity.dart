import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final double? bearing;
  final double? speed;
  final DateTime timestamp;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.bearing,
    this.speed,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, bearing, speed, timestamp];
}

class CourierEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final String phoneNumber;

  const CourierEntity({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, name, role, avatarUrl, phoneNumber];
}

enum DeliveryStatus { pending, inTransit, onDelivery, delivered }

class DeliveryEntity extends Equatable {
  final String orderId;
  final CourierEntity courier;
  final LocationEntity courierLocation;
  final LocationEntity destination;
  final DeliveryStatus status;
  final int etaMinutes;
  final DateTime? deliveryTime;
  final String destinationAddress;
  final List<LocationEntity> routePoints;

  const DeliveryEntity({
    required this.orderId,
    required this.courier,
    required this.courierLocation,
    required this.destination,
    required this.status,
    required this.etaMinutes,
    this.deliveryTime,
    required this.destinationAddress,
    required this.routePoints,
  });

  DeliveryEntity copyWith({
    String? orderId,
    CourierEntity? courier,
    LocationEntity? courierLocation,
    LocationEntity? destination,
    DeliveryStatus? status,
    int? etaMinutes,
    DateTime? deliveryTime,
    String? destinationAddress,
    List<LocationEntity>? routePoints,
  }) {
    return DeliveryEntity(
      orderId: orderId ?? this.orderId,
      courier: courier ?? this.courier,
      courierLocation: courierLocation ?? this.courierLocation,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    courier,
    courierLocation,
    destination,
    status,
    etaMinutes,
    deliveryTime,
    destinationAddress,
    routePoints,
  ];
}
