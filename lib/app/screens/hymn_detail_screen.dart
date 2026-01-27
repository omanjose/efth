import 'package:efth/app/controller/favorite_controller.dart';
import 'package:efth/app/controller/hymn_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  late PageController _pageController;
  late int currentPage;

  final hymnCtrl = Get.find<HymnController>();
  final favController = Get.find<FavouriteController>();
  final audioController = Get.find<AudioController>();

  @override
  void initState() {
    super.initState();
    currentPage = widget.selectedIndex;
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void dispose() {
    audioController.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get current hymns list (reactive to changes)
      final hymns = List.from(widget.items);
      
      // If list is empty, go back
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

      // Adjust current page if out of bounds
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
          setState(() {
            currentPage = index;
          });
          audioController.stop();
        },
        itemBuilder: (context, index) {
          final hymn = hymns[index];

          return Scaffold(
            appBar: AppBar(
              title: Text('Hymn ${hymn.id}'.toUpperCase()),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  audioController.stop();
                  Get.back();
                },
              ),
              actions: [
                // Play/Stop button
                Obx(
                  () => IconButton(
                    icon: Icon(
                      audioController.isPlaying.value
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline_outlined,
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
                ),

                // Favorite button
                Obx(() {
                  final isFav = favController.isFavourite(hymn);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () {
                      favController.toggle(hymn);
                      // State will auto-update due to Obx wrapper
                    },
                  );
                }),
              ],
            ),
            body: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(5),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: FittedBox(
                      child: Text(
                        hymn.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListView(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 20,
                      ),
                      children: [
                        Obx(
                          () => Center(
                            child: Text(
                              hymn.lyrics,
                              style: TextStyle(
                                fontSize: hymnCtrl.fontSize,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: _buildFontControls(),
          );
        },
      );
    });
  }

  Widget _buildFontControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 30),
          onPressed: hymnCtrl.decreaseFontSize,
        ),
        Obx(
          () => Text(
            hymnCtrl.fontSize.toInt().toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 30),
          onPressed: hymnCtrl.increaseFontSize,
        ),
      ],
    );
  }
}