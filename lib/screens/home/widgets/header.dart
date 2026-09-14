import 'package:flutter/material.dart';
import 'package:indina/core/constants/app_colors.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.gamepad_rounded, color: Color(0xFF092117)),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Text(
            'INDIVERSE',
            style: TextStyle(
              fontFamily: 'Michroma',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
