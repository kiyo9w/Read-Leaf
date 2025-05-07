import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:path/path.dart' as path;
import 'package:screenshot/screenshot.dart';
import 'package:epubx/epubx.dart' hide Image;

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  final _memoryCache = <String, ImageProvider>{};
  static const int maxMemoryCacheSize = 100;
  static const double thumbnailWidth = 150.0;
  static const double thumbnailHeight = 200.0;

  final _screenshotController = ScreenshotController();

  // Default PDF thumbnails mapping
  final Map<String, String> _defaultThumbnails = {
    'atomic_habits.pdf': 'assets/images/thumbnails/atomic_habits_thumb.jpg',
    'business_law.pdf': 'assets/images/thumbnails/business_law_thumb.jpg',
    'app_development_flutter.pdf':
        'assets/images/thumbnails/app_development_flutter_thumb.jpg',
    'gietconchimnhan.pdf': 'assets/images/thumbnails/gietconchimnhan_thumb.jpg',
    'lewis-lion-the-witch-and-the-wardrobe.epub':
        'assets/images/thumbnails/lion_the_witch_thumb.jpg',
    'steinbeck-of-mice-and-men.epub':
        'assets/images/thumbnails/mice_and_men_thumb.jpg',
  };

  Future<String> _getThumbnailPath(String originalPath) async {
    final cacheDir = await getTemporaryDirectory();
    final fileName = path.basename(originalPath);
    return path.join(cacheDir.path, 'thumbnails', '${fileName}_thumb.jpg');
  }

  Future<ImageProvider> getFileThumbnail(String filePath) async {
    final fileType = path.extension(filePath).toLowerCase();
    if (fileType == '.pdf') {
      return getPdfThumbnail(filePath);
    } else if (fileType == '.epub') {
      return getEpubThumbnail(filePath);
    }
    return const AssetImage('assets/images/pdf_placeholder.png');
  }

  // Helper method to validate image bytes
  bool _isValidImageBytes(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) {
      return false;
    }

    // Check for common image signatures
    // JPEG starts with FF D8 FF
    if (bytes.length > 2 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return true;
    }

    // PNG starts with 89 50 4E 47 0D 0A 1A 0A
    if (bytes.length > 7 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return true;
    }

    // GIF starts with GIF87a or GIF89a
    if (bytes.length > 5 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38 &&
        (bytes[4] == 0x37 || bytes[4] == 0x39) &&
        bytes[5] == 0x61) {
      return true;
    }

    // If no recognized signature is found, it's likely not a valid image
    print('Invalid image format detected: not a recognized image format');
    return false;
  }

  Future<ImageProvider> getEpubThumbnail(String filePath) async {
    final fileName = path.basename(filePath);
    print('Starting EPUB thumbnail generation for: $fileName');

    // Check if this is a default EPUB and return its pre-cached thumbnail
    if (_defaultThumbnails.containsKey(fileName)) {
      print('Using pre-defined thumbnail for $fileName');
      return AssetImage(_defaultThumbnails[fileName]!);
    }

    // Check memory cache first
    if (_memoryCache.containsKey(filePath)) {
      print('Found in memory cache: $fileName');
      return _memoryCache[filePath]!;
    }

    // Check disk cache
    final thumbnailPath = await _getThumbnailPath(filePath);
    final thumbnailFile = File(thumbnailPath);

    if (await thumbnailFile.exists()) {
      print('Found in disk cache: $fileName');

      try {
        // Validate the cached thumbnail file
        final fileBytes = await thumbnailFile.readAsBytes();
        if (!_isValidImageBytes(fileBytes)) {
          print(
              'Cached thumbnail exists but contains invalid image data, regenerating...');
          await thumbnailFile.delete();
        } else {
          final provider = FileImage(thumbnailFile);
          _addToMemoryCache(filePath, provider);
          return provider;
        }
      } catch (e) {
        print('Error validating cached thumbnail: $e');
        // Try to regenerate if validation fails
      }
    }

    print('Generating new thumbnail for EPUB: $fileName');

    // Generate new thumbnail
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final book = await EpubReader.readBook(bytes);

      print('EPUB loaded, title: ${book.Title}');
      print('Has content: ${book.Content != null}');
      print('Has images: ${book.Content?.Images?.isNotEmpty}');

      // Check if book has images at all
      if (book.Content?.Images == null || book.Content!.Images!.isEmpty) {
        print('No images found in EPUB, using generated thumbnail');
        return _generateBookCoverWithTitle(
            book.Title ?? path.basenameWithoutExtension(fileName),
            thumbnailFile);
      }

      // Try to find a cover image with systematic approach
      Uint8List? coverBytes;

      // 1. Look for files with 'cover' in name (case insensitive)
      final coverNamedImages = book.Content!.Images!.entries
          .where((e) =>
              e.key.toLowerCase().contains('cover') &&
              (e.value.Content?.isNotEmpty ?? false))
          .toList();

      if (coverNamedImages.isNotEmpty) {
        print(
            'Found image with "cover" in name: ${coverNamedImages.first.key}');
        coverBytes = Uint8List.fromList(coverNamedImages.first.value.Content!);

        // Validate the cover image
        if (!_isValidImageBytes(coverBytes)) {
          print('Cover image has invalid format, trying alternative images');
          coverBytes = null;
        }
      }

      // 2. If not found or invalid, look for common cover image patterns
      if (coverBytes == null) {
        final commonCoverPatterns = ['title', 'front', 'cover', 'title-page'];

        for (final pattern in commonCoverPatterns) {
          final matches = book.Content!.Images!.entries
              .where((e) =>
                  e.key.toLowerCase().contains(pattern) &&
                  (e.value.Content?.isNotEmpty ?? false))
              .toList();

          if (matches.isNotEmpty) {
            print(
                'Found image matching pattern "$pattern": ${matches.first.key}');
            coverBytes = Uint8List.fromList(matches.first.value.Content!);

            // Validate the image
            if (_isValidImageBytes(coverBytes)) {
              break;
            } else {
              print(
                  'Image for pattern "$pattern" has invalid format, trying next pattern');
              coverBytes = null;
            }
          }
        }
      }

      // 3. If still not found, use first image if it's large enough (likely a cover)
      if (coverBytes == null && book.Content!.Images!.isNotEmpty) {
        final sortedImages = book.Content!.Images!.entries
            .where((e) => (e.value.Content?.length ?? 0) > 1000)
            .toList()
          ..sort((a, b) => (b.value.Content?.length ?? 0)
              .compareTo(a.value.Content?.length ?? 0));

        if (sortedImages.isNotEmpty) {
          // Try images in order of size (largest first)
          for (final imgEntry in sortedImages) {
            final contentLength = imgEntry.value.Content?.length ?? 0;
            print('Trying image: ${imgEntry.key}, size: $contentLength bytes');

            coverBytes = Uint8List.fromList(imgEntry.value.Content!);

            // Validate the image
            if (_isValidImageBytes(coverBytes)) {
              print('Found valid image: ${imgEntry.key}');
              break;
            } else {
              print(
                  'Image ${imgEntry.key} has invalid format, trying next image');
              coverBytes = null;
            }
          }
        }
      }

      // If we have valid bytes, save and return
      if (coverBytes != null && coverBytes.isNotEmpty) {
        try {
          print('Saving thumbnail to disk cache: $thumbnailPath');
          await thumbnailFile.parent.create(recursive: true);
          await thumbnailFile.writeAsBytes(coverBytes);

          final provider = MemoryImage(coverBytes);
          _addToMemoryCache(filePath, provider);
          return provider;
        } catch (e) {
          print('Error saving thumbnail: $e');
          // Fall through to default thumbnail generation
        }
      } else {
        print('No suitable cover image found in EPUB');
      }

      // If no cover image found or saving failed, generate a default one with title
      return _generateBookCoverWithTitle(
          book.Title ?? path.basenameWithoutExtension(fileName), thumbnailFile);
    } catch (e) {
      print('Error generating EPUB thumbnail: $e');
      return const AssetImage('assets/images/book_placeholder.png');
    }
  }

  // Helper method to generate a thumbnail with title
  Future<ImageProvider> _generateBookCoverWithTitle(
      String title, File thumbnailFile) async {
    print('Generating cover with title: $title');
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Container(
          width: thumbnailWidth * 2,
          height: thumbnailHeight * 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade200, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.book_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final defaultBytes = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 300),
        pixelRatio: 2.0,
        targetSize: Size(thumbnailWidth * 2, thumbnailHeight * 2),
      );

      await thumbnailFile.parent.create(recursive: true);
      await thumbnailFile.writeAsBytes(defaultBytes);

      final provider = MemoryImage(defaultBytes);
      return provider;
    } catch (e) {
      print('Error generating default cover: $e');
      return const AssetImage('assets/images/book_placeholder.png');
    }
  }

  Future<ImageProvider> getPdfThumbnail(String filePath) async {
    final fileName = path.basename(filePath);

    // Check if this is a default PDF and return its pre-cached thumbnail
    if (_defaultThumbnails.containsKey(fileName)) {
      return AssetImage(_defaultThumbnails[fileName]!);
    }

    // Check memory cache first
    if (_memoryCache.containsKey(filePath)) {
      return _memoryCache[filePath]!;
    }

    // Check disk cache
    final thumbnailPath = await _getThumbnailPath(filePath);
    final thumbnailFile = File(thumbnailPath);

    if (await thumbnailFile.exists()) {
      final provider = FileImage(thumbnailFile);
      _addToMemoryCache(filePath, provider);
      return provider;
    }

    // Generate new thumbnail
    try {
      // First load and render the PDF
      final document = await PdfDocument.openFile(filePath);

      // Wait a bit to ensure PDF is loaded
      await Future.delayed(const Duration(milliseconds: 500));

      final bytes = await _generatePdfThumbnail(filePath, document);

      // Wait additional time to ensure proper rendering before caching
      await Future.delayed(const Duration(milliseconds: 10000));

      // Only cache if the bytes are valid
      if (bytes.isNotEmpty) {
        await thumbnailFile.parent.create(recursive: true);
        await thumbnailFile.writeAsBytes(bytes);

        final provider = MemoryImage(bytes);
        _addToMemoryCache(filePath, provider);
        return provider;
      }
      throw Exception('Generated thumbnail is empty');
    } catch (e) {
      print('Error generating thumbnail: $e');
      return const AssetImage('assets/images/pdf_placeholder.png');
    }
  }

  Future<Uint8List> _generatePdfThumbnail(
      String filePath, PdfDocument document) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: Container(
            width: thumbnailWidth * 2,
            height: thumbnailHeight * 2,
            color: Colors.white,
            child: PdfPageView(
              document: document,
              pageNumber: 1,
              alignment: Alignment.center,
              maximumDpi: 300,
              decorationBuilder: (context, pageSize, page, pageImage) {
                if (pageImage == null) return const SizedBox.shrink();
                return pageImage;
              },
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final bytes = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 300),
        pixelRatio: 2.0, // Reduced for faster rendering
        targetSize: Size(thumbnailWidth * 2, thumbnailHeight * 2),
      );

      if (bytes.isEmpty) {
        throw Exception('Failed to capture thumbnail');
      }

      return bytes;
    } catch (e) {
      print('Error generating PDF thumbnail: $e');
      return _generateDefaultThumbnail();
    }
  }

  Future<Uint8List> _generateDefaultThumbnail() async {
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Container(
          width: thumbnailWidth * 2,
          height: thumbnailHeight * 2,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );

    return await _screenshotController.captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 200),
      pixelRatio: 4.0,
      targetSize: Size(thumbnailWidth * 3, thumbnailHeight * 3),
    );
  }

  Future<ImageProvider> getNetworkThumbnail(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final provider = FileImage(file);
    _addToMemoryCache(url, provider);
    return provider;
  }

  void _addToMemoryCache(String key, ImageProvider provider) {
    if (_memoryCache.length >= maxMemoryCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[key] = provider;
  }

  void clearCache() {
    _memoryCache.clear();
  }

  Future<File?> getThumbnail(String filePath) async {
    final thumbnailPath = await _getThumbnailPath(filePath);
    final thumbnailFile = File(thumbnailPath);

    if (await thumbnailFile.exists()) {
      return thumbnailFile;
    }

    try {
      final imageProvider = await getFileThumbnail(filePath);

      // If it's a FileImage, return the file
      if (imageProvider is FileImage) {
        return File(imageProvider.file.path);
      }

      // For other types, we can't directly return a File
      return null;
    } catch (e) {
      print('Error getting thumbnail: $e');
      return null;
    }
  }
}
