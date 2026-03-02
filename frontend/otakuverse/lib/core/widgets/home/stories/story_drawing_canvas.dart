import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/models/stories/story_elements.dart';

class StoryDrawingCanvas extends StatefulWidget {
  final List<DrawingPath> drawings;
  final Function(DrawingPath) onDrawingAdded;

  const StoryDrawingCanvas({
    super.key,
    required this.drawings,
    required this.onDrawingAdded,
  });

  @override
  State<StoryDrawingCanvas> createState() => _StoryDrawingCanvasState();
}

class _StoryDrawingCanvasState extends State<StoryDrawingCanvas> {
  DrawingPath? _currentDrawing;
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Zone de dessin
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _currentDrawing = DrawingPath(
                  points: [details.localPosition],
                  color: _selectedColor,
                  strokeWidth: _strokeWidth,
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                );
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _currentDrawing?.points.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              if (_currentDrawing != null) {
                widget.onDrawingAdded(_currentDrawing!);
                setState(() => _currentDrawing = null);
              }
            },
            child: CustomPaint(
              painter: DrawingCanvasPainter(
                drawings: widget.drawings,
                currentDrawing: _currentDrawing,
              ),
              size: Size.infinite,
            ),
          ),

          // Barre d'outils
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Palette de couleurs
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple,
                        Colors.orange,
                        Colors.pink,
                        Colors.white,
                        Colors.black,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? AppColors.crimsonRed
                                    : AppColors.mediumGray,
                                width: _selectedColor == color ? 3 : 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Épaisseur du trait
                  Row(
                    children: [
                      const Icon(
                        Icons.line_weight,
                        color: AppColors.pureWhite,
                        size: 20,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.crimsonRed,
                            inactiveTrackColor: AppColors.mediumGray,
                            thumbColor: AppColors.crimsonRed,
                          ),
                          child: Slider(
                            value: _strokeWidth,
                            min: 1,
                            max: 20,
                            onChanged: (value) {
                              setState(() => _strokeWidth = value);
                            },
                          ),
                        ),
                      ),
                      Text(
                        '${_strokeWidth.toInt()}px',
                        style: GoogleFonts.inter(
                          color: AppColors.pureWhite,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter pour le canvas
class DrawingCanvasPainter extends CustomPainter {
  final List<DrawingPath> drawings;
  final DrawingPath? currentDrawing;

  DrawingCanvasPainter({
    required this.drawings,
    this.currentDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner tous les chemins existants
    for (var drawing in drawings) {
      _drawPath(canvas, drawing);
    }

    // Dessiner le chemin en cours
    if (currentDrawing != null) {
      _drawPath(canvas, currentDrawing!);
    }
  }

  void _drawPath(Canvas canvas, DrawingPath drawing) {
    final paint = Paint()
      ..color = drawing.color
      ..strokeWidth = drawing.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < drawing.points.length - 1; i++) {
      canvas.drawLine(
        drawing.points[i],
        drawing.points[i + 1],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DrawingCanvasPainter oldDelegate) => true;
}