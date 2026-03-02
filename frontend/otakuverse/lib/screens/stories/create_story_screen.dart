// screens/stories/create_story_screen.dart

// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/widgets/home/stories/story_filter_selector.dart';
import 'package:otakuverse/core/widgets/home/stories/story_sticker_picker.dart';
import 'package:otakuverse/core/widgets/home/stories/story_text_editor.dart';
import 'package:otakuverse/models/stories/story_elements.dart';
import 'package:otakuverse/services/stories_service.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

enum EditMode { none, text, sticker, drawing, shape }

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  File? _selectedFile;
  String? _mediaType;
  VideoPlayerController? _videoController;
  bool _isLoading = false;

  // Mode d'édition
  EditMode _editMode = EditMode.none;

  // Éléments
  List<StoryText> _texts = [];
  List<StorySticker> _stickers = [];
  List<DrawingPath> _drawings = [];
  List<StoryShape> _shapes = [];

  // Filtres et ajustements
  ColorFilter? _currentFilter;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;

  // Couleur de fond
  Color? _backgroundColor;

  // Clé pour capture
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // Dessin en cours
  DrawingPath? _currentDrawing;
  Color _drawingColor = Colors.red;
  double _drawingStrokeWidth = 3.0;

  // Forme en cours
  ShapeType _selectedShapeType = ShapeType.rectangle;
  Offset? _shapeStartPoint;
  Offset? _shapeEndPoint;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // ============================================
  // SÉLECTION MÉDIA
  // ============================================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _mediaType = 'image';
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );

    if (video != null) {
      final file = File(video.path);
      
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();

      setState(() {
        _selectedFile = file;
        _mediaType = 'video';
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _mediaType = 'image';
      });
    }
  }

  // ============================================
  // CRÉER FOND DE COULEUR
  // ============================================
  void _createColorBackground() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'Choisir une couleur',
          style: GoogleFonts.poppins(color: AppColors.pureWhite),
        ),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
            Colors.orange,
            Colors.pink,
            Colors.teal,
            Colors.indigo,
            Colors.black,
            Colors.white,
            AppColors.crimsonRed,
          ].map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _backgroundColor = color;
                  _selectedFile = null;
                  _mediaType = 'image';
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pureWhite, width: 2),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================
  // AJOUTER TEXTE
  // ============================================
  void _addText() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StoryTextEditor(
        onTextAdded: (storyText) {
          setState(() {
            _texts.add(storyText);
          });
        },
      ),
    );
  }

  // ============================================
  // AJOUTER STICKER
  // ============================================
  void _addSticker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StoryStickerPicker(
        onStickerSelected: (emoji) {
          setState(() {
            _stickers.add(
              StorySticker(
                emoji: emoji,
                position: Offset(
                  MediaQuery.of(context).size.width / 2 - 40,
                  MediaQuery.of(context).size.height / 2 - 40,
                ),
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              ),
            );
          });
        },
      ),
    );
  }

  // ============================================
  // MODE DESSIN
  // ============================================
  void _toggleDrawingMode() {
    setState(() {
      if (_editMode == EditMode.drawing) {
        _editMode = EditMode.none;
      } else {
        _editMode = EditMode.drawing;
      }
    });
  }

  // ============================================
  // MODE FORME
  // ============================================
  void _toggleShapeMode() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choisir une forme',
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              children: [
                _buildShapeButton(ShapeType.rectangle, Icons.crop_square, 'Rectangle'),
                _buildShapeButton(ShapeType.circle, Icons.circle_outlined, 'Cercle'),
                _buildShapeButton(ShapeType.arrow, Icons.arrow_forward, 'Flèche'),
                _buildShapeButton(ShapeType.line, Icons.remove, 'Ligne'),
                _buildShapeButton(ShapeType.heart, Icons.favorite_border, 'Cœur'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeButton(ShapeType type, IconData icon, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedShapeType = type;
          _editMode = EditMode.shape;
        });
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.mediumGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.pureWhite, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.pureWhite,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FILTRES
  // ============================================
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StoryFilterSelector(
        currentFile: _selectedFile!,
        currentFilter: _currentFilter,
        brightness: _brightness,
        contrast: _contrast,
        saturation: _saturation,
        onFilterChanged: (filter, brightness, contrast, saturation) {
          setState(() {
            _currentFilter = filter;
            _brightness = brightness;
            _contrast = contrast;
            _saturation = saturation;
          });
        },
      ),
    );
  }

  // ============================================
  // ANNULER DERNIER ÉLÉMENT
  // ============================================
  void _undo() {
    setState(() {
      if (_drawings.isNotEmpty) {
        _drawings.removeLast();
      } else if (_shapes.isNotEmpty) {
        _shapes.removeLast();
      } else if (_texts.isNotEmpty) {
        _texts.removeLast();
      } else if (_stickers.isNotEmpty) {
        _stickers.removeLast();
      }
    });
  }

  // ============================================
  // CAPTURER LA STORY
  // ============================================
  Future<File?> _captureEditedStory() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData == null) return null;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/story_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(byteData.buffer.asUint8List());

      return imageFile;
    } catch (e) {
      print('❌ Error capturing story: $e');
      return null;
    }
  }

  // ============================================
  // PUBLIER
  // ============================================
  Future<void> _publishStory() async {
    if (_selectedFile == null && _backgroundColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez créer une story'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      File? fileToUpload;

      // Capturer si éditions ou fond de couleur
      if (_texts.isNotEmpty || 
          _stickers.isNotEmpty || 
          _drawings.isNotEmpty || 
          _shapes.isNotEmpty ||
          _currentFilter != null ||
          _backgroundColor != null) {
        fileToUpload = await _captureEditedStory();
        if (fileToUpload == null) {
          throw Exception('Erreur lors de la capture');
        }
      } else {
        fileToUpload = _selectedFile;
      }

      final result = await StoriesService().createStory(
        mediaFile: fileToUpload!,
        mediaType: 'image', // Toujours image après capture
      );

      if (!mounted) return;

      if (result['success'] != null) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Story publiée'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error']}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        elevation: 0,
        title: Text(
          'Créer une story',
          style: GoogleFonts.poppins(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bouton Undo
          if (_selectedFile != null || _backgroundColor != null)
            IconButton(
              icon: const Icon(Icons.undo, color: AppColors.pureWhite),
              onPressed: _undo,
            ),
          
          // Bouton Publier
          if (_selectedFile != null || _backgroundColor != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                onPressed: _isLoading ? null : _publishStory,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.crimsonRed,
                        ),
                      )
                    : Text(
                        'Publier',
                        style: GoogleFonts.inter(
                          color: AppColors.crimsonRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: _selectedFile == null && _backgroundColor == null
          ? _buildPicker()
          : _buildEditor(),
    );
  }

  // ============================================
  // SÉLECTEUR
  // ============================================
  Widget _buildPicker() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.pureWhite,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Partage un moment',
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Choisis un média ou crée un fond',
              style: GoogleFonts.inter(
                color: AppColors.mediumGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            _buildPickerButton(
              icon: Icons.camera_alt,
              label: 'Prendre une photo',
              onTap: _takePhoto,
            ),

            const SizedBox(height: 16),

            _buildPickerButton(
              icon: Icons.photo_library,
              label: 'Galerie photo',
              onTap: _pickImage,
            ),

            const SizedBox(height: 16),

            _buildPickerButton(
              icon: Icons.videocam,
              label: 'Galerie vidéo',
              onTap: _pickVideo,
            ),

            const SizedBox(height: 16),

            _buildPickerButton(
              icon: Icons.palette,
              label: 'Fond de couleur',
              onTap: _createColorBackground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mediumGray.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.crimsonRed, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.pureWhite,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ÉDITEUR
  // ============================================
  Widget _buildEditor() {
    return Column(
      children: [
        // Zone d'édition
        Expanded(
          child: GestureDetector(
            onPanStart: _editMode == EditMode.drawing || _editMode == EditMode.shape
                ? _onPanStart
                : null,
            onPanUpdate: _editMode == EditMode.drawing || _editMode == EditMode.shape
                ? _onPanUpdate
                : null,
            onPanEnd: _editMode == EditMode.drawing || _editMode == EditMode.shape
                ? _onPanEnd
                : null,
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: _backgroundColor ?? Colors.transparent,
                child: Stack(
                  children: [
                    // Image/Vidéo avec filtres
                    if (_selectedFile != null)
                      Center(
                        child: _buildMediaWithFilters(),
                      ),

                    // Dessins
                    ..._drawings.map((drawing) => CustomPaint(
                          painter: DrawingPainter(drawing),
                          size: Size.infinite,
                        )),

                    // Dessin en cours
                    if (_currentDrawing != null)
                      CustomPaint(
                        painter: DrawingPainter(_currentDrawing!),
                        size: Size.infinite,
                      ),

                    // Formes
                    ..._shapes.map((shape) => CustomPaint(
                          painter: ShapePainter(shape),
                          size: Size.infinite,
                        )),

                    // Forme en cours
                    if (_shapeStartPoint != null && _shapeEndPoint != null)
                      CustomPaint(
                        painter: ShapePainter(
                          StoryShape(
                            type: _selectedShapeType,
                            position: _shapeStartPoint!,
                            size: Size(
                              (_shapeEndPoint!.dx - _shapeStartPoint!.dx).abs(),
                              (_shapeEndPoint!.dy - _shapeStartPoint!.dy).abs(),
                            ),
                            color: _drawingColor,
                            strokeWidth: _drawingStrokeWidth,
                            id: 'temp',
                          ),
                        ),
                        size: Size.infinite,
                      ),

                    // ✅ CORRECTION : Stickers avec GestureDetector simplifié
                    ..._stickers.map((sticker) => Positioned(
                          left: sticker.position.dx,
                          top: sticker.position.dy,
                          child: GestureDetector(
                            // ✅ Utiliser UNIQUEMENT onScaleUpdate (pas onPanUpdate)
                            onScaleStart: (details) {
                              // Initialiser si nécessaire
                            },
                            onScaleUpdate: (details) {
                              setState(() {
                                // Déplacement
                                sticker.position += details.focalPointDelta;
                                
                                // Scale
                                if (details.scale != 1.0) {
                                  sticker.size *= details.scale;
                                }
                                
                                // Rotation
                                if (details.rotation != 0.0) {
                                  sticker.rotation += details.rotation;
                                }
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                _stickers.removeWhere((s) => s.id == sticker.id);
                              });
                            },
                            child: Transform.rotate(
                              angle: sticker.rotation,
                              child: Text(
                                sticker.emoji,
                                style: TextStyle(fontSize: sticker.size),
                              ),
                            ),
                          ),
                        )),

                    // ✅ CORRECTION : Textes avec GestureDetector simplifié
                    ..._texts.map((text) => Positioned(
                          left: text.position.dx,
                          top: text.position.dy,
                          child: GestureDetector(
                            // ✅ Utiliser UNIQUEMENT onScaleUpdate (pas onPanUpdate)
                            onScaleStart: (details) {
                              // Initialiser si nécessaire
                            },
                            onScaleUpdate: (details) {
                              setState(() {
                                // Déplacement
                                text.position += details.focalPointDelta;
                                
                                // Scale
                                if (details.scale != 1.0) {
                                  text.scale *= details.scale;
                                }
                                
                                // Rotation
                                if (details.rotation != 0.0) {
                                  text.rotation += details.rotation;
                                }
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                _texts.removeWhere((t) => t.id == text.id);
                              });
                            },
                            child: Transform.scale(
                              scale: text.scale,
                              child: Transform.rotate(
                                angle: text.rotation,
                                child: _buildStyledText(text),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Barre d'outils
        _buildToolbar(),
      ],
    );
  }
  // Suite dans le prochain message...
  // screens/stories/create_story_screen.dart (SUITE)

  // ============================================
  // MÉDIA AVEC FILTRES
  // ============================================
  Widget _buildMediaWithFilters() {
    Widget mediaWidget;

    if (_mediaType == 'video' && _videoController != null) {
      mediaWidget = AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    } else {
      mediaWidget = Image.file(
        _selectedFile!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Appliquer les filtres
    if (_currentFilter != null) {
      mediaWidget = ColorFiltered(
        colorFilter: _currentFilter!,
        child: mediaWidget,
      );
    }

    // Appliquer luminosité/contraste/saturation
    if (_brightness != 0.0 || _contrast != 1.0 || _saturation != 1.0) {
      mediaWidget = ColorFiltered(
        colorFilter: ColorFilter.matrix(_buildColorMatrix()),
        child: mediaWidget,
      );
    }

    return mediaWidget;
  }

  // Matrice de couleur personnalisée
  List<double> _buildColorMatrix() {
    final brightness = _brightness;
    final contrast = _contrast;
    final saturation = _saturation;

    return [
      contrast * saturation, 0, 0, 0, brightness,
      0, contrast * saturation, 0, 0, brightness,
      0, 0, contrast * saturation, 0, brightness,
      0, 0, 0, 1, 0,
    ];
  }

  // ============================================
  // TEXTE STYLISÉ
  // ============================================
  Widget _buildStyledText(StoryText text) {
    TextStyle textStyle = GoogleFonts.inter(
      color: text.color,
      fontSize: text.fontSize,
      fontWeight: text.fontStyle == 'bold' ? FontWeight.bold : FontWeight.w600,
      fontStyle: text.fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal,
    );

    Widget textWidget = Text(
      text.text,
      style: textStyle,
      textAlign: text.alignment,
    );

    // Style Neon
    if (text.fontStyle == 'neon') {
      textWidget = Stack(
        children: [
          Text(
            text.text,
            style: textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = text.color.withOpacity(0.5),
            ),
            textAlign: text.alignment,
          ),
          Text(
            text.text,
            style: textStyle.copyWith(
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: text.color,
                ),
                Shadow(
                  blurRadius: 20,
                  color: text.color,
                ),
              ],
            ),
            textAlign: text.alignment,
          ),
        ],
      );
    }

    // Style Outlined
    if (text.fontStyle == 'outlined') {
      textWidget = Stack(
        children: [
          Text(
            text.text,
            style: textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = Colors.black,
            ),
            textAlign: text.alignment,
          ),
          Text(
            text.text,
            style: textStyle,
            textAlign: text.alignment,
          ),
        ],
      );
    }

    // Fond
    if (text.backgroundColor != Colors.transparent) {
      textWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: text.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: textWidget,
      );
    }

    return textWidget;
  }

  // ============================================
  // GESTION DU DESSIN
  // ============================================
  void _onPanStart(DragStartDetails details) {
    if (_editMode == EditMode.drawing) {
      setState(() {
        _currentDrawing = DrawingPath(
          points: [details.localPosition],
          color: _drawingColor,
          strokeWidth: _drawingStrokeWidth,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      });
    } else if (_editMode == EditMode.shape) {
      setState(() {
        _shapeStartPoint = details.localPosition;
        _shapeEndPoint = details.localPosition;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_editMode == EditMode.drawing && _currentDrawing != null) {
      setState(() {
        _currentDrawing!.points.add(details.localPosition);
      });
    } else if (_editMode == EditMode.shape) {
      setState(() {
        _shapeEndPoint = details.localPosition;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_editMode == EditMode.drawing && _currentDrawing != null) {
      setState(() {
        _drawings.add(_currentDrawing!);
        _currentDrawing = null;
      });
    } else if (_editMode == EditMode.shape && 
               _shapeStartPoint != null && 
               _shapeEndPoint != null) {
      setState(() {
        _shapes.add(
          StoryShape(
            type: _selectedShapeType,
            position: _shapeStartPoint!,
            size: Size(
              (_shapeEndPoint!.dx - _shapeStartPoint!.dx).abs(),
              (_shapeEndPoint!.dy - _shapeStartPoint!.dy).abs(),
            ),
            color: _drawingColor,
            strokeWidth: _drawingStrokeWidth,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        );
        _shapeStartPoint = null;
        _shapeEndPoint = null;
        _editMode = EditMode.none;
      });
    }
  }

  // ============================================
  // BARRE D'OUTILS
  // ============================================
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
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
          // Palette de couleurs pour dessin
          if (_editMode == EditMode.drawing || _editMode == EditMode.shape)
            _buildDrawingControls(),

          // Outils principaux
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildToolButton(
                  icon: Icons.text_fields,
                  label: 'Texte',
                  isActive: _editMode == EditMode.text,
                  onTap: _addText,
                ),
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.emoji_emotions,
                  label: 'Sticker',
                  isActive: _editMode == EditMode.sticker,
                  onTap: _addSticker,
                ),
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.brush,
                  label: 'Dessin',
                  isActive: _editMode == EditMode.drawing,
                  onTap: _toggleDrawingMode,
                ),
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.crop_square,
                  label: 'Forme',
                  isActive: _editMode == EditMode.shape,
                  onTap: _toggleShapeMode,
                ),
                if (_mediaType == 'image') ...[
                  const SizedBox(width: 12),
                  _buildToolButton(
                    icon: Icons.filter,
                    label: 'Filtre',
                    onTap: _showFilters,
                  ),
                ],
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.refresh,
                  label: 'Changer',
                  onTap: () {
                    setState(() {
                      _selectedFile = null;
                      _mediaType = null;
                      _backgroundColor = null;
                      _texts.clear();
                      _stickers.clear();
                      _drawings.clear();
                      _shapes.clear();
                      _currentFilter = null;
                      _videoController?.dispose();
                      _videoController = null;
                      _editMode = EditMode.none;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.crimsonRed : AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.pureWhite,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.pureWhite,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CONTRÔLES DE DESSIN
  // ============================================
  Widget _buildDrawingControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Couleurs
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
                  onTap: () => setState(() => _drawingColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _drawingColor == color
                            ? AppColors.crimsonRed
                            : AppColors.mediumGray,
                        width: _drawingColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Épaisseur du trait
          Row(
            children: [
              const Icon(Icons.line_weight, color: AppColors.pureWhite, size: 20),
              Expanded(
                child: Slider(
                  value: _drawingStrokeWidth,
                  min: 1,
                  max: 20,
                  activeColor: AppColors.crimsonRed,
                  onChanged: (value) {
                    setState(() => _drawingStrokeWidth = value);
                  },
                ),
              ),
              Text(
                '${_drawingStrokeWidth.toInt()}px',
                style: GoogleFonts.inter(
                  color: AppColors.pureWhite,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// PAINTER POUR LE DESSIN
// ============================================
class DrawingPainter extends CustomPainter {
  final DrawingPath drawingPath;

  DrawingPainter(this.drawingPath);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = drawingPath.color
      ..strokeWidth = drawingPath.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < drawingPath.points.length - 1; i++) {
      if (drawingPath.points[i] != null && drawingPath.points[i + 1] != null) {
        canvas.drawLine(
          drawingPath.points[i],
          drawingPath.points[i + 1],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

// ============================================
// PAINTER POUR LES FORMES
// ============================================
class ShapePainter extends CustomPainter {
  final StoryShape shape;

  ShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = shape.color
      ..strokeWidth = shape.strokeWidth
      ..style = shape.filled ? PaintingStyle.fill : PaintingStyle.stroke;

    canvas.save();
    canvas.translate(shape.position.dx, shape.position.dy);
    canvas.rotate(shape.rotation);

    switch (shape.type) {
      case ShapeType.rectangle:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, shape.size.width, shape.size.height),
          paint,
        );
        break;

      case ShapeType.circle:
        final radius = (shape.size.width + shape.size.height) / 4;
        canvas.drawCircle(
          Offset(shape.size.width / 2, shape.size.height / 2),
          radius,
          paint,
        );
        break;

      case ShapeType.line:
        canvas.drawLine(
          Offset.zero,
          Offset(shape.size.width, shape.size.height),
          paint,
        );
        break;

      case ShapeType.arrow:
        final path = Path();
        path.moveTo(0, shape.size.height / 2);
        path.lineTo(shape.size.width * 0.7, shape.size.height / 2);
        path.lineTo(shape.size.width * 0.7, 0);
        path.lineTo(shape.size.width, shape.size.height / 2);
        path.lineTo(shape.size.width * 0.7, shape.size.height);
        path.lineTo(shape.size.width * 0.7, shape.size.height / 2);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case ShapeType.heart:
        final path = Path();
        final width = shape.size.width;
        final height = shape.size.height;
        path.moveTo(width / 2, height * 0.35);
        path.cubicTo(
          width * 0.2, 0, 
          0, height * 0.3, 
          width / 2, height,
        );
        path.moveTo(width / 2, height * 0.35);
        path.cubicTo(
          width * 0.8, 0, 
          width, height * 0.3, 
          width / 2, height,
        );
        canvas.drawPath(path, paint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) => true;
}