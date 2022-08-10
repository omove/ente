import 'package:flutter/material.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/events/files_updated_event.dart';
import 'package:photos/models/file_load_result.dart';
import 'package:photos/models/gallery_type.dart';
import 'package:photos/models/search/location_search_result.dart';
import 'package:photos/models/selected_files.dart';
import 'package:photos/ui/viewer/gallery/gallery.dart';
import 'package:photos/ui/viewer/gallery/gallery_app_bar_widget.dart';
import 'package:photos/ui/viewer/gallery/gallery_overlay_widget.dart';

class FilesInLocationPage extends StatelessWidget {
  final LocationSearchResult locationSearchResult;

  final _selectedFiles = SelectedFiles();
  static const String kTagPrefix = "location_search";
  static const GalleryType appBarType = GalleryType.searchResults;
  static const GalleryType overlayType = GalleryType.searchResults;
  FilesInLocationPage({
    this.locationSearchResult,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gallery = Gallery(
      asyncLoader: (creationStartTime, creationEndTime, {limit, asc}) {
        final result = locationSearchResult.files
            .where(
              (file) =>
                  file.creationTime >= creationStartTime &&
                  file.creationTime <= creationEndTime,
            )
            .toList();
        return Future.value(
          FileLoadResult(
            result,
            result.length < locationSearchResult.files.length,
          ),
        );
      },
      reloadEvent: Bus.instance.on<FilesUpdatedEvent>().where(
            (event) =>
                event.updatedFiles.firstWhere(
                  (element) => element.uploadedFileID != null,
                  orElse: () => null,
                ) !=
                null,
          ),
      forceReloadEvents: [
        Bus.instance.on<FilesUpdatedEvent>().where(
              (event) =>
                  event.updatedFiles.firstWhere(
                    (element) => element.uploadedFileID != null,
                    orElse: () => null,
                  ) !=
                  null,
            ),
      ],
      tagPrefix: kTagPrefix,
      selectedFiles: _selectedFiles,
      initialFiles: [locationSearchResult.files[0]],
      footer: const SizedBox(height: 120),
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: GalleryAppBarWidget(
          appBarType,
          locationSearchResult.location,
          _selectedFiles,
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          gallery,
          GalleryOverlayWidget(
            overlayType,
            _selectedFiles,
          )
        ],
      ),
    );
  }
}
