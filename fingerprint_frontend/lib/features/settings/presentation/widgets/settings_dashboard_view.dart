import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsDashboardView extends StatelessWidget {
  const SettingsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAppearanceSection(context, localizations, state),
              const SizedBox(height: 24),
              _buildLanguageSection(context, localizations, state),
              const SizedBox(height: 24),
              _buildNotificationsSection(context, localizations),
              const SizedBox(height: 24),
              _buildAboutSection(context, localizations),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    AppLocalizations localizations,
    SettingsState state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.appearance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                localizations.appearanceDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context: context,
              title: localizations.systemTheme,
              icon: Icons.settings_brightness,
              isSelected: state.themeMode == ThemeMode.system,
              onTap: () => context.read<SettingsBloc>().add(
                const ChangeThemeEvent(ThemeMode.system),
              ),
            ),
            _buildThemeOption(
              context: context,
              title: localizations.lightTheme,
              icon: Icons.light_mode,
              isSelected: state.themeMode == ThemeMode.light,
              onTap: () => context.read<SettingsBloc>().add(
                const ChangeThemeEvent(ThemeMode.light),
              ),
            ),
            _buildThemeOption(
              context: context,
              title: localizations.darkTheme,
              icon: Icons.dark_mode,
              isSelected: state.themeMode == ThemeMode.dark,
              onTap: () => context.read<SettingsBloc>().add(
                const ChangeThemeEvent(ThemeMode.dark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: isSelected
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Colors.transparent,
      leading: Icon(icon, size: 20),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.circle_outlined),
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 36),
      dense: true,
      selected: isSelected,
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    AppLocalizations localizations,
    SettingsState state,
  ) {
    final isArabic = state.locale.languageCode == 'ar';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(isArabic ? Icons.g_translate : Icons.translate),
              title: Text(isArabic ? 'العربية' : 'English'),
              subtitle: Text(isArabic ? 'اللغة العربية' : 'English language'),
              trailing: Switch(
                value: isArabic,
                activeTrackColor: Theme.of(
                  context,
                ).colorScheme.primaryContainer,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  final locale = Locale(value ? 'ar' : 'en', '');
                  context.read<SettingsBloc>().add(ChangeLanguageEvent(locale));
                },
              ),
              contentPadding: const EdgeInsets.only(left: 36),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(localizations.notifications),
        subtitle: Text(localizations.notificationsDesc),
        trailing: const Icon(Icons.chevron_left),
        onTap: () {},
      ),
    );
  }

  Widget _buildAboutSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(localizations.about),
        subtitle: Text(localizations.aboutDesc),
        trailing: const Icon(Icons.chevron_left),
        onTap: () {},
      ),
    );
  }
}
