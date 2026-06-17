import 'package:flutter/material.dart';
import 'package:logistica_app/core/theme/app_theme.dart';
import 'package:logistica_app/core/view_state.dart';
import 'package:logistica_app/features/shipments/model/shipment_model.dart';
import 'package:logistica_app/features/shipments/viewmodel/shipment_detail_view_model.dart';
import 'package:provider/provider.dart';

class ShipmentDetailView extends StatefulWidget {
  const ShipmentDetailView({
    super.key,
    required this.shipment,
  });

  final ShipmentModel shipment;

  @override
  State<ShipmentDetailView> createState() => _ShipmentDetailViewState();
}

class _ShipmentDetailViewState extends State<ShipmentDetailView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _destinationController;
  late String _selectedStatus;

  static const List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'Pendiente'},
    {'value': 'in_transit', 'label': 'En tránsito'},
    {'value': 'delivered', 'label': 'Entregado'},
  ];

  @override
  void initState() {
    super.initState();
    _destinationController =
        TextEditingController(text: widget.shipment.destination);
    _selectedStatus = widget.shipment.status;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ShipmentDetailViewModel>();
    final success = await viewModel.updateShipment(
      destination: _destinationController.text.trim(),
      status: _selectedStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Envío actualizado exitosamente'),
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

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar envío'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar y eliminar este envío?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final viewModel = context.read<ShipmentDetailViewModel>();
    final success = await viewModel.deleteShipment();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Envío eliminado'),
          backgroundColor: AppTheme.errorColor,
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
    final viewModel = context.watch<ShipmentDetailViewModel>();
    final shipment = viewModel.shipment ?? widget.shipment;
    final isLoading = viewModel.state == ViewState.loading;

    final statusColor = AppTheme.statusColor(shipment.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Envío'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar envío',
            onPressed: isLoading ? null : _onDelete,
          ),
        ],
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
                  Card(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code_2,
                                    color: AppTheme.secondaryColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      shipment.trackingNumber,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              _DetailRow(
                                label: 'Remitente',
                                value: shipment.sender,
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(
                                label: 'Destinatario',
                                value: shipment.receiver,
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(
                                label: 'Creado',
                                value: _formatDate(shipment.createdAt),
                                icon: Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              AppTheme.statusLabel(shipment.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Actualizar envío',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _destinationController,
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
                      labelText: 'Estado',
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
                      onPressed: isLoading ? null : _onUpdate,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar cambios'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : _onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Cancelar envío'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                      ),
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
