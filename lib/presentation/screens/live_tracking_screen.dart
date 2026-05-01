import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shipa/core/theme/app_theme.dart';
import 'package:shipa/domain/entities/delivery_entity.dart';
import 'package:shipa/presentation/viewmodels/tracking_viewmodel.dart';
import 'package:shipa/presentation/widgets/courier_info_card.dart';
import 'package:shipa/presentation/widgets/delivery_status_timeline.dart';
import 'package:shipa/presentation/widgets/eta_banner.dart';
import 'package:shipa/presentation/widgets/order_id_row.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sheetAnimController;
  late final Animation<double> _sheetAnimation;

  @override
  void initState() {
    super.initState();

    _sheetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _sheetAnimation = CurvedAnimation(
      parent: _sheetAnimController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(trackingViewModelProvider.notifier).initialize();
      _sheetAnimController.forward();
    });
  }

  @override
  void dispose() {
    _sheetAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingViewModelProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    final initialTarget = LatLng(
      state.delivery?.courierLocation.latitude ?? 0.0,
      state.delivery?.courierLocation.longitude ?? 0.0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child:
                state.status == TrackingStatus.loading || state.delivery == null
                ? const _MapLoadingPlaceholder()
                : GoogleMap(
                    onMapCreated: (controller) => ref
                        .read(trackingViewModelProvider.notifier)
                        .onMapCreated(controller),
                    onCameraMove: (position) => ref
                        .read(trackingViewModelProvider.notifier)
                        .onCameraMove(position),
                    onCameraIdle: () => ref
                        .read(trackingViewModelProvider.notifier)
                        .onCameraIdle(),
                    initialCameraPosition: CameraPosition(
                      target: initialTarget,
                      zoom: 13.0,
                    ),
                    markers: state.markers,
                    polylines: state.polylines,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: true,
                  ),
          ),

          Positioned(top: 0, left: 0, right: 0, child: _TopBar()),

          Positioned(
            bottom: 450,
            right: 15,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !state.isFollowing && state.delivery != null
                  ? _RecenterButton()
                  : const SizedBox.shrink(),
            ),
          ),

          Positioned(
            bottom: 15,
            left: 15,
            right: 15,

            child: AnimatedBuilder(
              animation: _sheetAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, (1 - _sheetAnimation.value) * 300),
                child: child,
              ),
              child: state.delivery != null
                  ? _BottomSheet(delivery: state.delivery!)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
        ),
      ),
      child: Row(
        children: [
          _BackButton(),
          const Expanded(
            child: Center(
              child: Text('Live Tracking', style: AppTextStyles.screenTitle),
            ),
          ),

          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          size: 26,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final DeliveryEntity delivery;

  const _BottomSheet({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EtaBanner(etaMinutes: delivery.etaMinutes, status: delivery.status),

          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                CourierInfoCard(delivery: delivery),

                OrderIdRow(
                  orderId: delivery.orderId,
                  status: _statusLabel(delivery.status),
                ),

                DeliveryStatusTimeline(delivery: delivery),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.onDelivery:
        return 'On Delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
    }
  }
}

class _MapLoadingPlaceholder extends StatelessWidget {
  const _MapLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F0),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading map...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecenterButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(trackingViewModelProvider.notifier).recenter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.my_location_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Recenter',
              style: AppTextStyles.etaText.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
