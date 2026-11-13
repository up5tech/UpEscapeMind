import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/providers/app_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/settings_repository.dart';

/// Settings screen: audio, haptics, language. Persisted via
/// [SettingsRepository] (`shared_preferences`).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(settingsRepositoryProvider);

    return AppScaffold(
      title: l10n.settingsTitle,
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsToggle(
            title: l10n.settingsMusic,
            icon: Icons.music_note_outlined,
            initialValue: repo.isMusicEnabled,
            onChanged: repo.setMusicEnabled,
          ),
          const SizedBox(height: 8),
          _SettingsToggle(
            title: l10n.settingsSoundEffects,
            icon: Icons.graphic_eq,
            initialValue: repo.isSoundEffectsEnabled,
            onChanged: repo.setSoundEffectsEnabled,
          ),
          const SizedBox(height: 8),
          _SettingsToggle(
            title: l10n.settingsHaptics,
            icon: Icons.vibration,
            initialValue: repo.isHapticsEnabled,
            onChanged: repo.setHapticsEnabled,
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: l10n.settingsLanguage,
            child: _LanguageSelector(repo: repo),
          ),
          const SizedBox(height: 16),
          SectionCard(child: _ResetProgressButton()),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatefulWidget {
  const _SettingsToggle({
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final Future<bool> Function() initialValue;
  final Future<void> Function(bool) onChanged;

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> {
  bool? _value;

  @override
  void initState() {
    super.initState();
    widget.initialValue().then((v) {
      if (mounted) setState(() => _value = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(widget.icon),
        title: Text(widget.title),
        value: _value ?? true,
        onChanged: (v) {
          setState(() => _value = v);
          widget.onChanged(v);
        },
      ),
    );
  }
}

class _LanguageSelector extends ConsumerStatefulWidget {
  const _LanguageSelector({required this.repo});

  final SettingsRepository repo;

  @override
  ConsumerState<_LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends ConsumerState<_LanguageSelector> {
  String? _override;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.repo.languageOverride().then((v) {
      if (mounted) {
        setState(() {
          _override = v;
          _loaded = true;
        });
        ref.read(appLocaleProvider.notifier).set(v == null ? null : Locale(v));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = _loaded
        ? _override
        : ref.watch(appLocaleProvider)?.languageCode;

    return DropdownButtonFormField<String?>(
      initialValue: current,
      decoration: const InputDecoration(),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.languageSystemDefault)),
        const DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
        const DropdownMenuItem(value: 'en', child: Text('English')),
      ],
      onChanged: (value) {
        setState(() => _override = value);
        ref
            .read(appLocaleProvider.notifier)
            .set(value == null ? null : Locale(value));
        widget.repo.setLanguageOverride(value);
      },
    );
  }
}

/// Destructive reset, gated behind an explicit confirmation dialog.
class _ResetProgressButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return OutlinedButton.icon(
      icon: const Icon(Icons.restart_alt),
      label: Text(l10n.settingsResetProgress),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger),
      ),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.resetProgressConfirmTitle),
            content: Text(l10n.resetProgressConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.commonConfirm),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;

        final repo = ref.read(progressRepositoryProvider);
        await repo.resetProgress(AppConstants.defaultSaveSlotId);
        ref.invalidate(gameProgressProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.resetProgressDone)));
        }
      },
    );
  }
}
