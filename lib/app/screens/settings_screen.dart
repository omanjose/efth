
import 'package:efth/app/controller/hymn_controller.dart';
import 'package:efth/app/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final hymnCtrl = Get.put(HymnController());
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          // ─── Appearance ──────────────────────────────────────────
          _SectionLabel(label: 'APPEARANCE'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              Obx(() => _DropdownTile<ThemeMode>(
                icon: Icons.brightness_6_rounded,
                label: 'Theme',
                subtitle: controller.getThemeModeString(),
                value: controller.themeService.themeMode,
                items: const [
                  DropdownMenuItem(
                      value: ThemeMode.system, child: Text('System')),
                  DropdownMenuItem(
                      value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(
                      value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (mode) {
                  if (mode != null) controller.changeTheme(mode);
                },
              )),
              Divider(height: 1, color: cs.outline),
              Obx(() => _DropdownTile<String>(
                icon: Icons.translate_rounded,
                label: 'Language',
                subtitle: _langLabel(hymnCtrl.language.value),
                value: hymnCtrl.language.value,
                items: const [
                  DropdownMenuItem(
                      value: 'english', child: Text('English')),
                  DropdownMenuItem(value: 'igbo', child: Text('Igbo')),
                  DropdownMenuItem(value: 'efik', child: Text('Efik')),
                ],
                onChanged: (lang) {
                  if (lang != null) hymnCtrl.changeLanguage(lang);
                },
              )),
            ],
          ),

          const SizedBox(height: 24),

          // ─── About ───────────────────────────────────────────────
          _SectionLabel(label: 'ABOUT'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _InfoTile(
                icon: Icons.tag_rounded,
                iconColor: AppColors.english,
                label: 'App Version',
                subtitle: '1.0.0',
              ),
              Divider(height: 1, color: cs.outline),
              _TappableTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.igbo,
                label: 'About App',
                subtitle: 'e-FTH Multilingual hymn book with audio',
                onTap: () => _showAboutDialog(context),
              ),
              Divider(height: 1, color: cs.outline),
              _TappableTile(
                icon: Icons.code_rounded,
                iconColor: AppColors.efik,
                label: 'Developer Info',
                subtitle: 'Hallmark Solutions · Aba, Nigeria',
                onTap: () => _showDeveloperDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ─── Footer ──────────────────────────────────────────────
          Column(
            children: [
              Text(
                '✦',
                style: TextStyle(
                  color: AppColors.gold.withOpacity(0.4),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '© 2026 eFTH · ALL RIGHTS RESERVED',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _langLabel(String lang) {
    switch (lang) {
      case 'igbo':
        return 'Igbo';
      case 'efik':
        return 'Efik';
      default:
        return 'English';
    }
  }

  void _showAboutDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About e-FTH'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A comprehensive multilingual hymn book:',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: cs.onSurface),
              ),
              const SizedBox(height: 12),
              ...[
                'English, Igbo & Efik translations',
                'Audio playback for hymns',
                'Favourite hymns collection',
                'Adjustable font size',
                'Light & dark themes',
                'Fully offline',
              ].map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(right: 10, top: 1),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(f,
                        style: TextStyle(
                            fontSize: 14, color: cs.onSurface)),
                  ],
                ),
              )),
              const SizedBox(height: 10),
              Text(
                'Perfect for worship, study & spiritual growth.',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: cs.onSurfaceVariant,
                    fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: const Text('About us')),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.code_rounded,
                      color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hallmark Solutions Resources',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: cs.onSurface)),
                    Text('Built with Love ❤️',
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DevInfoRow(icon: Icons.location_on_rounded, text: 'Aba, Nigeria'),
            const SizedBox(height: 8),
            _DevInfoRow(icon: Icons.phone_rounded, text: '+234-703-430-7977'),
            const SizedBox(height: 8),
            _DevInfoRow(
                icon: Icons.email_rounded, text: 'joshuaoleh@gmail.com'),
            const SizedBox(height: 14),
            Text(
              '© 2026 eFTH. All rights reserved.',
              style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String label, subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: cs.onSurface)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              underline: const SizedBox(),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface),
              dropdownColor: cs.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              icon: Icon(Icons.expand_more_rounded,
                  size: 18, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label, subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              border: Border.all(color: iconColor.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: cs.onSurface)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(
            subtitle == '1.0.0' ? '1.0.0' : '',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _TappableTile extends StatelessWidget {
  const _TappableTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                border: Border.all(color: iconColor.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: cs.onSurface)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _DevInfoRow extends StatelessWidget {
  const _DevInfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.gold),
        const SizedBox(width: 10),
        Text(text,
            style: TextStyle(fontSize: 13, color: cs.onSurface)),
      ],
    );
  }
}
