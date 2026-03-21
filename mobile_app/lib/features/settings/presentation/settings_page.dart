import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../application/api_key_notifier.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _keyController;
  bool _obscure = true;
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(apiKeyNotifierProvider);
    _keyController = TextEditingController(
      text: current.isCustom ? current.key : '',
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _saved = false;
    });
    await ref.read(apiKeyNotifierProvider.notifier).save(_keyController.text);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _saved = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  Future<void> _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar clave'),
        content: const Text(
          'Se eliminará la clave personalizada y se usará la configurada en el entorno (.env).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await ref.read(apiKeyNotifierProvider.notifier).resetToEnv();
    _keyController.clear();
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final keyState = ref.watch(apiKeyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── API Key ────────────────────────────────
          _SectionHeader(label: 'API', icon: Icons.vpn_key_rounded),
          const SizedBox(height: 10),
          _StatusBanner(keyState: keyState),
          const SizedBox(height: 12),
          TextFormField(
            controller: _keyController,
            obscureText: _obscure,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'Ingresa tu clave secreta',
              prefixIcon: const Icon(Icons.lock_rounded, size: 18, color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onChanged: (_) {
              if (_saved) setState(() => _saved = false);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      _saved ? Icons.check_rounded : Icons.save_rounded,
                      size: 18,
                    ),
              label: Text(_saved ? 'Guardado' : 'Guardar clave'),
              style: _saved
                  ? FilledButton.styleFrom(backgroundColor: AppColors.success)
                  : null,
            ),
          ),
          if (keyState.isCustom) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.restore_rounded, size: 17),
                label: const Text('Restaurar clave del entorno'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── Servidor ───────────────────────────────
          _SectionHeader(label: 'Servidor', icon: Icons.cloud_rounded),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Base URL',
            value: const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'https://home-saledl.vercel.app',
            ),
          ),

          const SizedBox(height: 28),

          // ── Acerca de ──────────────────────────────
          _SectionHeader(label: 'Acerca de', icon: Icons.info_outline_rounded),
          const SizedBox(height: 10),
          const _InfoRow(label: 'Versión', value: '0.1.0 (1)'),
          const SizedBox(height: 4),
          const _InfoRow(label: 'Plataforma', value: 'Flutter'),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.keyState});

  final ApiKeyState keyState;

  @override
  Widget build(BuildContext context) {
    final (icon, text, bg, fg) = switch (keyState) {
      ApiKeyState(isCustom: true, isEmpty: false) => (
          Icons.check_circle_rounded,
          'Usando clave personalizada almacenada',
          AppColors.successLight,
          AppColors.success,
        ),
      ApiKeyState(isEmpty: true) => (
          Icons.warning_rounded,
          'Sin clave configurada — las llamadas a la API fallarán',
          AppColors.warningLight,
          AppColors.warning,
        ),
      _ => (
          Icons.info_rounded,
          'Usando clave del entorno (.env / --dart-define)',
          const Color(0xFFDBEAFE),
          AppColors.accent,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: fg, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
