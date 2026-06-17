import 'package:flutter/foundation.dart';
import 'package:logistica_app/core/view_state.dart';
import 'package:logistica_app/features/shipments/data/shipment_repository.dart';
import 'package:logistica_app/features/shipments/model/shipment_model.dart';

class ShipmentDetailViewModel extends ChangeNotifier {
  ShipmentDetailViewModel(this._repository, ShipmentModel shipment)
      : _shipment = shipment,
        _state = ViewState.success;

  final ShipmentRepository _repository;

  ViewState _state;
  String? _errorMessage;
  ShipmentModel? _shipment;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  ShipmentModel? get shipment => _shipment;

  Future<void> loadShipmentDetail(String id) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _shipment = await _repository.fetchShipmentDetail(id);
      _state = ViewState.success;
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> updateShipment({
    required String destination,
    required String status,
  }) async {
    if (_shipment == null) return false;

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _shipment = await _repository.updateShipment(
        id: _shipment!.id,
        destination: destination,
        status: status,
      );
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteShipment() async {
    if (_shipment == null) return false;

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteShipment(_shipment!.id);
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
