import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color textColor;

  const AppLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo ikonu
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan yeşil daire
              Container(
                width: size * 0.75,
                height: size * 0.75,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(size * 0.18),
                ),
              ),
              // Yaprak ikonu
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_rounded, color: Colors.white, size: size * 0.38),
                  Text(
                    'F',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.w900,
                      height: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (showText) ...[
          SizedBox(width: size * 0.2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Foodsense',
                      style: TextStyle(
                        color: textColor,
                        fontSize: size * 0.42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'AI',
                      style: TextStyle(
                        color: const Color(0xFF66BB6A),
                        fontSize: size * 0.42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Akıllı Beslenme Asistanı',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.65),
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}