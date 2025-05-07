import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:read_leaf/core/constants/responsive_constants.dart';
import 'package:read_leaf/features/library/data/thumbnail_service.dart';
import 'package:get_it/get_it.dart';

class ReaderLoadingScreen extends StatefulWidget {
  final String filePath;
  final double loadingProgress;
  final bool isCompleted;
  final VoidCallback? onCompleted;

  const ReaderLoadingScreen({
    super.key,
    required this.filePath,
    this.loadingProgress = 0.0,
    this.isCompleted = false,
    this.onCompleted,
  });

  @override
  State<ReaderLoadingScreen> createState() => _ReaderLoadingScreenState();
}

class _ReaderLoadingScreenState extends State<ReaderLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  ImageProvider? _thumbnailImage;
  bool _hasLoadedThumbnail = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _loadThumbnail();
    _animationController.forward();

    // If already completed when widget is created, trigger the onCompleted callback
    if (widget.isCompleted && widget.onCompleted != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onCompleted!();
      });
    }
  }

  Future<void> _loadThumbnail() async {
    try {
      final thumbnailService = GetIt.I<ThumbnailService>();
      final fileExtension = path.extension(widget.filePath).toLowerCase();
      print(
          'Loading thumbnail for ${path.basename(widget.filePath)} with extension $fileExtension');

      if (fileExtension == '.pdf' || fileExtension == '.epub') {
        final file = File(widget.filePath);
        if (await file.exists()) {
          print('File exists at path: ${widget.filePath}');

          // First try to get a cached thumbnail
          final thumbnail =
              await thumbnailService.getThumbnail(widget.filePath);
          if (mounted && thumbnail != null) {
            print('Using cached thumbnail');

            // Pre-verify the image data is valid
            final isValid = await _verifyImageData(FileImage(thumbnail));
            if (isValid) {
              setState(() {
                _thumbnailImage = FileImage(thumbnail);
                _hasLoadedThumbnail = true;
              });
              return;
            } else {
              print('Cached thumbnail found but image data is invalid');
            }
          }

          print('No cached thumbnail found, generating new one');

          // If no cached thumbnail, try to generate one
          try {
            final imageProvider =
                await thumbnailService.getFileThumbnail(widget.filePath);

            // Pre-verify the image data is valid
            final isValid = await _verifyImageData(imageProvider);

            if (mounted) {
              if (isValid) {
                print('Successfully generated valid thumbnail');
                setState(() {
                  _thumbnailImage = imageProvider;
                  _hasLoadedThumbnail = true;
                });
              } else {
                print(
                    'Generated thumbnail but image data is invalid, using default');
                _useDefaultThumbnail(fileExtension);
              }
            }
          } catch (e) {
            print('Error generating thumbnail: $e');
            _useDefaultThumbnail(fileExtension);
          }
        } else {
          print('File does not exist at path: ${widget.filePath}');
          _useDefaultThumbnail(fileExtension);
        }
      } else {
        print('Unsupported file extension: $fileExtension');
        _useDefaultThumbnail(fileExtension);
      }
    } catch (e) {
      print('Error in _loadThumbnail: $e');
      if (mounted) {
        final fileExtension = path.extension(widget.filePath).toLowerCase();
        _useDefaultThumbnail(fileExtension);
      }
    }
  }

  // New helper method to verify image data is valid
  Future<bool> _verifyImageData(ImageProvider imageProvider) async {
    try {
      final completer = Completer<bool>();

      // Create image stream and listen for events
      final ImageStream stream =
          imageProvider.resolve(const ImageConfiguration());
      final listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(true); // Image loaded successfully
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          print('Image verification failed: $exception');
          completer.complete(false); // Image failed to load
        },
      );

      stream.addListener(listener);

      // Add timeout to prevent hanging
      Future.delayed(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      final result = await completer.future;
      stream.removeListener(listener);
      return result;
    } catch (e) {
      print('Error verifying image data: $e');
      return false;
    }
  }

  void _useDefaultThumbnail(String fileExtension) {
    if (!mounted) return;

    print('Using default thumbnail for $fileExtension');
    setState(() {
      _thumbnailImage = AssetImage(fileExtension == '.pdf'
          ? 'assets/images/pdf_placeholder.png'
          : 'assets/images/book_placeholder.png');
      _hasLoadedThumbnail = true;
    });
  }

  @override
  void didUpdateWidget(ReaderLoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if we've just completed loading
    if (widget.isCompleted &&
        !oldWidget.isCompleted &&
        widget.onCompleted != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onCompleted!();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(widget.filePath);
    final fileExtension = path.extension(widget.filePath).toLowerCase();
    final isTablet = ResponsiveConstants.isTablet(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background with blur effect
              if (_hasLoadedThumbnail && _thumbnailImage != null)
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      try {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _blurAnimation.value,
                              sigmaY: _blurAnimation.value,
                            ),
                            child: Opacity(
                              opacity: 0.3,
                              child: Image(
                                image: _thumbnailImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                      'Error rendering background image: $error');
                                  return Container(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        print('Error applying blur effect: $e');
                        // Fall back to a plain background
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        );
                      }
                    },
                  ),
                )
              else
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),

              // Content
              Positioned.fill(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // File icon or thumbnail
                        if (_hasLoadedThumbnail && _thumbnailImage != null)
                          Container(
                            width: isTablet ? 240 : 180,
                            height: isTablet ? 320 : 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: _thumbnailImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                      'Error rendering thumbnail image: $error');
                                  return Container(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF352A3B)
                                        : const Color(0xFFF8F1F1),
                                    child: Center(
                                      child: Icon(
                                        fileExtension == '.pdf'
                                            ? Icons.picture_as_pdf
                                            : Icons.book,
                                        size: isTablet ? 80 : 60,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          Container(
                            width: isTablet ? 180 : 140,
                            height: isTablet ? 180 : 140,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF352A3B)
                                  : const Color(0xFFF8F1F1),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                fileExtension == '.pdf'
                                    ? Icons.picture_as_pdf
                                    : Icons.book,
                                size: isTablet ? 80 : 60,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),

                        // File name
                        Text(
                          fileName,
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 22,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFFF2F2F7)
                                    : const Color(0xFF1C1C1E),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 32),

                        // Loading indicator
                        SizedBox(
                          width: isTablet ? 220 : 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: widget.loadingProgress,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF352A3B)
                                  : const Color(0xFFEEE5E5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFFE4B4C4)
                                    : const Color(0xFFDD6F87),
                              ),
                              minHeight: isTablet ? 8 : 6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Loading text
                        Text(
                          widget.isCompleted
                              ? 'Ready to read'
                              : 'Opening document...',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFFAA96B6)
                                    : const Color(0xFF9E7B80),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Message about disabling loading screen
                        Opacity(
                          opacity: 0.7,
                          child: Text(
                            "This loading screen can be disabled in Settings",
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
