import 'package:flutter/foundation.dart';
import 'package:logistica_app/core/view_state.dart';
import 'package:logistica_app/features/auth/data/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  ViewState _state = ViewState.initial;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(email: email, password: password);
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
