import 'package:flutter/material.dart';
import 'package:logistica_app/core/network/api_service.dart';
import 'package:logistica_app/core/theme/app_theme.dart';
import 'package:logistica_app/features/auth/data/auth_repository.dart';
import 'package:logistica_app/features/auth/view/login_view.dart';
import 'package:logistica_app/features/auth/view/register_view.dart';
import 'package:logistica_app/features/auth/viewmodel/login_view_model.dart';
import 'package:logistica_app/features/auth/viewmodel/register_view_model.dart';
import 'package:logistica_app/features/shipments/data/shipment_repository.dart';
import 'package:logistica_app/features/shipments/model/shipment_model.dart';
import 'package:logistica_app/features/shipments/view/shipment_create_view.dart';
import 'package:logistica_app/features/shipments/view/shipment_detail_view.dart';
import 'package:logistica_app/features/shipments/view/shipment_list_view.dart';
import 'package:logistica_app/features/shipments/viewmodel/shipment_create_view_model.dart';
import 'package:logistica_app/features/shipments/viewmodel/shipment_detail_view_model.dart';
import 'package:logistica_app/features/shipments/viewmodel/shipment_list_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  final apiService = ApiService(baseUrl: ApiService.defaultBaseUrl);
  final authRepository = AuthRepository(apiService: apiService);
  final shipmentRepository = ShipmentRepository(apiService: apiService);

  runApp(
    LogisticaApp(
      authRepository: authRepository,
      shipmentRepository: shipmentRepository,
    ),
  );
}

class LogisticaApp extends StatelessWidget {
  const LogisticaApp({
    super.key,
    required this.authRepository,
    required this.shipmentRepository,
  });

  final AuthRepository authRepository;
  final ShipmentRepository shipmentRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<ShipmentRepository>.value(value: shipmentRepository),
      ],
      child: MaterialApp(
        title: 'Logística Express',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(authRepository),
            child: const LoginView(),
          ),
        );
      case '/register':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (_) => RegisterViewModel(authRepository),
            child: const RegisterView(),
          ),
        );
      case '/shipments':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ShipmentListViewModel(shipmentRepository),
            child: const ShipmentListView(),
          ),
        );
      case '/shipments/create':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ShipmentCreateViewModel(shipmentRepository),
            child: const ShipmentCreateView(),
          ),
        );
      case '/shipments/detail':
        final shipment = settings.arguments as ShipmentModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ShipmentDetailViewModel(shipmentRepository)
              ..setShipment(shipment),
            child: const ShipmentDetailView(),
          ),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(authRepository),
            child: const LoginView(),
          ),
        );
    }
  }
}
