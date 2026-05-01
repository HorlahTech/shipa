import 'package:shipa/data/datasources/tracking_datasource.dart';
import 'package:shipa/domain/entities/delivery_entity.dart';
import 'package:shipa/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingDataSource _dataSource;

  TrackingRepositoryImpl(this._dataSource);

  @override
  Stream<DeliveryEntity> watchDelivery() {
    return _dataSource.watchDelivery().map((model) => model.toEntity());
  }

  @override
  Future<DeliveryEntity> getDelivery() async {
    final model = await _dataSource.getDelivery();
    return model.toEntity();
  }

  @override
  Future<void> dispose() async {
    _dataSource.dispose();
  }
}
