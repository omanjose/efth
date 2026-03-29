import 'package:efth/app/controller/favorite_controller.dart';
import 'package:efth/app/controller/hymn_controller.dart';
import 'package:efth/app/model/hymn_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme.dart';
import '../controller/audio_controller.dart';

class HymnDetailScreen extends StatefulWidget {
  const HymnDetailScreen({
    super.key,
    required this.selectedIndex,
    required this.items, // the exact list to page through — do NOT re-filter
  });

  final int selectedIndex;
  final List<HymnModel> items;

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int currentPage;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final hymnCtrl = Get.find<HymnController>();
  final favController = Get.find<FavouriteController>();
  final audioController = Get.find<AudioController>();

  @override
  void initState() {
    super.initState();
    currentPage = widget.selectedIndex;
    _pageController = PageController(initialPage: widget.selectedIndex);

    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    audioController.stop();
    _pageController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _langAccent(String? lang) {
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
    // Use widget.items directly — never re-filter here.
    // HomeScreen passes a language-filtered list.
    // FavouriteScreen passes the favourites list.
    // Both are already the right set of hymns to page through.
    //
    // We wrap in Obx only to react to allHymns.refresh() after a download
    // so hasAudio/audioPath update in the play button — we look up each
    // displayed hymn by id in allHymns to get the live Rx fields.
    return Obx(() {
      // Touch allHymns so this Obx re-runs when audio status refreshes
      // ignore: unnecessary_statements
      hymnCtrl.allHymns.length;

      final hymns = widget.items;

      if (hymns.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            audioController.stop();
            Get.back();
          }
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (currentPage >= hymns.length) {
        currentPage = hymns.length - 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(currentPage);
          }
        });
      }

      return PageView.builder(
        controller: _pageController,
        itemCount: hymns.length,
        onPageChanged: (index) {
          setState(() => currentPage = index);
          audioController.stop();
        },
        itemBuilder: (context, index) {
          // For audio reactivity: look up the live model from allHymns by
          // id+language so Rx hasAudio/audioPath fields are observed.
          // Fall back to widget.items[index] if not found (e.g. favourites
          // loaded from DB before allHymns is ready).
          final staticHymn = hymns[index];
          final liveHymn = hymnCtrl.allHymns.firstWhereOrNull(
                (h) => h.id == staticHymn.id && h.language == staticHymn.language,
              ) ??
              staticHymn;

          final accent = _langAccent(liveHymn.language);
          final cs = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: _buildAppBar(staticHymn, liveHymn, accent, cs),
            body: _buildBody(staticHymn, accent, cs),
            floatingActionButton: _buildFontControls(cs),
          );
        },
      );
    });
  }

  // staticHymn  — from widget.items, has stable title/lyrics/id
  // liveHymn    — from allHymns, has reactive hasAudio/audioPath
  PreferredSizeWidget _buildAppBar(
    HymnModel staticHymn,
    HymnModel liveHymn,
    Color accent,
    ColorScheme cs,
  ) {
    return AppBar(
      title: Text('HYMN ${staticHymn.id}'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        onPressed: () {
          audioController.stop();
          Get.back();
        },
      ),
      actions: [
        // Play button reads liveHymn's Rx fields so it reacts to downloads
        Obx(() {
          final playing = audioController.isPlaying.value;
          final hasAudio =
              liveHymn.hasAudio == true && liveHymn.audioPath != null;

          if (!hasAudio) {
            return IconButton(
              icon: Icon(
                Icons.music_off_rounded,
                color: cs.onSurfaceVariant.withOpacity(0.3),
                size: 24,
              ),
              onPressed: null,
              tooltip: 'No audio available',
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              if (playing)
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  playing
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  color: playing ? AppColors.gold : null,
                  size: 26,
                ),
                onPressed: () async {
                  if (audioController.isPlaying.value) {
                    audioController.pause();
                    return;
                  }
                  if (liveHymn.id == 134 || liveHymn.id == 986) {
                    final pathA =
                        liveHymn.audioPath!.replaceAll('.opus', 'A.opus');
                    final pathB =
                        liveHymn.audioPath!.replaceAll('.opus', 'B.opus');
                    if (kDebugMode) print('🎵 2-part: $pathA | $pathB');
                    await audioController.playTwo(pathA, pathB);
                  } else {
                    if (kDebugMode) print('🎵 Playing: ${liveHymn.audioPath}');
                    await audioController.playOne(liveHymn.audioPath!);
                  }
                },
                tooltip: playing ? 'Pause' : 'Play',
              ),
            ],
          );
        }),

        // Favourite button uses staticHymn (has language set correctly)
        Obx(() {
          final isFav = favController.isFavourite(staticHymn);
          return IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.error : null,
              size: 22,
            ),
            onPressed: () => favController.toggle(staticHymn),
            tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
          );
        }),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildBody(HymnModel hymn, Color accent, ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 5, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            border: Border.all(color: accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                '✦  ✦  ✦',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hymn.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: cs.onSurface,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                '✦',
                style: TextStyle(
                  color: accent.withOpacity(0.9),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceVariant,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
              children: [
                Obx(
                  () => Text(
                    hymn.lyrics,
                    style: TextStyle(
                      fontSize: hymnCtrl.fontSize,
                      height: 1.9,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '·  ·  ·',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontControls(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 20),
            onPressed: hymnCtrl.decreaseFontSize,
            style: IconButton.styleFrom(fixedSize: const Size(38, 38)),
          ),
          Obx(
            () => SizedBox(
              width: 30,
              child: Text(
                hymnCtrl.fontSize.toInt().toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: cs.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 20),
            onPressed: hymnCtrl.increaseFontSize,
            style: IconButton.styleFrom(fixedSize: const Size(38, 38)),
          ),
        ],
      ),
    );
  }
}