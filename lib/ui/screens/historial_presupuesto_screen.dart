// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
/*import 'package:path/path.dart' as p;*/
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

import '../../data/database/presupuesto_guardado_dao.dart';
import '../../data/models/presupuesto_guardado.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';

class HistorialPresupuestoScreen extends StatefulWidget {
  const HistorialPresupuestoScreen({super.key});

  @override
  State<HistorialPresupuestoScreen> createState() =>
      _HistorialPresupuestoScreenState();
}

class _HistorialPresupuestoScreenState
    extends State<HistorialPresupuestoScreen> {
  final _dao = PresupuestoGuardadoDao();
  late Future<List<PresupuestoGuardado>> _futurePresupuestos;

  @override
  void initState() {
    super.initState();
    _futurePresupuestos = _dao.obtenerTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de presupuestos'),
        backgroundColor: AppColors.surface,
      ),
      body: FutureBuilder<List<PresupuestoGuardado>>(
        future: _futurePresupuestos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AppEmptyState(
              icon: Icons.picture_as_pdf_outlined,
              message:
                  'No hay presupuestos guardados.\nGenerá uno desde Generar presupuesto.',
            );
          }

          final presupuestos = snapshot.data!;
          presupuestos.sort((a, b) => b.fecha.compareTo(a.fecha));

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: presupuestos.length,
            itemBuilder: (context, index) {
              final p = presupuestos[index];
              return _PresupuestoCard(
                presupuesto: p,
                onOpen: () async {
                  final file = File(p.filePath);
                  if (!await file.exists()) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'No se encontró el archivo del presupuesto en el dispositivo.'),
                      ),
                    );
                    return;
                  }
                  await OpenFile.open(p.filePath);
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar presupuesto'),
                      content: const Text(
                          '¿Seguro que querés eliminar este presupuesto y su archivo PDF?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      final file = File(p.filePath);
                      if (await file.exists()) {
                        await file.delete();
                      }
                      await _dao.eliminarPresupuesto(p.id!);
                    } catch (e) {
                      debugPrint('Error al eliminar presupuesto: $e');
                    }
                    if (mounted) {
                      setState(() {
                        _futurePresupuestos = _dao.obtenerTodos();
                      });
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PresupuestoCard extends StatelessWidget {
  final PresupuestoGuardado presupuesto;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _PresupuestoCard({
    required this.presupuesto,
    required this.onOpen,
    required this.onDelete,
  });

  String _fmtFecha(DateTime f) {
    return '${f.day}/${f.month}/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 22,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        presupuesto.cliente.isEmpty
                            ? 'Presupuesto sin nombre'
                            : presupuesto.cliente,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${presupuesto.negocio} · ${_fmtFecha(presupuesto.fecha)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${presupuesto.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined, size: 18),
                          color: AppColors.textSecondary,
                          onPressed: () async {
                            final file = File(presupuesto.filePath);
                            if (!await file.exists()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'No se encontró el archivo del presupuesto en el dispositivo.'),
                                ),
                              );
                              return;
                            }
                            final bytes = await file.readAsBytes();
                            await Printing.sharePdf(
                              bytes: bytes,
                              filename: presupuesto.displayName,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppColors.error,
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

