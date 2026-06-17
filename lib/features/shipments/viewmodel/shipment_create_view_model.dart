import 'package:flutter/foundation.dart';
import 'package:logistica_app/core/view_state.dart';
import 'package:logistica_app/features/shipments/data/shipment_repository.dart';

class ShipmentCreateViewModel extends ChangeNotifier {
  ShipmentCreateViewModel(this._repository);

  final ShipmentRepository _repository;

  ViewState _state = ViewState.initial;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<bool> createShipment({
    required String trackingNumber,
    required String sender,
    required String receiver,
    required String destination,
    String status = 'pending',
  }) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createShipment(
        trackingNumber: trackingNumber,
        sender: sender,
        receiver: receiver,
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

  void resetState() {
    _state = ViewState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
