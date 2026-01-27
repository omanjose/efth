import 'package:efth/app/screens/hymn_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/favorite_controller.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favController = Get.find<FavouriteController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Favourite Hymns'),
      leading: IconButton(onPressed: ()=>Get.back(), icon: Icon(Icons.arrow_back_ios)),),
      body: Obx(() {
        if (favController.favouriteHymns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 35,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorite hymns yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add hymns to favorites from the home screen',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: favController.favouriteHymns.length,
          itemBuilder: (_, i) {
            final hymn = favController.favouriteHymns[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  // backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${hymn.id}',
                    style:  TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  hymn.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),

                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hymn.language,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: (){
                  final userSelection = favController.favouriteHymns.indexOf(hymn);
                  Get.to(()=>HymnDetailScreen(
                      selectedIndex: userSelection, items:favController.favouriteHymns,
                  ));

            }));
          },
        );
      }),
    );
  }
}
