// screens/stories/widgets/story_filter_selector.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otakuverse/core/constants/colors.dart';

class StoryFilterSelector extends StatefulWidget {
  final File currentFile;
  final ColorFilter? currentFilter;
  final double brightness;
  final double contrast;
  final double saturation;
  final Function(ColorFilter?, double, double, double) onFilterChanged;

  const StoryFilterSelector({
    super.key,
    required this.currentFile,
    required this.currentFilter,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.onFilterChanged,
  });

  @override
  State<StoryFilterSelector> createState() => _StoryFilterSelectorState();
}

class _StoryFilterSelectorState extends State<StoryFilterSelector> {
  late double _brightness;
  late double _contrast;
  late double _saturation;
  ColorFilter? _selectedFilter;

  // Tous les filtres disponibles
  final Map<String, ColorFilter?> filters = {
    'Original': null,
    'Noir & Blanc': const ColorFilter.mode(
      Colors.grey,
      BlendMode.saturation,
    ),
    'Sépia': const ColorFilter.matrix([
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    'Vintage': const ColorFilter.matrix([
      0.9, 0, 0, 0, 0,
      0, 0.8, 0, 0, 0,
      0, 0, 0.6, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    'Cool': const ColorFilter.matrix([
      1, 0, 0, 0, 0,
      0, 0.95, 0, 0, 0,
      0, 0, 1.1, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    'Warm': const ColorFilter.matrix([
      1.2, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    'Dramatique': const ColorFilter.matrix([
      1.5, 0, 0, 0, 0,
      0, 1.5, 0, 0, 0,
      0, 0, 1.5, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    'Rêve': const ColorFilter.matrix([
      1.2, 0, 0, 0, 0,
      0, 1.1, 0, 0, 0,
      0, 0, 1.3, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    'Négatif': const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ]),
    'Pastel': const ColorFilter.matrix([
      0.8, 0, 0, 0, 20,
      0, 0.8, 0, 0, 20,
      0, 0, 0.8, 0, 20,
      0, 0, 0, 1, 0,
    ]),
    'High Contrast': const ColorFilter.matrix([
      2, 0, 0, 0, -128,
      0, 2, 0, 0, -128,
      0, 0, 2, 0, -128,
      0, 0, 0, 1, 0,
    ]),
    'Froid': const ColorFilter.matrix([
      0.9, 0, 0, 0, 0,
      0, 0.9, 0, 0, 0,
      0, 0, 1.2, 0, 0,
      0, 0, 0, 1, 0,
    ]),
  };

  @override
  void initState() {
    super.initState();
    _brightness = widget.brightness;
    _contrast = widget.contrast;
    _saturation = widget.saturation;
    _selectedFilter = widget.currentFilter;
  }

  void _applyChanges() {
    widget.onFilterChanged(
      _selectedFilter,
      _brightness,
      _contrast,
      _saturation,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres & Ajustements',
                  style: GoogleFonts.poppins(
                    color: AppColors.pureWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _applyChanges,
                  child: Text(
                    'Appliquer',
                    style: GoogleFonts.inter(
                      color: AppColors.crimsonRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filtres prédéfinis
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final entry = filters.entries.elementAt(index);
                final isSelected = _selectedFilter == entry.value;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = entry.value);
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.crimsonRed
                                  : AppColors.mediumGray,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ColorFiltered(
                              colorFilter: entry.value ??
                                  const ColorFilter.mode(
                                    Colors.transparent,
                                    BlendMode.multiply,
                                  ),
                              child: Image.file(
                                widget.currentFile,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.key,
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.crimsonRed
                                : AppColors.pureWhite,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Ajustements manuels
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajustements',
                    style: GoogleFonts.poppins(
                      color: AppColors.pureWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Luminosité
                  _buildSlider(
                    label: 'Luminosité',
                    value: _brightness,
                    min: -0.5,
                    max: 0.5,
                    onChanged: (value) => setState(() => _brightness = value),
                  ),

                  const SizedBox(height: 16),

                  // Contraste
                  _buildSlider(
                    label: 'Contraste',
                    value: _contrast,
                    min: 0.5,
                    max: 2.0,
                    onChanged: (value) => setState(() => _contrast = value),
                  ),

                  const SizedBox(height: 16),

                  // Saturation
                  _buildSlider(
                    label: 'Saturation',
                    value: _saturation,
                    min: 0.0,
                    max: 2.0,
                    onChanged: (value) => setState(() => _saturation = value),
                  ),

                  const SizedBox(height: 24),

                  // Bouton Reset
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _brightness = 0.0;
                          _contrast = 1.0;
                          _saturation = 1.0;
                          _selectedFilter = null;
                        });
                      },
                      icon: const Icon(Icons.refresh, color: AppColors.mediumGray),
                      label: Text(
                        'Réinitialiser',
                        style: GoogleFonts.inter(color: AppColors.mediumGray),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.lightGray,
                fontSize: 14,
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: GoogleFonts.inter(
                color: AppColors.pureWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.crimsonRed,
            inactiveTrackColor: AppColors.mediumGray,
            thumbColor: AppColors.crimsonRed,
            overlayColor: AppColors.crimsonRed.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}