import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.darkGray,
          side: BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColors.darkGray.withOpacity(0.5),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightGray),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Google en SVG natif Flutter
                  _GoogleLogo(),
                  const SizedBox(width: 12),
                  Text(
                    'Continuer avec Google',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Bleu — quart haut-gauche
    final paintBlue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    // Rouge — quart haut-droit
    final paintRed = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    // Jaune — quart bas-droit
    final paintYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    // Vert — quart bas-gauche
    final paintGreen = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Dessiner les 4 quarts colorés
    canvas.drawArc(rect, -3.14159, 3.14159 / 2, true, paintBlue);   // gauche haut
    canvas.drawArc(rect, -3.14159 / 2, 3.14159 / 2, true, paintRed); // droit haut
    canvas.drawArc(rect, 0, 3.14159 / 2, true, paintYellow);          // droit bas
    canvas.drawArc(rect, 3.14159 / 2, 3.14159 / 2, true, paintGreen); // gauche bas

    // Cercle blanc central (trou du logo)
    final paintWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.58, paintWhite);

    // Barre horizontale du "G"
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx, cy - r * 0.2, r * 0.95, r * 0.4),
      Radius.circular(r * 0.1),
    );
    canvas.drawRRect(barRect, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}