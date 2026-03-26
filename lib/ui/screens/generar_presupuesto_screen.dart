// ignore_for_file: use_build_context_synchronously
/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

import '../../data/database/presupuesto_guardado_dao.dart';
import '../../data/models/item_presupuesto.dart';
import '../../data/models/presupuesto_guardado.dart';
import '../../pdf/presupuesto_pdf.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';


class GenerarPresupuestoScreen extends StatefulWidget {
  const GenerarPresupuestoScreen({super.key});

  @override
  State<GenerarPresupuestoScreen> createState() =>
      _GenerarPresupuestoScreenState();
      
} 
class _GenerarPresupuestoScreenState extends State<GenerarPresupuestoScreen> {
  final _presupuestoDao = PresupuestoGuardadoDao();
  final _clienteController = TextEditingController();

  bool _generando = false;

  final _mensaje1Controller = TextEditingController(
    text:
        'Gracias por ponerse en contacto con nosotros y considerar nuestros servicios para su próximo evento. Nos complace presentarle la siguiente cotización.',
  );

  final _mensaje2Controller = TextEditingController(
    text:
        'Para confirmar su pedido, se requiere un anticipo del 50% del costo total. Este anticipo debe abonarse dentro de los 15 días posteriores a la fecha de esta cotización. En caso de cancelación, el anticipo no será reembolsable.',
  );

  final _nombreNegocioController = TextEditingController(
    text: '',
  );

  final _telefonoController = TextEditingController(
    text: '',
  );

  
  final List<ItemPresupuesto> _items = [];

  double get _total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  String _sanitizeFileName(String input) {
    final withoutSpaces = input.trim().replaceAll(' ', '_');
    final safe = withoutSpaces.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');
    return safe.isEmpty ? 'presupuesto' : safe;
  }

  void _agregarItem() {
    setState(() => _items.add(ItemPresupuesto()));
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _mensaje1Controller.dispose();
    _mensaje2Controller.dispose();
    _nombreNegocioController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

@override
void initState() {
  super.initState();
  _items.add(ItemPresupuesto());
}

  @override
  Widget build(BuildContext context) {

    return Stack (
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Generar presupuesto'),
            backgroundColor: AppColors.surface,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSectionCard(
                  title: 'Cliente',
                  children: [
                    TextFormField(
                      controller: _clienteController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente',
                        hintText: 'Ej: María García',
                      ),
                    ),
                  ],
                ),
                const AppSectionSpacer(),
                AppSectionCard(
                  title: 'Productos',
                  children: [
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return _ItemPresupuestoCard(
                        key: ValueKey(item), // Para poder eliminar correctamente
                        item: item,
                        onChanged: () => setState(() {}),
                        onDelete: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                        },
                      );
                    }),
                    TextButton.icon(
                      onPressed: _agregarItem,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar producto'),
                    ),
                  ],
                ),

                const AppSectionSpacer(),
                AppSectionCard(
                  title: 'Total',
                  children: [
                    AppSummaryRow(
                      label: 'TOTAL',
                      value: _total,
                      bold: true,
                    ),
                  ],
                ),
                const AppSectionSpacer(),
                AppSectionCard(
                  title: 'Datos del negocio',
                  children: [
                    TextFormField(
                      controller: _nombreNegocioController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del negocio',
                        hintText: 'Mi Pastelería',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        hintText: '11 1234-5678',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                const AppSectionSpacer(),
                AppSectionCard(
                  title: 'Mensajes del presupuesto',
                  children: [
                    TextFormField(
                      controller: _mensaje1Controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Mensaje inicial',
                        hintText: 'Texto de bienvenida o introducción',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _mensaje2Controller,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Mensaje final',
                        hintText: 'Condiciones, anticipo, cancelación',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                /// Generar PDF
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    label: const Text('Generar PDF'),
                    onPressed: _generando ? null : () async {
                      
                      // Validaciones para generar el PDF
                      if (_items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Agregá al menos un producto'),
                          ),
                        );
                        return;
                      }
                      if (_nombreNegocioController.text.trim().isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresá el nombre del negocio')
                          ),
                        );
                        return;
                      }
                      if (_clienteController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresá el nombre del cliente'),
                          ),
                        );
                        return;
                      }
                      if (!mounted) return;
                      setState(() => _generando = true);
                      final ahora = DateTime.now();

                      final pdf = await PresupuestoPdf.generar(
                        negocio: _nombreNegocioController.text,
                        telefono: _telefonoController.text,
                        cliente: _clienteController.text,
                        fecha: ahora,
                        items: _items,
                        mensaje1: _mensaje1Controller.text,
                        mensaje2: _mensaje2Controller.text,
                      );

                      final bytes = await pdf.save();

                      // Guardar archivo físicamente
                      final dir = await getApplicationDocumentsDirectory();
                      final folder = Directory(p.join(dir.path, 'presupuestos'));
                      if (!await folder.exists()) {
                        await folder.create(recursive: true);
                      }

                      final fechaStr =
                          '${ahora.year.toString().padLeft(4, '0')}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
                      final clienteSafe = _sanitizeFileName(_clienteController.text);

                      final displayName = '${fechaStr}_$clienteSafe.pdf';
                      final uniqueId = DateTime.now().millisecondsSinceEpoch;
                      final phisicalName = '${fechaStr}_${clienteSafe}_$uniqueId.pdf';
                      final filePath = p.join(folder.path, phisicalName);
                    
                      final file = File(filePath);
                      try {
                        await file.writeAsBytes(bytes, flush: true);
                        final presupuesto = PresupuestoGuardado(
                          cliente: _clienteController.text.trim(),
                          negocio: _nombreNegocioController.text.trim(),
                          telefono: _telefonoController.text.trim().isEmpty
                              ? null
                              : _telefonoController.text.trim(),
                          fecha: ahora,
                          total: _total,
                          filePath: filePath,
                          displayName: displayName,
                        );
                        await _presupuestoDao.insertar(presupuesto);
                      } catch (e) {
                        if (await file.exists()) {
                          await file.delete();
                        } // Por si algo salió mal al escribir el archivo, no dejamos basura en el almacenamiento
                        if (!mounted) return;
                        setState(() => _generando = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No se pudo guardar el presupuesto. Intentá nuevamente.'),
                          ),
                        );

                        return;
                      }
                      if (!mounted) return;

                      setState((){
                        _generando = false;
                      });

                      // Diálogo de confirmación con opciones
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text('🎉 Presupuesto generado'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Tu PDF está listo para enviar al cliente.'),
                                SizedBox(height: 16),
                                Text ('Presupuesto disponible en la sección de historial de presupuestos.',
                                style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54, 
                                ),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () async{
                                  Navigator.of(ctx).pop();
                                  await Printing.sharePdf(
                                    bytes: bytes,
                                    filename: displayName,
                                  );
                                },
                                child: const Text('Compartir presupuesto'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  /*await Printing.layoutPdf(
                                    onLayout: (format) async => bytes,
                                  );*/
                                  await OpenFile.open(filePath);
                                },
                                child: const Text('Ver PDF'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
              
            ),
          ),
        ),
        if (_generando) ...[
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ItemPresupuestoCard extends StatelessWidget {
  final ItemPresupuesto item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _ItemPresupuestoCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D9)),
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Producto',
              hintText: 'Ej: Torta de chocolate',
            ),
            onChanged: (v) {
              item.producto = v;
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.cantidad.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  onChanged: (v) {
                    item.cantidad = int.tryParse(v) ?? 1;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio unit.',
                    hintText: '0.00',
                    prefixText: '\$ ',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: (v) {
                    item.precioUnitario = double.tryParse(v) ?? 0;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Detalle (opcional)',
              hintText: 'Descripción adicional',
            ),
            onChanged: (v) => item.detalle = v,
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Quitar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

// Generar presupuesto V2

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

import '../../data/database/presupuesto_guardado_dao.dart';
import '../../data/models/item_presupuesto.dart';
import '../../data/models/presupuesto_guardado.dart';
import '../../pdf/presupuesto_pdf.dart';
import '../theme/app_theme.dart';

class GenerarPresupuestoScreen extends StatefulWidget {
  const GenerarPresupuestoScreen({super.key});

  @override
  State<GenerarPresupuestoScreen> createState() =>
      _GenerarPresupuestoScreenState();
}

class _GenerarPresupuestoScreenState extends State<GenerarPresupuestoScreen> {
  final _presupuestoDao = PresupuestoGuardadoDao();

  final _clienteController = TextEditingController();
  final _nombreNegocioController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _mensaje1Controller = TextEditingController();
  final _mensaje2Controller = TextEditingController();

  // Errores inline por campo
  String? _errorCliente;
  String? _errorNegocio;

  bool _generando = false;
  final List<ItemPresupuesto> _items = [];

  double get _total =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _items.add(ItemPresupuesto());
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _nombreNegocioController.dispose();
    _telefonoController.dispose();
    _mensaje1Controller.dispose();
    _mensaje2Controller.dispose();
    super.dispose();
  }

  // ─── Validación ──────────────────────────────────────────────────────────────

  bool _validar() {
    bool ok = true;
    setState(() {
      _errorNegocio = null;
      _errorCliente = null;
    });

    if (_nombreNegocioController.text.trim().isEmpty) {
      setState(() => _errorNegocio = 'Ingresá el nombre del negocio');
      ok = false;
    }
    if (_clienteController.text.trim().isEmpty) {
      setState(() => _errorCliente = 'Ingresá el nombre del cliente');
      ok = false;
    }

    // Validar cada item
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.producto.trim().isEmpty) {
        _mostrarSnack('El producto ${i + 1} no tiene nombre');
        return false;
      }
      if (item.precioUnitario <= 0) {
        _mostrarSnack('El producto "${item.producto}" tiene precio 0');
        return false;
      }
    }

    if (_items.isEmpty) {
      _mostrarSnack('Agregá al menos un producto');
      return false;
    }

    return ok;
  }

  void _mostrarSnack(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Generación de PDF (extraído del onPressed) ───────────────────────────

  Future<void> _generarPdf() async {
    if (!_validar()) return;

    setState(() => _generando = true);

    final ahora = DateTime.now();
    late final List<int> bytes;

    try {
      final pdf = await PresupuestoPdf.generar(
        negocio: _nombreNegocioController.text.trim(),
        telefono: _telefonoController.text.trim(),
        cliente: _clienteController.text.trim(),
        fecha: ahora,
        items: _items,
        mensaje1: _mensaje1Controller.text,
        mensaje2: _mensaje2Controller.text,
      );
      bytes = await pdf.save();
    } catch (e) {
      if (!mounted) return;
      setState(() => _generando = false);
      _mostrarSnack('Error al generar el PDF. Intentá nuevamente.');
      return;
    }

    // Guardar archivo físicamente
    late final String filePath;
    late final String displayName;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(dir.path, 'presupuestos'));
      if (!await folder.exists()) await folder.create(recursive: true);

      final fechaStr =
          '${ahora.year.toString().padLeft(4, '0')}-'
          '${ahora.month.toString().padLeft(2, '0')}-'
          '${ahora.day.toString().padLeft(2, '0')}';
      final clienteSafe = _sanitizeFileName(_clienteController.text);
      final uniqueId = ahora.millisecondsSinceEpoch;

      displayName = '${fechaStr}_$clienteSafe.pdf';
      final physicalName = '${fechaStr}_${clienteSafe}_$uniqueId.pdf';
      filePath = p.join(folder.path, physicalName);

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      final presupuesto = PresupuestoGuardado(
        cliente: _clienteController.text.trim(),
        negocio: _nombreNegocioController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        fecha: ahora,
        total: _total,
        filePath: filePath,
        displayName: displayName,
      );
      await _presupuestoDao.insertar(presupuesto);
    } catch (e) {
      // Limpiar archivo huérfano si existió
      try {
        final f = File(filePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}

      if (!mounted) return;
      setState(() => _generando = false);
      _mostrarSnack('No se pudo guardar el presupuesto. Intentá nuevamente.');
      return;
    }

    if (!mounted) return;
    setState(() => _generando = false);

    await _mostrarDialogoExito(
      bytes: bytes,
      displayName: displayName,
      filePath: filePath,
    );
  }

  // ─── Diálogo de éxito ─────────────────────────────────────────────────────

  Future<void> _mostrarDialogoExito({
    required List<int> bytes,
    required String displayName,
    required String filePath,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de éxito
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('📄', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Presupuesto listo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Para ${_clienteController.text.trim()}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Guardado en historial de presupuestos.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Botón principal: Compartir
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: Text(
                    'Compartir presupuesto',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await Printing.sharePdf(
                      bytes: Uint8List.fromList(bytes),
                      filename: displayName,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Botón secundario: Ver PDF
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton.icon(
                  icon: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                  label: Text(
                    'Ver PDF',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await OpenFile.open(filePath);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _sanitizeFileName(String input) {
    final withoutSpaces = input.trim().replaceAll(' ', '_');
    final safe = withoutSpaces.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');
    return safe.isEmpty ? 'presupuesto' : safe;
  }

  void _agregarItem() => setState(() => _items.add(ItemPresupuesto()));

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_generando, // bloquea el back durante la generación
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
                onPressed: _generando ? null : () => Navigator.pop(context),
              ),
              title: Text(
                'Nuevo presupuesto',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Datos del negocio ──
                  _SectionCard(
                    title: 'Datos del negocio',
                    children: [
                      _AppField(
                        controller: _nombreNegocioController,
                        label: 'Negocio',
                        hint: 'Mi Pastelería',
                        errorText: _errorNegocio,
                        onChanged: (_) =>
                            setState(() => _errorNegocio = null),
                      ),
                      const SizedBox(height: 10),
                      _AppField(
                        controller: _telefonoController,
                        label: 'Teléfono',
                        hint: '11 1234-5678',
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Cliente ──
                  _SectionCard(
                    title: 'Cliente',
                    children: [
                      _AppField(
                        controller: _clienteController,
                        label: 'Nombre del cliente',
                        hint: 'Ej: María García',
                        errorText: _errorCliente,
                        onChanged: (_) =>
                            setState(() => _errorCliente = null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Productos ──
                  _SectionCard(
                    title: 'Productos',
                    children: [
                      ..._items.asMap().entries.map((entry) {
                        return _ItemPresupuestoCard(
                          key: ValueKey(entry.value),
                          item: entry.value,
                          onChanged: () => setState(() {}),
                          onDelete: _items.length > 1
                              ? () => setState(() => _items.removeAt(entry.key))
                              : null, // no permite borrar el último item
                        );
                      }),
                      const SizedBox(height: 4),
                      _AddProductoButton(onTap: _agregarItem),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Mensajes ──
                  _SectionCard(
                    title: 'Mensajes del presupuesto',
                    children: [
                      _AppField(
                        controller: _mensaje1Controller,
                        label: 'Mensaje inicial',
                        hint:
                            'Ej: Gracias por contactarnos, a continuación le enviamos la cotización.',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      _AppField(
                        controller: _mensaje2Controller,
                        label: 'Mensaje final',
                        hint:
                            'Ej: Se requiere un anticipo del 50% para confirmar el pedido.',
                        maxLines: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Total ──
                  _TotalCard(total: _total),
                  const SizedBox(height: 20),

                  // ── Botón generar ──
                  _GenerarButton(
                    generando: _generando,
                    onPressed: _generarPdf,
                  ),
                ],
              ),
            ),
          ),

          // ── Overlay de carga ──
          if (_generando) _LoadingOverlay(),
        ],
      ),
    );
  }
}

// ─── Componentes privados de la pantalla ─────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? errorText;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppField({
    required this.controller,
    required this.label,
    required this.hint,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppColors.textMuted.withOpacity(0.6),
        ),
        errorText: errorText,
        errorStyle: GoogleFonts.dmSans(fontSize: 11, color: AppColors.error),
        filled: true,
        fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.surfaceVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

class _ItemPresupuestoCard extends StatelessWidget {
  final ItemPresupuesto item;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

  const _ItemPresupuestoCard({
    super.key,
    required this.item,
    required this.onChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant, width: 1),
      ),
      child: Column(
        children: [
          _AppField(
            controller: TextEditingController(text: item.producto)
              ..selection = TextSelection.collapsed(offset: item.producto.length),
            label: 'Producto',
            hint: 'Ej: Torta de chocolate',
            onChanged: (v) {
              item.producto = v;
              onChanged();
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.cantidad.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.surfaceVariant, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                  ),
                  onChanged: (v) {
                    item.cantidad = int.tryParse(v) ?? 1;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Precio unit.',
                    labelStyle: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.textMuted),
                    hintText: '0,00',
                    prefixText: '\$ ',
                    prefixStyle: GoogleFonts.dmSans(
                        fontSize: 14, color: AppColors.textSecondary),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: AppColors.background,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.surfaceVariant, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                  ),
                  onChanged: (v) {
                    item.precioUnitario =
                        double.tryParse(v.replaceAll(',', '.')) ?? 0;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AppField(
            controller: TextEditingController(text: item.detalle),
            label: 'Detalle (opcional)',
            hint: 'Descripción adicional',
            onChanged: (v) => item.detalle = v,
          ),
          if (onDelete != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: Text(
                  'Quitar',
                  style: GoogleFonts.dmSans(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddProductoButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProductoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Agregar producto',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total del presupuesto',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '\$ ${total.toStringAsFixed(2)}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerarButton extends StatelessWidget {
  final bool generando;
  final VoidCallback onPressed;
  const _GenerarButton({required this.generando, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: generando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📄', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              'Generar PDF',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Generando tu presupuesto...',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}