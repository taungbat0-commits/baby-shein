import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';

class AudioControlBar extends StatelessWidget {
  final VoidCallback onListen;
  final VoidCallback? onListenMy;
  final VoidCallback onSlow;
  final VoidCallback onRepeat;
  final Color primaryColor;

  const AudioControlBar({
    super.key,
    required this.onListen,
    this.onListenMy,
    required this.onSlow,
    required this.onRepeat,
    this.primaryColor = AppColors.skyBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: BouncyButton(
                onTap: onListen,
                color: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'EN • အင်္ဂလိပ်',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onListenMy != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: BouncyButton(
                  onTap: onListenMy,
                  color: AppColors.softPink,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🇲🇲', style: TextStyle(fontSize: 17)),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'MY • မြန်မာ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: BouncyButton(
                onTap: onSlow,
                color: AppColors.sunYellowLight,
                border: Border.all(color: AppColors.sunYellow, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🐢', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text(
                      'Slow • ဖြည်းဖြည်း',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BouncyButton(
                onTap: onRepeat,
                color: AppColors.mintGreenLight,
                border: Border.all(color: AppColors.mintGreen, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, color: AppColors.mintGreen, size: 18),
                    SizedBox(width: 5),
                    Text(
                      'Repeat • ထပ်နားထောင်',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
