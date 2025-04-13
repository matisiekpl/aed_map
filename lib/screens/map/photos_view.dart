import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:aed_map/models/aed.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotosView extends StatefulWidget {
  final Defibrillator defibrillator;

  const PhotosView({super.key, required this.defibrillator});

  @override
  State<PhotosView> createState() => _PhotosViewState();
}

class _PhotosViewState extends State<PhotosView> {
  late PageController _pageController;
  late int currentIndex;
  double _dragOffset = 0;
  static const double _dismissThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta!;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _dismissThreshold) {
      Navigator.pop(context);
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _reportImage() {
    var pointsCubit = context.read<PointsCubit>();
    final l10n = AppLocalizations.of(context)!;
    var originalContext = context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reportImage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportImageConfirmation),
            const SizedBox(height: 8),
            Text(
              l10n.reportImageDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final image = widget.defibrillator.images[currentIndex];
              if (image.id != null) {
                await pointsCubit.reportImage(image);
                showDialog(
                  context: originalContext,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.imageReported),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.understand),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text(l10n.report),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.defibrillator.images.isEmpty) {
      return const Center(child: Text('No images available'));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: _handleVerticalDragUpdate,
        onVerticalDragEnd: _handleVerticalDragEnd,
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider:
                        NetworkImage(widget.defibrillator.images[index].url),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                itemCount: widget.defibrillator.images.length,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(),
                ),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.defibrillator.images[currentIndex].id != null)
                        IconButton(
                          icon: const Icon(Icons.flag, color: Colors.white),
                          onPressed: _reportImage,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.black54,
                    child: Text(
                      '${currentIndex + 1}/${widget.defibrillator.images.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
