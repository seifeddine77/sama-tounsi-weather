import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Script pour générer l'icône de l'application
// Cette icône sera utilisée pour Android et iOS

void main() async {
  // Créer l'icône
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = 1024.0;
  
  // Fond dégradé
  final bgPaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF667EEA),
        Color(0xFF764BA2),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size, size));
  
  // Dessiner le fond arrondi
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      const Radius.circular(200),
    ),
    bgPaint,
  );
  
  // Dessiner le soleil
  final sunPaint = Paint()
    ..shader = const LinearGradient(
      colors: [
        Color(0xFFFFD700),
        Color(0xFFFFA500),
      ],
    ).createShader(Rect.fromLTWH(200, 200, 300, 300));
  
  // Rayons du soleil
  final rayPaint = Paint()
    ..color = const Color(0xFFFFD700).withOpacity(0.8)
    ..style = PaintingStyle.fill;
  
  // Dessiner 8 rayons
  for (int i = 0; i < 8; i++) {
    canvas.save();
    canvas.translate(350, 350);
    canvas.rotate(i * 0.785); // 45 degrés en radians
    canvas.drawRect(
      const Rect.fromLTWH(-15, -180, 30, 100),
      rayPaint,
    );
    canvas.restore();
  }
  
  // Corps du soleil
  canvas.drawCircle(
    const Offset(350, 350),
    120,
    sunPaint,
  );
  
  // Dessiner le nuage
  final cloudPaint = Paint()
    ..color = Colors.white.withOpacity(0.95)
    ..style = PaintingStyle.fill;
  
  // Parties du nuage
  canvas.drawOval(
    const Rect.fromLTWH(450, 500, 200, 120),
    cloudPaint,
  );
  canvas.drawOval(
    const Rect.fromLTWH(550, 480, 250, 150),
    cloudPaint,
  );
  canvas.drawOval(
    const Rect.fromLTWH(650, 510, 180, 100),
    cloudPaint,
  );
  canvas.drawOval(
    const Rect.fromLTWH(500, 550, 280, 120),
    cloudPaint,
  );
  
  // Gouttes de pluie
  final rainPaint = Paint()
    ..color = const Color(0xFF4FC3F7).withOpacity(0.8)
    ..style = PaintingStyle.fill;
  
  // Dessiner 3 gouttes
  final dropPath = Path();
  
  // Goutte 1
  dropPath.moveTo(520, 700);
  dropPath.quadraticBezierTo(520, 680, 530, 670);
  dropPath.quadraticBezierTo(540, 680, 540, 700);
  dropPath.quadraticBezierTo(540, 720, 530, 730);
  dropPath.quadraticBezierTo(520, 720, 520, 700);
  
  // Goutte 2
  dropPath.moveTo(620, 720);
  dropPath.quadraticBezierTo(620, 700, 630, 690);
  dropPath.quadraticBezierTo(640, 700, 640, 720);
  dropPath.quadraticBezierTo(640, 740, 630, 750);
  dropPath.quadraticBezierTo(620, 740, 620, 720);
  
  // Goutte 3
  dropPath.moveTo(720, 700);
  dropPath.quadraticBezierTo(720, 680, 730, 670);
  dropPath.quadraticBezierTo(740, 680, 740, 700);
  dropPath.quadraticBezierTo(740, 720, 730, 730);
  dropPath.quadraticBezierTo(720, 720, 720, 700);
  
  canvas.drawPath(dropPath, rainPaint);
  
  print('Icône générée avec succès !');
  print('Utilisez flutter_launcher_icons pour générer les icônes de l\'application');
}
