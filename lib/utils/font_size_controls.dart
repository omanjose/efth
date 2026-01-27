import 'package:flutter/material.dart';


class FontSizeControls extends StatelessWidget {
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;


  const FontSizeControls({
    super.key,
    required this.onIncrease,
    required this.onDecrease,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.remove), onPressed: onDecrease),
        IconButton(icon: const Icon(Icons.add), onPressed: onIncrease),
      ],
    );
  }
}