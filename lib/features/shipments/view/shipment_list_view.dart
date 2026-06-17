import 'package:flutter/material.dart';
import 'package:logistica_app/core/theme/app_theme.dart';
import 'package:logistica_app/core/view_state.dart';
import 'package:logistica_app/features/auth/data/auth_repository.dart';
import 'package:logistica_app/features/shipments/model/shipment_model.dart';
import 'package:logistica_app/features/shipments/viewmodel/shipment_list_view_model.dart';
import 'package:provider/provider.dart';

class ShipmentListView extends StatefulWidget {
  const ShipmentListView({super.key});

  @override
  State<ShipmentListView> createState() => _ShipmentListViewState();
}

class _ShipmentListViewState extends State<ShipmentListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentListViewModel>().loadShipments();
    });
  }

  void _onLogout() {
    context.read<AuthRepository>().logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.of(context).pushNamed('/shipments/create');
    if (result == true && mounted) {
      context.read<ShipmentListViewModel>().loadShipments();
    }
  }

  Future<void> _navigateToDetail(ShipmentModel shipment) async {
    final result = await Navigator.of(context).pushNamed(
      '/shipments/detail',
      arguments: shipment,
    );
    if (result == true && mounted) {
      context.read<ShipmentListViewModel>().loadShipments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ShipmentListViewModel>();
    final authRepository = context.read<AuthRepository>();
    final userName = authRepository.currentUser?.fullName ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Envíos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _onLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo envío'),
      ),
      body: _buildBody(viewModel, userName),
    );
  }

  Widget _buildBody(ShipmentListViewModel viewModel, String userName) {
    if (viewModel.state == ViewState.loading &&
        viewModel.shipments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == ViewState.error && viewModel.shipments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? 'Error al cargar envíos',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ShipmentListViewModel>().loadShipments();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.shipments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Hola, $userName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay envíos registrados',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear primer envío'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ShipmentListViewModel>().loadShipments(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: viewModel.shipments.length,
        itemBuilder: (context, index) {
          final shipment = viewModel.shipments[index];
          return _ShipmentCard(
            shipment: shipment,
            onTap: () => _navigateToDetail(shipment),
          );
        },
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.shipment,
    required this.onTap,
  });

  final ShipmentModel shipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(shipment.status);
    final statusLabel = AppTheme.statusLabel(shipment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shipment.trackingNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Remitente',
                    value: shipment.sender,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Destinatario',
                    value: shipment.receiver,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Destino',
                    value: shipment.destination,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
