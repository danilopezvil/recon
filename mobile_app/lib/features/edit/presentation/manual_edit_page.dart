import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/models/analyzed_item.dart';

class ManualEditPage extends ConsumerStatefulWidget {
  const ManualEditPage({super.key});

  @override
  ConsumerState<ManualEditPage> createState() => _ManualEditPageState();
}

class _ManualEditPageState extends ConsumerState<ManualEditPage> {
  static const _validConditions = {'new', 'like_new', 'good', 'fair', 'parts'};

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _condition;
  late final TextEditingController _pickupArea;
  late final TextEditingController _description;
  late final TextEditingController _author;
  late final TextEditingController _genre;
  late final TextEditingController _language;

  @override
  void initState() {
    super.initState();
    final item = ref.read(workflowControllerProvider).analyzedItem;
    _title = TextEditingController(text: item?.title ?? '');
    _price = TextEditingController(text: (item?.price ?? 0).toString());
    _category = TextEditingController(text: item?.category ?? '');
    _condition = TextEditingController(text: item?.condition ?? 'good');
    _pickupArea = TextEditingController(text: item?.pickupArea ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _author = TextEditingController(text: item?.author ?? '');
    _genre = TextEditingController(text: item?.genre ?? '');
    _language = TextEditingController(text: item?.language ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _category.dispose();
    _condition.dispose();
    _pickupArea.dispose();
    _description.dispose();
    _author.dispose();
    _genre.dispose();
    _language.dispose();
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
              _field(_title, 'Título'),
              _field(_price, 'Precio', keyboardType: TextInputType.number),
              _field(_category, 'Categoría'),
              _field(_condition, 'Condición (new, like_new, good, fair, parts)'),
              _field(_pickupArea, 'Zona de recogida'),
              _field(_description, 'Descripción', maxLines: 4),
              _field(_author, 'Autor (opcional)', required: false),
              _field(_genre, 'Género (opcional)', required: false),
              _field(_language, 'Idioma (opcional)', required: false),
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
                          author: _author.text.trim().isEmpty ? null : _author.text.trim(),
                          genre: _genre.text.trim().isEmpty ? null : _genre.text.trim(),
                          language: _language.text.trim().isEmpty ? null : _language.text.trim(),
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
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final v = (value ?? '').trim();
          if (required && v.isEmpty) return 'Campo obligatorio';
          if (controller == _condition && v.isNotEmpty && !_validConditions.contains(v)) {
            return 'Condición inválida';
          }
          return null;
        },
      ),
    );
  }
}
