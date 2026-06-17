import 'package:logistica_app/core/network/api_service.dart';
import 'package:logistica_app/features/shipments/model/shipment_model.dart';

class ShipmentRepository {
  ShipmentRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<List<ShipmentModel>> fetchShipments() async {
    final response = await _apiService.get('/api/shipments');
    _apiService.throwIfNotSuccess(
      response,
      fallbackMessage: 'Error al obtener envíos',
    );

    final data = _apiService.decodeList(response);
    return data
        .map((item) => ShipmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ShipmentModel> createShipment(ShipmentModel shipment) async {
    final response = await _apiService.post(
      '/api/shipments',
      body: shipment.toCreateJson(),
    );
    _apiService.throwIfNotSuccess(
      response,
      fallbackMessage: 'Error al crear envío',
    );

    return ShipmentModel.fromJson(_apiService.decodeMap(response));
  }

  Future<ShipmentModel> fetchShipmentDetail(String id) async {
    final response = await _apiService.get('/api/shipments/$id');
    _apiService.throwIfNotSuccess(
      response,
      fallbackMessage: 'Error al obtener el detalle del envío',
    );

    return ShipmentModel.fromJson(_apiService.decodeMap(response));
  }

  Future<ShipmentModel> updateShipment({
    required String id,
    String? destination,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (destination != null) body['destination'] = destination;
    if (status != null) body['status'] = status;

    final response = await _apiService.put(
      '/api/shipments/$id',
      body: body,
    );
    _apiService.throwIfNotSuccess(
      response,
      fallbackMessage: 'Error al actualizar envío',
    );

    return ShipmentModel.fromJson(_apiService.decodeMap(response));
  }

  Future<void> deleteShipment(String id) async {
    final response = await _apiService.delete('/api/shipments/$id');
    _apiService.throwIfNotSuccess(
      response,
      fallbackMessage: 'Error al eliminar envío',
    );
  }
}
