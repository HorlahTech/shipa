import 'package:shipa/domain/entities/delivery_entity.dart';
import 'package:shipa/domain/repositories/tracking_repository.dart';

class WatchDeliveryUseCase {
  final TrackingRepository _repository;

  WatchDeliveryUseCase(this._repository);

  Stream<DeliveryEntity> call() {
    return _repository.watchDelivery();
  }
}

class GetDeliveryUseCase {
  final TrackingRepository _repository;

  GetDeliveryUseCase(this._repository);

  Future<DeliveryEntity> call() {
    return _repository.getDelivery();
  }
}
