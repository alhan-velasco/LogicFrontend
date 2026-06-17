import 'package:flutter/material.dart';
import 'package:logistica_app/core/theme/app_theme.dart';
import 'package:logistica_app/core/view_state.dart';
import 'package:logistica_app/features/shipments/viewmodel/shipment_create_view_model.dart';
import 'package:provider/provider.dart';

class ShipmentCreateView extends StatefulWidget {
  const ShipmentCreateView({super.key});

  @override
  State<ShipmentCreateView> createState() => _ShipmentCreateViewState();
}

class _ShipmentCreateViewState extends State<ShipmentCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  final _senderController = TextEditingController();
  final _receiverController = TextEditingController();
  final _destinationController = TextEditingController();
  String _selectedStatus = 'pending';

  static const List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'Pendiente'},
    {'value': 'in_transit', 'label': 'En tránsito'},
    {'value': 'delivered', 'label': 'Entregado'},
  ];

  @override
  void dispose() {
    _trackingController.dispose();
    _senderController.dispose();
    _receiverController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ShipmentCreateViewModel>();
    final success = await viewModel.createShipment(
      trackingNumber: _trackingController.text.trim(),
      sender: _senderController.text.trim(),
      receiver: _receiverController.text.trim(),
      destination: _destinationController.text.trim(),
      status: _selectedStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Envío creado exitosamente'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ShipmentCreateViewModel>();
    final isLoading = viewModel.state == ViewState.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Envío'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Datos del paquete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _trackingController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Número de seguimiento',
                      prefixIcon: Icon(Icons.qr_code_2),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Ingresa un número de seguimiento válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senderController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Remitente',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Ingresa el nombre del remitente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _receiverController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Destinatario',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Ingresa el nombre del destinatario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _destinationController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Destino',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Ingresa la dirección de destino';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado inicial',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: _statusOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          ),
                        )
                        .toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _onSubmit,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Crear envío'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
