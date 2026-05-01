import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shipa/core/constants/map_style.dart';

import 'package:shipa/core/theme/app_theme.dart';
import 'package:shipa/domain/entities/delivery_entity.dart';
import 'package:shipa/domain/usecases/tracking_usecases.dart';
import 'package:shipa/presentation/providers/tracking_providers.dart';

enum TrackingStatus { initial, loading, success, error }

class TrackingState {
  final TrackingStatus status;
  final DeliveryEntity? delivery;
  final String? errorMessage;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng? currentCameraPosition;
  final GoogleMapController? mapController;
  final bool isFollowing;

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.delivery,
    this.errorMessage,
    this.markers = const {},
    this.polylines = const {},
    this.currentCameraPosition,
    this.mapController,
    this.isFollowing = true,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    DeliveryEntity? delivery,
    String? errorMessage,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    LatLng? currentCameraPosition,
    GoogleMapController? mapController,
    bool? isFollowing,
  }) {
    return TrackingState(
      status: status ?? this.status,
      delivery: delivery ?? this.delivery,
      errorMessage: errorMessage ?? this.errorMessage,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      currentCameraPosition:
          currentCameraPosition ?? this.currentCameraPosition,
      mapController: mapController ?? this.mapController,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class TrackingViewModel extends StateNotifier<TrackingState> {
  final WatchDeliveryUseCase _watchDeliveryUseCase;
  final GetDeliveryUseCase _getDeliveryUseCase;

  StreamSubscription<DeliveryEntity>? _deliverySubscription;
  double _currentZoom = 13.0;
  bool _isProgrammaticMove = false;

  TrackingViewModel({
    required WatchDeliveryUseCase watchDeliveryUseCase,
    required GetDeliveryUseCase getDeliveryUseCase,
  }) : _watchDeliveryUseCase = watchDeliveryUseCase,
       _getDeliveryUseCase = getDeliveryUseCase,
       super(const TrackingState());

  Future<void> initialize() async {
    state = state.copyWith(status: TrackingStatus.loading);

    try {
      final delivery = await _getDeliveryUseCase();
      final markers = await _buildMarkers(delivery);
      final polylines = _buildPolylines(delivery);

      state = state.copyWith(
        status: TrackingStatus.success,
        delivery: delivery,
        markers: markers,
        polylines: polylines,
        currentCameraPosition: LatLng(
          delivery.courierLocation.latitude,
          delivery.courierLocation.longitude,
        ),
      );

      _startWatching();
    } catch (e) {
      state = state.copyWith(
        status: TrackingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void onMapCreated(GoogleMapController controller) {
    state = state.copyWith(mapController: controller);
    controller.setMapStyle(mapStyle);

    _animateCameraToCurrentPosition();
  }

  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    if (!_isProgrammaticMove && state.isFollowing) {
      state = state.copyWith(isFollowing: false);
    }
  }

  void onCameraIdle() {
    _isProgrammaticMove = false;
  }

  void recenter() {
    state = state.copyWith(isFollowing: true);
    _animateCameraToCurrentPosition();
  }

  void _startWatching() {
    _deliverySubscription?.cancel();
    _deliverySubscription = _watchDeliveryUseCase().listen(
      _onDeliveryUpdate,
      onError: _onError,
    );
  }

  Future<void> _onDeliveryUpdate(DeliveryEntity delivery) async {
    DeliveryEntity effectiveDelivery = delivery;

    if (delivery.status != DeliveryStatus.delivered) {
      final distance = _calculateDistance(
        LatLng(
          delivery.courierLocation.latitude,
          delivery.courierLocation.longitude,
        ),
        LatLng(delivery.destination.latitude, delivery.destination.longitude),
      );

      if (distance < 0.0005) {
        effectiveDelivery = delivery.copyWith(status: DeliveryStatus.delivered);
      }
    }

    final markers = await _buildMarkers(effectiveDelivery);
    final polylines = _buildPolylines(effectiveDelivery);

    state = state.copyWith(
      delivery: effectiveDelivery,
      markers: markers,
      polylines: polylines,
      currentCameraPosition: LatLng(
        effectiveDelivery.courierLocation.latitude,
        effectiveDelivery.courierLocation.longitude,
      ),
    );

    _animateCameraToCurrentPosition();
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    final dLat = p1.latitude - p2.latitude;
    final dLon = p1.longitude - p2.longitude;
    return sqrt(dLat * dLat + dLon * dLon);
  }

  void _onError(Object error) {
    state = state.copyWith(
      status: TrackingStatus.error,
      errorMessage: error.toString(),
    );
  }

  Future<Set<Marker>> _buildMarkers(DeliveryEntity delivery) async {
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId('courier'),
        position: LatLng(
          delivery.courierLocation.latitude,
          delivery.courierLocation.longitude,
        ),
        anchor: const Offset(0.5, 0.5),
        rotation: delivery.courierLocation.bearing ?? 0.0,
        zIndex: 2,
        infoWindow: InfoWindow(title: delivery.courier.name),
        icon: await _createDriverMarker(),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          delivery.destination.latitude,
          delivery.destination.longitude,
        ),
        anchor: const Offset(0.5, 1.0),
        zIndex: 1,
      ),
    );

    return markers;
  }

  Set<Polyline> _buildPolylines(DeliveryEntity delivery) {
    if (delivery.routePoints.isEmpty) return {};

    final points = delivery.routePoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final isDelivered = delivery.status == DeliveryStatus.delivered;

    if (isDelivered) {
      return {
        Polyline(
          polylineId: const PolylineId('route_traveled'),
          points: points,
          color: Colors.grey.withValues(alpha: 0.6),
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      };
    }

    final courierLatLng = LatLng(
      delivery.courierLocation.latitude,
      delivery.courierLocation.longitude,
    );

    final splitIndex = _findClosestPointIndex(courierLatLng, points);

    final traveledPoints = [...points.sublist(0, splitIndex), courierLatLng];
    final remainingPoints = [courierLatLng, ...points.sublist(splitIndex + 1)];

    return {
      Polyline(
        polylineId: const PolylineId('route_traveled'),
        points: traveledPoints,
        color: Colors.grey.withValues(alpha: 0.6),
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
      Polyline(
        polylineId: const PolylineId('route_remaining'),
        points: remainingPoints,
        color: AppColors.primary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  int _findClosestPointIndex(LatLng current, List<LatLng> points) {
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final dLat = current.latitude - points[i].latitude;
      final dLon = current.longitude - points[i].longitude;
      final distance = dLat * dLat + dLon * dLon;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  void _animateCameraToCurrentPosition() {
    if (!state.isFollowing) return;

    final controller = state.mapController;
    final position = state.currentCameraPosition;
    if (controller == null || position == null) return;

    _isProgrammaticMove = true;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: _currentZoom, tilt: 0),
      ),
    );
  }

  @override
  void dispose() {
    _deliverySubscription?.cancel();
    super.dispose();
  }

  Future<BitmapDescriptor> _createDriverMarker() async {
    const double size = 120.0;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double center = size / 2;

    final Paint glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset(center, center), 45, glowPaint);

    final Paint circlePaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(center, center), 28, circlePaint);

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(Offset(center, center), 28, borderPaint);

    const IconData bikeIcon = Icons.directions_bike;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(bikeIcon.codePoint),
      style: TextStyle(
        fontSize: 32,
        fontFamily: bikeIcon.fontFamily,
        package: bikeIcon.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center - textPainter.width / 2, center - textPainter.height / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}

final trackingViewModelProvider =
    StateNotifierProvider<TrackingViewModel, TrackingState>(
      (ref) => TrackingViewModel(
        watchDeliveryUseCase: ref.watch(watchDeliveryUseCaseProvider),
        getDeliveryUseCase: ref.watch(getDeliveryUseCaseProvider),
      ),
    );
