
import 'package:efth/app/controller/favorite_controller.dart';
import 'package:efth/app/controller/hymn_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme.dart';
import '../controller/audio_controller.dart';

class HymnDetailScreen extends StatefulWidget {
  const HymnDetailScreen({
    super.key,
    required this.selectedIndex,
    required this.items,
  });

  final int selectedIndex;
  final List items;

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
    return Obx(() {
      final hymns = List.from(widget.items);

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
          final hymn = hymns[index];
          final accent = _langAccent(hymn.language ?? 'english');
          final cs = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: _buildAppBar(hymn, accent, cs),
            body: _buildBody(hymn, accent, cs),
            floatingActionButton: _buildFontControls(cs),
          );
        },
      );
    });
  }

  PreferredSizeWidget _buildAppBar(dynamic hymn, Color accent, ColorScheme cs) {
    return AppBar(
      title: Text('HYMN ${hymn.id}'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        onPressed: () {
          audioController.stop();
          Get.back();
        },
      ),
      actions: [
        // ── Play / Pause ──────────────────────────────────────
        Obx(() {
          final playing = audioController.isPlaying.value;
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
                  if (hymn.id == 134) {
                    await audioController.playTwo(
                      'assets/audio/FTH0134A.mp3',
                      'assets/audio/FTH0134B.mp3',
                    );
                  } else if (hymn.id == 986) {
                    await audioController.playTwo(
                      'assets/audio/FTH0986A.mp3',
                      'assets/audio/FTH0986B.mp3',
                    );
                  } else {
                    await audioController.playOne(hymn.audio);
                  }
                },
              ),
            ],
          );
        }),

        // ── Favourite ─────────────────────────────────────────
        Obx(() {
          final isFav = favController.isFavourite(hymn);
          return IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.error : null,
              size: 22,
            ),
            onPressed: () => favController.toggle(hymn),
          );
        }),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildBody(dynamic hymn, Color accent, ColorScheme cs) {
    return Column(
      children: [
        // ── Title banner ──────────────────────────────────────
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

        // ── Lyrics ────────────────────────────────────────────
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
            style: IconButton.styleFrom(
              fixedSize: const Size(38, 38),
            ),
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
            style: IconButton.styleFrom(
              fixedSize: const Size(38, 38),
            ),
          ),
        ],
      ),
    );
  }
}
