// lib/core/utils/image_utils.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';

/// Utilitaires pour manipuler les images
class ImageUtils {
  static final ImagePicker _picker = ImagePicker();
  
  // ============================================
  // SÉLECTION D'IMAGES
  // ============================================
  
  /// Sélectionner une image depuis la galerie
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Erreur sélection image: $e');
      return null;
    }
  }
  
  /// Sélectionner plusieurs images
  static Future<List<File>> pickMultipleImages({int maxImages = 10}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      // Limiter au nombre maximum
      final limitedImages = images.take(maxImages).toList();
      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Erreur sélection images: $e');
      return [];
    }
  }
  
  /// Prendre une photo avec la caméra
  static Future<File?> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Erreur capture photo: $e');
      return null;
    }
  }
  
  // ============================================
  // COMPRESSION
  // ============================================
  
  /// Compresser une image
  static Future<File?> compressImage(
    File file, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );
      
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Erreur compression: $e');
      return null;
    }
  }
  
  /// Compresser pour avatar (petit)
  static Future<File?> compressAvatar(File file) async {
    return compressImage(
      file,
      quality: 90,
      maxWidth: 400,
      maxHeight: 400,
    );
  }
  
  /// Compresser pour post (moyen)
  static Future<File?> compressPost(File file) async {
    return compressImage(
      file,
      quality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
  }
  
  /// Compresser pour thumbnail
  static Future<File?> compressThumbnail(File file) async {
    return compressImage(
      file,
      quality: 75,
      maxWidth: 300,
      maxHeight: 300,
    );
  }
  
  // ============================================
  // REDIMENSIONNEMENT
  // ============================================
  
  /// Redimensionner une image
  static Future<File?> resizeImage(
    File file, {
    required int width,
    required int height,
  }) async {
    try {
      // Lire l'image
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Redimensionner
      final resized = img.copyResize(
        image,
        width: width,
        height: height,
      );
      
      // Sauvegarder
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final resizedFile = File(targetPath);
      await resizedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));
      
      return resizedFile;
    } catch (e) {
      print('Erreur redimensionnement: $e');
      return null;
    }
  }
  
  /// Créer un carré (crop center)
  static Future<File?> cropToSquare(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Obtenir le côté le plus petit
      final size = image.width < image.height ? image.width : image.height;
      
      // Calculer l'offset pour centrer
      final offsetX = (image.width - size) ~/ 2;
      final offsetY = (image.height - size) ~/ 2;
      
      // Crop
      final cropped = img.copyCrop(
        image,
        x: offsetX,
        y: offsetY,
        width: size,
        height: size,
      );
      
      // Sauvegarder
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final croppedFile = File(targetPath);
      await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 85));
      
      return croppedFile;
    } catch (e) {
      print('Erreur crop: $e');
      return null;
    }
  }
  
  // ============================================
  // VALIDATION
  // ============================================
  
  /// Vérifier si le fichier est une image valide
  static bool isValidImage(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  }
  
  /// Vérifier la taille du fichier
  static Future<bool> isValidSize(
    File file, {
    int maxSizeBytes = AppConstants.maxImageSize,
  }) async {
    try {
      final size = await file.length();
      return size <= maxSizeBytes;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtenir la taille du fichier en bytes
  static Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }
  
  /// Obtenir les dimensions de l'image
  static Future<Map<String, int>?> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      print('Erreur dimensions: $e');
      return null;
    }
  }
  
  // ============================================
  // FILTRES
  // ============================================
  
  /// Appliquer un filtre grayscale
  static Future<File?> applyGrayscale(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Appliquer grayscale
      final filtered = img.grayscale(image);
      
      // Sauvegarder
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filteredFile = File(targetPath);
      await filteredFile.writeAsBytes(img.encodeJpg(filtered, quality: 85));
      
      return filteredFile;
    } catch (e) {
      print('Erreur filtre: $e');
      return null;
    }
  }
  
  /// Appliquer un filtre sepia
  static Future<File?> applySepia(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Appliquer sepia
      final filtered = img.sepia(image);
      
      // Sauvegarder
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filteredFile = File(targetPath);
      await filteredFile.writeAsBytes(img.encodeJpg(filtered, quality: 85));
      
      return filteredFile;
    } catch (e) {
      print('Erreur filtre: $e');
      return null;
    }
  }
  
  /// Ajuster la luminosité (-100 à 100)
  static Future<File?> adjustBrightness(File file, int amount) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Ajuster luminosité
      final adjusted = img.adjustColor(
        image,
        brightness: amount.toDouble(),
      );
      
      // Sauvegarder
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final adjustedFile = File(targetPath);
      await adjustedFile.writeAsBytes(img.encodeJpg(adjusted, quality: 85));
      
      return adjustedFile;
    } catch (e) {
      print('Erreur ajustement: $e');
      return null;
    }
  }
  
  // ============================================
  // ROTATION
  // ============================================
  
  /// Faire tourner l'image (90, 180, 270 degrés)
  static Future<File?> rotateImage(File file, int degrees) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Rotation
      img.Image rotated;
      switch (degrees) {
        case 90:
          rotated = img.copyRotate(image, angle: 90);
          break;
        case 180:
          rotated = img.copyRotate(image, angle: 180);
          break;
        case 270:
          rotated = img.copyRotate(image, angle: 270);
          break;
        default:
          rotated = image;
      }
      
      // Sauvegarder
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final rotatedFile = File(targetPath);
      await rotatedFile.writeAsBytes(img.encodeJpg(rotated, quality: 85));
      
      return rotatedFile;
    } catch (e) {
      print('Erreur rotation: $e');
      return null;
    }
  }
  
  // ============================================
  // CONVERSION
  // ============================================
  
  /// Convertir en bytes
  static Future<Uint8List?> fileToBytes(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      print('Erreur conversion: $e');
      return null;
    }
  }
  
  /// Créer un fichier depuis bytes
  static Future<File?> bytesToFile(Uint8List bytes, String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('Erreur création fichier: $e');
      return null;
    }
  }
  
  // ============================================
  // NETTOYAGE
  // ============================================
  
  /// Supprimer un fichier temporaire
  static Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur suppression: $e');
    }
  }
  
  /// Nettoyer tous les fichiers temporaires
  static Future<void> clearTempDirectory() async {
    try {
      final dir = await getTemporaryDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
    } catch (e) {
      print('Erreur nettoyage: $e');
    }
  }
}
