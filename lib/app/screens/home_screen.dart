import 'package:efth/app/screens/hymn_detail_screen.dart';
import 'package:efth/app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme.dart';
import '../controller/favorite_controller.dart';
import '../controller/hymn_controller.dart';
import '../controller/search_controller.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _languages = [
    ('English', 'english', AppColors.english),
    ('Igbo', 'igbo', AppColors.igbo),
    ('Efik', 'efik', AppColors.efik),
  ];

  @override
  Widget build(BuildContext context) {
    final favController = Get.find<FavouriteController>();
    final hymnCtrl = Get.find<HymnController>();
    final searchCtrl = Get.find<SearchQueryController>();
    final cs = Theme
        .of(context)
        .colorScheme;
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('e — F T H'),
        actions: [
          _AppBarIconBtn(
            icon: Icons.favorite_rounded,
            onPressed: () =>
                Get.to(() => const FavouriteScreen(),
                    transition: Transition.cupertino),
          ),
          _AppBarIconBtn(
            icon: Icons.tune_rounded,
            onPressed: () =>
                Get.to(() => const SettingsView(),
                    transition: Transition.cupertino),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Obx(() {
            final selected = hymnCtrl.language.value;
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: _languages.map((lang) {
                  final isSelected = selected == lang.$2;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _LanguageChip(
                        label: lang.$1,
                        value: lang.$2,
                        accent: lang.$3,
                        isSelected: isSelected,
                        onTap: () => hymnCtrl.language.value = lang.$2,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ),

      body: Column(
          children: [
      // ── Search bar ──────────────────────────────────────────
      Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        controller: searchCtrl.queryController,
        onChanged: (v) => searchCtrl.query.value = v,
        decoration: const InputDecoration(
          hintText: 'Search by title, number or word…',
          prefixIcon: Icon(Icons.search_rounded, size: 20),
        ),
      ),
    ),

    // ── Count bar ───────────────────────────────────────────
    Obx(() {
    final list = searchCtrl.filter(hymnCtrl.hymns);
    return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
    children: [
    Text(
    '${list.length} HYMNS',
    style: TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: cs.onSurfaceVariant,
    ),
    ),
    const SizedBox(width: 10),
    Expanded(
    child: Container(height: 1.5, color: cs.outline),
    ),
    const SizedBox(width: 10),
    Obx(() {
    final lang = hymnCtrl.language.value;
    final accent = lang == 'english'
    ? AppColors.english
        : lang == 'igbo'
    ? AppColors.igbo
        : AppColors.efik;
    return Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
    color: accent,
    shape: BoxShape.circle,
    ),
    );
    }),
    ],
    ),
    );
    }),


    // ── List ────────────────────────────────────────────────
    Expanded(
      child: Obx(() {
        final list = searchCtrl.filter(hymnCtrl.hymns);

        if (hymnCtrl.isLoading || hymnCtrl.hymns.isEmpty) {
          return _EmptyState(
            icon: Icons.music_note_rounded,
            message: 'Loading hymns…',
            showLoader: true,
          );
        }

        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off_rounded,
            message: 'No hymns found',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final hymn = list[index];
            final accent = hymn.language == 'english'
                ? AppColors.english
                : hymn.language == 'igbo'
                ? AppColors.igbo
                : AppColors.efik;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HymnCard(
                hymn: hymn,
                accent: accent,
                onTap: () {
                  final idx = hymnCtrl.allHymns.indexOf(hymn);
                  Get.to(
                        () => HymnDetailScreen(
                      selectedIndex: idx,
                      items: hymnCtrl.allHymns,
                    ),
                    transition: Transition.cupertino,
                  );
                },
              ),
            );
          },
        );
      }),
    ),
    ],
    ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _AppBarIconBtn extends StatelessWidget {
  const _AppBarIconBtn({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.value,
    required this.accent,
    required this.isSelected,
    required this.onTap,
  });

  final String label, value;
  final Color accent;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme
        .of(context)
        .colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? accent : AppColors.lightMuted,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0.3,
              color: isSelected ? accent : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _HymnCard extends StatelessWidget {
  const _HymnCard({
    required this.hymn,
    required this.accent,
    required this.onTap,
  });

  final dynamic hymn;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme
        .of(context)
        .colorScheme;

    return Material(
      color: cs.surfaceVariant,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: accent.withOpacity(0.08),
        highlightColor: accent.withOpacity(0.04),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              // ID badge
              Container(
                width: 42,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  border: Border.all(color: accent.withOpacity(0.35)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${hymn.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title + preview
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hymn.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hymn.lyrics
                          .split('\n')
                          .first,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.showLoader = false,
  });

  final IconData icon;
  final String message;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    final cs = Theme
        .of(context)
        .colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: cs.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (showLoader) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
