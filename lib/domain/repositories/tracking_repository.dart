import 'package:shipa/domain/entities/delivery_entity.dart';

abstract class TrackingRepository {
  Stream<DeliveryEntity> watchDelivery();

  Future<DeliveryEntity> getDelivery();

  Future<void> dispose();
}
