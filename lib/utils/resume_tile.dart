
import 'package:flutter/material.dart';
 
class ResumeTile extends StatelessWidget {
  const ResumeTile({super.key, 
    required this.partialBytes,
    required this.onResume,
    required this.onDiscard,
  });
 
  final int partialBytes;
  final VoidCallback onResume;
  final VoidCallback onDiscard;
 
  String get _savedMb => (partialBytes / 1048576).toStringAsFixed(1);
 
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
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.pause_circle_outline_rounded,
                size: 18, color: Colors.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Download Paused',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: cs.onSurface),
                ),
                Text(
                  '$_savedMb MB saved — tap to resume',
                  style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange),
                ),
              ],
            ),
          ),
          // Resume button
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            color: Colors.orange,
            onPressed: onResume,
            tooltip: 'Resume download',
          ),
          // Discard button
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: cs.onSurfaceVariant.withOpacity(0.5),
            onPressed: onDiscard,
            tooltip: 'Discard and start over',
          ),
        ],
      ),
    );
  }
}