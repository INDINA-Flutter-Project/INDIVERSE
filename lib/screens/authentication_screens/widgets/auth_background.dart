import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthDecoratedBackground extends StatelessWidget {
  const AuthDecoratedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.background)),
        const Positioned.fill(child: CustomPaint(painter: _AuthGlowPainter())),
        Positioned.fill(child: child),
      ],
    );
  }
}

class AuthGlassPanel extends StatelessWidget {
  const AuthGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 38,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.36),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthSegmentedControl extends StatelessWidget {
  const AuthSegmentedControl({
    super.key,
    required this.signUpSelected,
    required this.onChanged,
  });

  final bool signUpSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
      ),
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOutCubic,
              alignment: signUpSelected
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: .5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF37F2A0), Color(0xFF08CE7E)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .22),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _SegmentButton(
                    label: 'Login',
                    selected: !signUpSelected,
                    onTap: () => onChanged(false),
                  ),
                ),
                Expanded(
                  child: _SegmentButton(
                    label: 'Sign up',
                    selected: signUpSelected,
                    onTap: () => onChanged(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [Color(0xFF37F2A0), Color(0xFF03C878)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: disabled ? AppColors.border : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.26),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: AppColors.background,
          disabledForegroundColor: AppColors.textSecondary,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.background,
                ),
              )
            : Text(label),
      ),
    );
  }
}

InputDecoration authFieldDecoration({
  required String label,
  String? hint,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.045),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.90),
              fontFamily: 'Sora',
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: selected ? AppColors.background : AppColors.textSecondary,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _AuthGlowPainter extends CustomPainter {
  const _AuthGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.42),
              AppColors.primary.withValues(alpha: 0.07),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.78, size.height * 0.04),
              radius: size.width * 0.62,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.04),
      size.width * 0.62,
      topGlow,
    );

    final lowerGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.28),
              AppColors.primary.withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.48, size.height * 0.76),
              radius: size.width * 0.72,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.76),
      size.width * 0.72,
      lowerGlow,
    );

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.primary.withValues(alpha: 0.34)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      Offset(size.width * 0.76, -size.height * 0.08),
      size.width * 0.54,
      arcPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 1.12),
      size.width * 0.74,
      arcPaint,
    );

    final dimOverlay = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, dimOverlay);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
