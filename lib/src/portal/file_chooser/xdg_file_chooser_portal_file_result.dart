import 'xdg_file_chooser_filter.dart';

/// Result of a request for access to files.
class XdgFileChooserPortalOpenFileResult {
  /// The URIs selected in the file chooser.
  var uris = <String>[];

  /// Result of the choices taken in the chooser.
  Map<String, String> choices;

  /// Selected filter that was used in the chooser.
  XdgFileChooserFilter? currentFilter;

  XdgFileChooserPortalOpenFileResult(
      {required this.uris,
      this.choices = const {},
      required this.currentFilter});
}

class XdgFileChooserPortalSaveFileResult {
  /// The URIs selected in the file chooser.
  var uris = <String>[];

  /// Result of the choices taken in the chooser.
  Map<String, String> choices;

  /// Selected filter that was used in the chooser.
  XdgFileChooserFilter? currentFilter;

  XdgFileChooserPortalSaveFileResult(
      {required this.uris,
      this.choices = const {},
      required this.currentFilter});
}

/// Result of a request asking for a folder as a location to save one or more files.
class XdgFileChooserPortalSaveFilesResult {
  /// The URIs selected in the file chooser.
  var uris = <String>[];

  /// Result of the choices taken in the chooser.
  Map<String, String> choices;

  XdgFileChooserPortalSaveFilesResult(
      {required this.uris, this.choices = const {}});
}
