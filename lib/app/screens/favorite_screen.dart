import 'package:efth/app/controller/favorite_controller.dart';
import 'package:efth/app/screens/hymn_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favCtrl = Get.find<FavouriteController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAVOURITES'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              onChanged: favCtrl.filterFavorites,
              decoration: const InputDecoration(
                hintText: 'Search favourites…',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final list = favCtrl.filteredFavorites;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border_rounded,
                    size: 48,
                    color: cs.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  favCtrl.favouriteHymns.isEmpty
                      ? 'No favourites yet'
                      : 'No results found',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final hymn = list[index];
            final accent = hymn.language == 'igbo'
                ? AppColors.igbo
                : hymn.language == 'efik'
                    ? AppColors.efik
                    : AppColors.english;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FavCard(
                hymn: hymn,
                accent: accent,
                onTap: () {
                  // Use filteredFavorites as the items list so the index
                  // matches exactly what is displayed on screen.
                  final items = favCtrl.filteredFavorites.toList();
                  final idx = items.indexOf(hymn);
                  Get.to(
                    () => HymnDetailScreen(
                      selectedIndex: idx,
                      items: items,
                    ),
                    transition: Transition.cupertino,
                  );
                },
                onDelete: () => favCtrl.removeFavorite(hymn),
              ),
            );
          },
        );
      }),
    );
  }
}

class _FavCard extends StatelessWidget {
  const _FavCard({
    required this.hymn,
    required this.accent,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic hymn;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              // Title + first line
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
                      hymn.lyrics.split('\n').first,
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
              // Language badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (hymn.language ?? 'en').substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Delete button
              IconButton(
                icon: const Icon(Icons.favorite_rounded, size: 18),
                color: Colors.red,
                onPressed: onDelete,
                tooltip: 'Remove from favourites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}