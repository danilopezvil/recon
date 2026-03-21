import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../domain/models/analyzed_item.dart';
import '../../../features/capture/application/workflow_controller.dart';
import '../../../shared/widgets/step_indicator.dart';

class ManualEditPage extends ConsumerStatefulWidget {
  const ManualEditPage({super.key});

  @override
  ConsumerState<ManualEditPage> createState() => _ManualEditPageState();
}

class _ManualEditPageState extends ConsumerState<ManualEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _pickupArea;
  late final TextEditingController _description;
  late String _category;
  late String _condition;

  static const _categoryOptions = [
    ('kitchen', 'Cocina'),
    ('books', 'Libros'),
    ('home', 'Hogar'),
    ('electronics', 'Electrónica'),
    ('other', 'Otro'),
  ];

  static const _conditionOptions = [
    ('new', 'Nuevo'),
    ('like_new', 'Como nuevo'),
    ('good', 'Buen estado'),
    ('fair', 'Aceptable'),
    ('parts', 'Para piezas'),
  ];

  @override
  void initState() {
    super.initState();
    final item = ref.read(workflowControllerProvider).analyzedItem;
    _title = TextEditingController(text: item?.title ?? '');
    _price = TextEditingController(text: (item?.price ?? 0).toString());
    _pickupArea = TextEditingController(text: item?.pickupArea ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    final cat = item?.category ?? 'other';
    _category = WorkflowController.validCategories.contains(cat) ? cat : 'other';
    final cond = item?.condition ?? 'good';
    _condition = WorkflowController.validConditions.contains(cond) ? cond : 'good';
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _pickupArea.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar datos'),
        bottom: const StepIndicator(currentStep: 2),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TextField(
              controller: _title,
              label: 'Título',
              icon: Icons.label_rounded,
              validator: (v) => (v ?? '').trim().length < 3 ? 'Mínimo 3 caracteres' : null,
            ),
            const SizedBox(height: 10),
            _TextField(
              controller: _price,
              label: 'Precio (€)',
              icon: Icons.sell_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final p = int.tryParse((v ?? '').trim());
                if (p == null || p < 0) return 'Debe ser un número >= 0';
                if (p > 100000) return 'Máximo 100 000 €';
                return null;
              },
            ),
            const SizedBox(height: 10),
            _DropdownField<String>(
              label: 'Categoría',
              icon: Icons.category_rounded,
              value: _category,
              items: _categoryOptions
                  .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 10),
            _DropdownField<String>(
              label: 'Condición',
              icon: Icons.star_half_rounded,
              value: _condition,
              items: _conditionOptions
                  .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                  .toList(),
              onChanged: (v) => setState(() => _condition = v!),
            ),
            const SizedBox(height: 10),
            _TextField(
              controller: _pickupArea,
              label: 'Zona de recogida',
              icon: Icons.location_on_rounded,
              validator: (v) => (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 10),
            _TextField(
              controller: _description,
              label: 'Descripción (opcional)',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(workflowControllerProvider.notifier).updateAnalyzedItem(
          AnalyzedItem(
            title: _title.text.trim(),
            price: int.tryParse(_price.text.trim()) ?? 0,
            category: _category,
            condition: _condition,
            pickupArea: _pickupArea.text.trim(),
            description: _description.text.trim(),
          ),
        );
    Navigator.pop(context);
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
      validator: validator,
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}
