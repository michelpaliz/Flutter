import 'package:flutter/material.dart';

class RepetitionToggleWidget extends StatelessWidget {
  final bool isRepetitive;
  final double toggleWidth;
  final VoidCallback onTap;

  const RepetitionToggleWidget({
    Key? key,
    required this.isRepetitive,
    required this.toggleWidth,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Repeat Event:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onTap,
          child: Container(
            width: toggleWidth,
            height: 30,
            decoration: BoxDecoration(
              color: isRepetitive ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              isRepetitive ? 'Yes' : 'No',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
