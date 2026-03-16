import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../features/capture/application/workflow_controller.dart';
import '../../../domain/models/analyzed_item.dart';

class ManualEditPage extends ConsumerStatefulWidget {
  const ManualEditPage({super.key});

  @override
  ConsumerState<ManualEditPage> createState() => _ManualEditPageState();
}

class _ManualEditPageState extends ConsumerState<ManualEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _condition;
  late final TextEditingController _pickupArea;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final item = ref.read(workflowControllerProvider).analyzedItem;
    _title = TextEditingController(text: item?.title ?? '');
    _price = TextEditingController(text: (item?.price ?? 0).toString());
    _category = TextEditingController(text: item?.category ?? 'other');
    _condition = TextEditingController(text: item?.condition ?? 'good');
    _pickupArea = TextEditingController(text: item?.pickupArea ?? '');
    _description = TextEditingController(text: item?.description ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _category.dispose();
    _condition.dispose();
    _pickupArea.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edición manual')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_title, 'Título', validator: (value) => (value ?? '').trim().isEmpty ? 'Campo obligatorio' : null),
              _field(_price, 'Precio', keyboardType: TextInputType.number, validator: (value) {
                final price = int.tryParse((value ?? '').trim());
                if (price == null || price < 0) return 'Debe ser >= 0';
                return null;
              }),
              _field(_category, 'Categoría (kitchen, books, home, electronics, other)', validator: (value) {
                if (!WorkflowController.validCategories.contains((value ?? '').trim())) return 'Categoría inválida';
                return null;
              }),
              _field(_condition, 'Condición (new, like_new, good, fair, parts)', validator: (value) {
                if (!WorkflowController.validConditions.contains((value ?? '').trim())) return 'Condición inválida';
                return null;
              }),
              _field(_pickupArea, 'Zona de recogida', validator: (value) => (value ?? '').trim().isEmpty ? 'Campo obligatorio' : null),
              _field(_description, 'Descripción (opcional)', maxLines: 4),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  ref.read(workflowControllerProvider.notifier).updateAnalyzedItem(
                        AnalyzedItem(
                          title: _title.text.trim(),
                          price: int.tryParse(_price.text.trim()) ?? 0,
                          category: _category.text.trim(),
                          condition: _condition.text.trim(),
                          pickupArea: _pickupArea.text.trim(),
                          description: _description.text.trim(),
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}
