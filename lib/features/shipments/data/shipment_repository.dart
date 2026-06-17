import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logistica_app/features/auth/data/auth_repository.dart';
import 'package:logistica_app/features/shipments/model/shipment_model.dart';

class ShipmentRepository {
  ShipmentRepository({
    required this.baseUrl,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final String baseUrl;
  final AuthRepository _authRepository;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authRepository.token != null)
          'Authorization': 'Bearer ${_authRepository.token}',
      };

  Future<List<ShipmentModel>> getShipments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/shipments'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => ShipmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _parseError(response);
  }

  Future<ShipmentModel> createShipment({
    required String trackingNumber,
    required String sender,
    required String receiver,
    required String destination,
    String status = 'pending',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/shipments'),
      headers: _headers,
      body: jsonEncode({
        'trackingNumber': trackingNumber,
        'sender': sender,
        'receiver': receiver,
        'destination': destination,
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      return ShipmentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw _parseError(response);
  }

  Future<ShipmentModel> updateShipment({
    required String id,
    String? destination,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (destination != null) body['destination'] = destination;
    if (status != null) body['status'] = status;

    final response = await http.put(
      Uri.parse('$baseUrl/api/shipments/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return ShipmentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw _parseError(response);
  }

  Future<void> deleteShipment(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/shipments/$id'),
      headers: _headers,
    );

    if (response.statusCode == 204) {
      return;
    }

    throw _parseError(response);
  }

  Exception _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = data['detail'];
      if (detail is String) {
        return Exception(detail);
      }
    } catch (_) {}
    return Exception('Error en la operación (${response.statusCode})');
  }
}
