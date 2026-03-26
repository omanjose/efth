
import 'package:efth/app/screens/hymn_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme.dart';
import '../controller/favorite_controller.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  Color _langAccent(String lang) {
    switch (lang) {
      case 'igbo':
        return AppColors.igbo;
      case 'efik':
        return AppColors.efik;
      default:
        return AppColors.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favController = Get.find<FavouriteController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAVED HYMNS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final hymns = favController.favouriteHymns;

        if (hymns.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: cs.onSurfaceVariant.withOpacity(0.35),
                ),
                const SizedBox(height: 16),
                Text(
                  'No saved hymns yet',
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap ♡ on any hymn to save it here',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Count bar ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Text(
                    '${hymns.length} SAVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 1, color: cs.outline)),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.favorite_rounded,
                    size: 10,
                    color: AppColors.error.withOpacity(0.9),
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: hymns.length,
                itemBuilder: (_, i) {
                  final hymn = hymns[i];
                  final accent = _langAccent(hymn.language ?? 'english');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: cs.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          final idx = hymns.indexOf(hymn);
                          Get.to(
                                () => HymnDetailScreen(
                              selectedIndex: idx,
                              items: hymns,
                            ),
                            transition: Transition.cupertino,
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        splashColor: accent.withOpacity(0.08),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cs.outline),
                          ),
                          child: Row(
                            children: [
                              // ID + accent dot
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  border: Border.all(
                                      color: accent.withOpacity(0.35)),
                                  shape: BoxShape.circle,
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
                              // Info
                              Expanded(
                                child: Column(
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
                                    const SizedBox(height: 4),
                                    // Language pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.12),
                                        border: Border.all(
                                            color: accent.withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        (hymn.language ?? 'english')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Chevron
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: cs.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
