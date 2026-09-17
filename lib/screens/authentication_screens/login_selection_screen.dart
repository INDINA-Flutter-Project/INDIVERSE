import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/widget/glass_action.dart';
import 'developer_login/developer_login_screen.dart';
import 'user_login/user_login_screen.dart';
import 'widgets/auth_background.dart';

class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AuthDecoratedBackground(
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final brand = Curves.easeOutExpo.transform(
              (_controller.value / .6).clamp(0.0, 1.0),
            );
            final panel = Curves.easeOutExpo.transform(
              ((_controller.value - .25) / .75).clamp(0.0, 1.0),
            );
            return Column(
              children: [
                const SizedBox(height: 36),
                Opacity(
                  opacity: brand,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - brand)),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/indiverse_logo.webp',
                          width: 150,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Saudi indie games, all in one place.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Opacity(
                  opacity: brand,
                  child: const _FeatureRow(),
                ),
                const Spacer(),
                Opacity(
                  opacity: panel,
                  child: Transform.translate(
                    offset: Offset(0, 26 * (1 - panel)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AuthGlassPanel(
                        padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Continue as',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 14),
                            _RoleButton(
                              label: 'User',
                              subtitle: 'Discover and follow indie games',
                              icon: const Icon(Icons.person_rounded),
                              filled: true,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserLoginScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _RoleButton(
                              label: 'Developer',
                              subtitle: 'Publish builds and reach players',
                              icon: const Icon(Icons.code_rounded),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DeveloperLoginScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  static const _items = [
    (Icons.explore_outlined, 'Discover'),
    (Icons.favorite_border_rounded, 'Follow'),
    (Icons.groups_2_outlined, 'Connect'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final item in _items)
            Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .1),
                    ),
                  ),
                  child: Icon(item.$1, color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  item.$2,
                  style: AppTextStyles.interface.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.subtitle,
    this.filled = false,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final String subtitle;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accent = filled ? const Color(0xFF06170F) : AppColors.primary;
    final labelStyle = AppTextStyles.interface.copyWith(
      color: accent,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    );
    final subtitleStyle = AppTextStyles.interface.copyWith(
      color: filled
          ? const Color(0xFF06170F).withValues(alpha: .68)
          : AppColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final content = Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? Colors.black.withValues(alpha: .12)
                : AppColors.primary.withValues(alpha: .12),
          ),
          child: IconTheme(
            data: IconThemeData(color: accent, size: 20),
            child: icon,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(height: 2),
              Text(subtitle, style: subtitleStyle),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: accent, size: 22),
      ],
    );

    if (!filled) {
      return GlassAction(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: content,
          ),
        ),
      ),
    );
  }
}
