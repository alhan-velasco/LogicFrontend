import 'package:flutter/foundation.dart';
import 'package:logistica_app/core/view_state.dart';
import 'package:logistica_app/features/shipments/data/shipment_repository.dart';
import 'package:logistica_app/features/shipments/model/shipment_model.dart';

class ShipmentListViewModel extends ChangeNotifier {
  ShipmentListViewModel(this._repository);

  final ShipmentRepository _repository;

  ViewState _state = ViewState.initial;
  String? _errorMessage;
  List<ShipmentModel> _shipments = [];

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<ShipmentModel> get shipments => List.unmodifiable(_shipments);

  Future<void> loadShipments() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _shipments = await _repository.getShipments();
      _state = ViewState.success;
      notifyListeners();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
