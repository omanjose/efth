import 'package:efth/app/controller/hymn_controller.dart';
import 'package:efth/app/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final hymnCtrl= Get.put(HymnController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(onPressed: ()=>Get.back(), icon: Icon(Icons.arrow_back_ios)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          _buildSection(
            'Appearance',
            [
              Obx(() => ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                subtitle: Text(controller.getThemeModeString()),
                trailing: DropdownButton<ThemeMode>(
                  value: controller.themeService.themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) controller.changeTheme(mode);
                  },
                ),
              )),
              Obx(() => ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(hymnCtrl.language.value.toUpperCase()),
                // subtitle: Text(controller.themeService.currentLanguage.value),
                trailing: DropdownButton<String>(
                  value: hymnCtrl.language.value,
                  // value: controller.themeService.currentLanguage.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'english',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'igbo',
                      child: Text('Igbo'),
                    ),
                    DropdownMenuItem(
                      value: 'efik',
                      child: Text('Efik'),
                    ),
                  ],
                  onChanged: (lang) {
                    if (lang != null) hymnCtrl.changeLanguage(lang);
                  },
                ),
              )),
            ],
          ),
          const SizedBox(height: 10),
          // Card(
          //     child: Column(
          //       children: [
          //         ListTile(
          //           leading: const CircleAvatar(
          //             backgroundColor: Color(0xFFE8EAF6),
          //             child: Icon(Icons.help_outline, color: Color(0xFF3F51B5)),
          //           ),
          //           title: const Text('Help & Support'),
          //           subtitle: const Text('Get help and contact support'),
          //           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //           onTap: () {
          //             Get.bottomSheet(
          //               Container(
          //                 padding: const EdgeInsets.all(24),
          //                 decoration: const BoxDecoration(
          //                   color: Colors.white,
          //                   borderRadius: BorderRadius.vertical(
          //                     top: Radius.circular(20),
          //                   ),
          //                 ),
          //                 child: Column(
          //                   mainAxisSize: MainAxisSize.min,
          //                   crossAxisAlignment: CrossAxisAlignment.stretch,
          //                   children: [
          //                     const Text(
          //                       'Help & Support',
          //                       style: TextStyle(
          //                         fontSize: 20,
          //                         fontWeight: FontWeight.bold,
          //                       ),
          //                     ),
          //                     const SizedBox(height: 16),
          //                     const Text('Contact us:'),
          //                     const SizedBox(height: 8),
          //                     const Text('📧 Email: joshuaoleh@gmail.com'),
          //                     const Text('📱 Phone: +234 (703) 430-7977'),
          //                     const Text('🌐 Website: www.joshuaoleh.com'),
          //                     const SizedBox(height: 16),
          //                     ElevatedButton(
          //                       onPressed: () => Get.back(),
          //                       child: const Text('Close'),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //         const Divider(height: 1),
          //         ListTile(
          //           leading: const CircleAvatar(
          //             backgroundColor: Color(0xFFFCE4EC),
          //             child: Icon(Icons.bug_report_outlined, color: Color(0xFFE91E63)),
          //           ),
          //           title: const Text('Report a Bug'),
          //           subtitle: const Text('Help us improve the app'),
          //           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //           onTap: () {
          //             Get.snackbar(
          //               'Thank You',
          //               'Bug reporting feature coming soon',
          //               snackPosition: SnackPosition.BOTTOM,
          //             );
          //           },
          //         ),
          //         const Divider(height: 1),
          //         ListTile(
          //           leading: const CircleAvatar(
          //             backgroundColor: Color(0xFFF3E5F5),
          //             child: Icon(Icons.info_outline, color: Color(0xFF9C27B0)),
          //           ),
          //           title: const Text('About'),
          //           subtitle: const Text('Version 1.0.0'),
          //           onTap: () {
          //             showAboutDialog(
          //               context: context,
          //               applicationName: 'Loan Predictor',
          //               applicationVersion: '1.0.0',
          //               applicationIcon: Container(
          //                 padding: const EdgeInsets.all(8),
          //                 decoration: BoxDecoration(
          //                   gradient: LinearGradient(
          //                     colors: [
          //                       Theme.of(context).primaryColor,
          //                       Theme.of(context).colorScheme.secondary,
          //                     ],
          //                   ),
          //                   borderRadius: BorderRadius.circular(12),
          //                 ),
          //                 child: const Icon(
          //                   Icons.account_balance_wallet,
          //                   color: Colors.white,
          //                   size: 32,
          //                 ),
          //               ),
          //               children: [
          //                 const SizedBox(height: 16),
          //                 const Text(
          //                   'An intelligent micro-loan repayment prediction app '
          //                       'that helps you manage loans with advanced analytics '
          //                       'and machine learning predictions.',
          //                   textAlign: TextAlign.center,
          //                 ),
          //                 const SizedBox(height: 16),
          //                 const Text(
          //                   'Features:',
          //                   style: TextStyle(fontWeight: FontWeight.bold),
          //                 ),
          //                 const Text('• AI-powered repayment predictions'),
          //                 const Text('• Comprehensive loan management'),
          //                 const Text('• Visual analytics dashboard'),
          //                 const Text('• Offline-first architecture'),
          //                 const Text('• Secure local data storage'),
          //                 const SizedBox(height: 16),
          //                 const Text(
          //                   '© 2026 eFTH. All rights reserved.',
          //                   style: TextStyle(fontSize: 12, color: Colors.grey),
          //                   textAlign: TextAlign.center,
          //                 ),
          //               ],
          //             );
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          // const Divider(),
          _buildSection(
            'About',
            [
              const ListTile(
                leading: CircleAvatar(
                      backgroundColor: Color(0xFFE8EAF6),
                      child: Icon(Icons.info_outline, color: Color(0xFF3F51B5)),
                    ),
                title: Text('App Version'),
                subtitle: Text('1.0.0'),
                trailing: Icon(Icons.arrow_forward_ios,size: 12),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3E5F5),
                      child: Icon(Icons.info_outline, color: Color(0xFF9C27B0)),
                    ),
                title: const Text('About App'),
                subtitle: const Text('Multilingual hymn book with audio'),
                onTap: () => _showAboutDialog(context),
                trailing: Icon(Icons.arrow_forward_ios,size: 12),
              ),
               const Divider(),
              ListTile(
                leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8EAF6),
                      child: Icon(Icons.help_outline, color: Color(0xFF3F51B5)),
                    ),
                title: const Text('Developer Info'),
                subtitle: const Text('Tap to view details'),
                onTap: () => _showDeveloperDialog(context),
                trailing: Icon(Icons.arrow_forward_ios,size: 12),
              ),
               
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About e-Fth'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A comprehensive multilingual hymn book application featuring:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• English, Igbo, and Efik translations'),
              Text('• Audio playback for hymns'),
              Text('• Favorite hymns collection'),
              Text('• Adjustable font sizes'),
              Text('• Light and dark themes'),
              Text('• Offline functionality'),
              SizedBox(height: 12),
              Text(
                'Perfect for worship, study, and spiritual growth.',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Information'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Developed with ❤️ using Flutter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('HallmarkSolutions'),
            SizedBox(height: 8),
            Text('• Aba, Nigeria'),
            Text('• +234-703-430-7977'),
            SizedBox(height: 10),
            Text('Contact: developer@hymnbook.com'),
            Text('Version: 1.0.0'),
            SizedBox(height: 10),
            Text(
                            '© 2026 eFTH. All rights reserved.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
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