import 'package:efth/app/screens/hymn_detail_screen.dart';
import 'package:efth/app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/hymn_controller.dart';
import '../controller/search_controller.dart';
import 'favorite_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hymnCtrl = Get.find<HymnController>();
final searchCtrl = Get.find<SearchQueryController>();

   return  Scaffold(
      appBar: AppBar(
        title: const Text('e-FTH'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Get.to(()=>FavouriteScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(()=>SettingsView()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _buildLanguageChip('English', 'english'),
                const SizedBox(width: 8),
                _buildLanguageChip('Igbo', 'igbo'),
                const SizedBox(width: 8),
                _buildLanguageChip('Efik', 'efik'),
              ],
            ),
          )),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 45,
              child: TextField(
                controller: searchCtrl.queryController,
              onChanged: (v) => searchCtrl.query.value = v,
                decoration: InputDecoration(
                  hintText: 'Search hymns by title or number...',
                  prefixIcon: const Icon(Icons.search),
                   border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                ),
              ),
            ),
          ),

          Obx(() {
            final list = searchCtrl.filter(hymnCtrl.hymns);
            if (hymnCtrl.isLoading||hymnCtrl.hymns.isEmpty) {
              return  Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 24,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
              );
            }
            // final hymns = hymnCtrl.filteredHymns;

            if (list.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hymns found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                itemCount: list.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final hymn = list[index];

                  return SizedBox(
                    height: 60,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 5),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        leading: Container(
                          width: 48,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${hymn.id}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          hymn.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        onTap: (){
                          final userSelection = hymnCtrl.allHymns.indexOf(hymn);
                          Get.to(()=>HymnDetailScreen(
                            selectedIndex: userSelection, items:hymnCtrl.allHymns
                          ));
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String label, String value) {
    final controller=Get.find<HymnController>();
    final isSelected = controller.language.value == value;

    return Expanded(
      child: FilterChip(
        avatar: Icon(Icons.music_note_outlined),
        backgroundColor: isSelected?Colors.green:null,
        label: SizedBox(
          width: 50,
          child: Text(
            label,textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.language.value = value;
            // Get.find<ThemeService>().changeLanguage(value);
          }
        },
        showCheckmark: false,
      ),
    );
  }
}