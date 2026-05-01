import 'package:shipa/domain/entities/delivery_entity.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final double? bearing;
  final double? speed;
  final DateTime timestamp;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.bearing,
    this.speed,
    required this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      bearing: json['bearing'] != null
          ? (json['bearing'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'bearing': bearing,
    'speed': speed,
    'timestamp': timestamp.toIso8601String(),
  };

  LocationEntity toEntity() => LocationEntity(
    latitude: latitude,
    longitude: longitude,
    bearing: bearing,
    speed: speed,
    timestamp: timestamp,
  );
}

class CourierModel {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final String phoneNumber;

  const CourierModel({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.phoneNumber,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) {
    return CourierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      phoneNumber: json['phone_number'] as String,
    );
  }

  CourierEntity toEntity() => CourierEntity(
    id: id,
    name: name,
    role: role,
    avatarUrl: avatarUrl,
    phoneNumber: phoneNumber,
  );
}

class DeliveryModel {
  final String orderId;
  final CourierModel courier;
  final LocationModel courierLocation;
  final LocationModel destination;
  final String status;
  final int etaMinutes;
  final DateTime? deliveryTime;
  final String destinationAddress;
  final List<LocationModel> routePoints;

  const DeliveryModel({
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

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      orderId: json['order_id'] as String,
      courier: CourierModel.fromJson(json['courier'] as Map<String, dynamic>),
      courierLocation: LocationModel.fromJson(
        json['courier_location'] as Map<String, dynamic>,
      ),
      destination: LocationModel.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      status: json['status'] as String,
      etaMinutes: json['eta_minutes'] as int,
      deliveryTime: json['delivery_time'] != null
          ? DateTime.parse(json['delivery_time'] as String)
          : null,
      destinationAddress: json['destination_address'] as String,
      routePoints: (json['route_points'] as List<dynamic>)
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DeliveryStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return DeliveryStatus.pending;
      case 'in_transit':
        return DeliveryStatus.inTransit;
      case 'on_delivery':
        return DeliveryStatus.onDelivery;
      case 'delivered':
        return DeliveryStatus.delivered;
      default:
        return DeliveryStatus.inTransit;
    }
  }

  DeliveryEntity toEntity() => DeliveryEntity(
    orderId: orderId,
    courier: courier.toEntity(),
    courierLocation: courierLocation.toEntity(),
    destination: destination.toEntity(),
    status: _parseStatus(status),
    etaMinutes: etaMinutes,
    deliveryTime: deliveryTime,
    destinationAddress: destinationAddress,
    routePoints: routePoints.map((p) => p.toEntity()).toList(),
  );
}
