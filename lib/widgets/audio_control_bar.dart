import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';

class AudioControlBar extends StatelessWidget {
  final VoidCallback onListen;
  final VoidCallback onSlow;
  final VoidCallback onRepeat;
  final Color primaryColor;

  const AudioControlBar({
    super.key,
    required this.onListen,
    required this.onSlow,
    required this.onRepeat,
    this.primaryColor = AppColors.skyBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: BouncyButton(
            onTap: onListen,
            color: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volume_up_rounded, color: Colors.white, size: 24),
                SizedBox(width: 6),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Listen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'နားထောင်မယ်',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: BouncyButton(
            onTap: onSlow,
            color: AppColors.sunYellowLight,
            border: Border.all(color: AppColors.sunYellow, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🐢', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Text(
                      'Slow',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ဖြည်းဖြည်း',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: BouncyButton(
            onTap: onRepeat,
            color: AppColors.mintGreenLight,
            border: Border.all(color: AppColors.mintGreen, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, color: AppColors.mintGreen, size: 18),
                    SizedBox(width: 3),
                    Text(
                      'Repeat',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ထပ်နားထောင်',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
