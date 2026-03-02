import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/models/stories/story_elements.dart';

class StoryTextEditor extends StatefulWidget {
  final Function(StoryText) onTextAdded;

  const StoryTextEditor({
    super.key,
    required this.onTextAdded,
  });

  @override
  State<StoryTextEditor> createState() => _StoryTextEditorState();
}

class _StoryTextEditorState extends State<StoryTextEditor> {
  final TextEditingController _controller = TextEditingController();
  Color _textColor = Colors.white;
  Color _bgColor = Colors.transparent;
  String _fontStyle = 'normal';
  TextAlign _alignment = TextAlign.center;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mediumGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Titre
            Text(
              'Ajouter du texte',
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            // TextField
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              style: GoogleFonts.inter(
                color: _textColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Écris quelque chose...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.mediumGray,
                ),
                filled: true,
                fillColor: _bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Styles de police
            Text(
              'Style',
              style: GoogleFonts.inter(
                color: AppColors.lightGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStyleButton('normal', 'Normal'),
                  const SizedBox(width: 8),
                  _buildStyleButton('bold', 'Gras'),
                  const SizedBox(width: 8),
                  _buildStyleButton('italic', 'Italic'),
                  const SizedBox(width: 8),
                  _buildStyleButton('neon', 'Néon'),
                  const SizedBox(width: 8),
                  _buildStyleButton('outlined', 'Contour'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Alignement
            Text(
              'Alignement',
              style: GoogleFonts.inter(
                color: AppColors.lightGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAlignButton(TextAlign.left, Icons.format_align_left),
                const SizedBox(width: 8),
                _buildAlignButton(TextAlign.center, Icons.format_align_center),
                const SizedBox(width: 8),
                _buildAlignButton(TextAlign.right, Icons.format_align_right),
              ],
            ),

            const SizedBox(height: 24),

            // Couleur du texte
            Text(
              'Couleur du texte',
              style: GoogleFonts.inter(
                color: AppColors.lightGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(false),

            const SizedBox(height: 24),

            // Couleur de fond
            Text(
              'Fond',
              style: GoogleFonts.inter(
                color: AppColors.lightGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(true),

            const SizedBox(height: 32),

            // Bouton Ajouter
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onTextAdded(
                    StoryText(
                      text: _controller.text,
                      position: const Offset(100, 200),
                      color: _textColor,
                      backgroundColor: _bgColor,
                      fontStyle: _fontStyle,
                      alignment: _alignment,
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimsonRed,
                foregroundColor: AppColors.pureWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Ajouter',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleButton(String style, String label) {
    final isSelected = _fontStyle == style;
    return InkWell(
      onTap: () => setState(() => _fontStyle = style),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.crimsonRed : AppColors.mediumGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.pureWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignButton(TextAlign align, IconData icon) {
    final isSelected = _alignment == align;
    return InkWell(
      onTap: () => setState(() => _alignment = align),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.crimsonRed : AppColors.mediumGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.pureWhite),
      ),
    );
  }

  Widget _buildColorPicker(bool isBackground) {
    final colors = isBackground
        ? [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
            Colors.white.withOpacity(0.7),
            AppColors.crimsonRed.withOpacity(0.7),
            Colors.blue.withOpacity(0.7),
            Colors.green.withOpacity(0.7),
            Colors.yellow.withOpacity(0.7),
            Colors.purple.withOpacity(0.7),
          ]
        : [
            Colors.white,
            Colors.black,
            AppColors.crimsonRed,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.orange,
            Colors.purple,
            Colors.pink,
            Colors.teal,
          ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = isBackground
              ? _bgColor == color
              : _textColor == color;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isBackground) {
                  _bgColor = color;
                } else {
                  _textColor = color;
                }
              });
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.crimsonRed : AppColors.mediumGray,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }
}