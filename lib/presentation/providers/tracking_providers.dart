import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shipa/data/datasources/tracking_datasource.dart';
import 'package:shipa/data/repositories/tracking_repository_impl.dart';
import 'package:shipa/domain/repositories/tracking_repository.dart';
import 'package:shipa/domain/usecases/tracking_usecases.dart';

final trackingDataSourceProvider = Provider<TrackingDataSource>(
  (ref) => SimulatedTrackingDataSource(),
);

final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => TrackingRepositoryImpl(ref.watch(trackingDataSourceProvider)),
);

final watchDeliveryUseCaseProvider = Provider<WatchDeliveryUseCase>(
  (ref) => WatchDeliveryUseCase(ref.watch(trackingRepositoryProvider)),
);

final getDeliveryUseCaseProvider = Provider<GetDeliveryUseCase>(
  (ref) => GetDeliveryUseCase(ref.watch(trackingRepositoryProvider)),
);
