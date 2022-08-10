import 'package:dbus/dbus.dart';

/// A pattern used to match files.
abstract class XdgFileChooserFilterPattern {
  int get _id;
  String get _pattern;

  XdgFileChooserFilterPattern();
}

/// A pattern used to match files using a glob string.
class XdgFileChooserGlobPattern extends XdgFileChooserFilterPattern {
  /// A glob patterns, e.g. '*.png'
  final String pattern;

  @override
  int get _id => 0;

  @override
  String get _pattern => pattern;

  XdgFileChooserGlobPattern(this.pattern);
}

/// A pattern used to match files using a MIME type.
class XdgFileChooserMimeTypePattern extends XdgFileChooserFilterPattern {
  /// A MIME type, e.g. 'image/png'
  final String mimeType;

  @override
  int get _id => 1;

  @override
  String get _pattern => mimeType;

  XdgFileChooserMimeTypePattern(this.mimeType);
}

/// A file filter in use in a file chooser.
class XdgFileChooserFilter {
  /// The name of this filter.
  final String name;

  /// Patterns to match files against.
  final List<XdgFileChooserFilterPattern> patterns;

  XdgFileChooserFilter(
      this.name, Iterable<XdgFileChooserFilterPattern> patterns)
      : patterns = patterns.toList();
}

XdgFileChooserFilter? decodeFilter(DBusValue? value) {
  if (value == null || value.signature != DBusSignature('(sa(us))')) {
    return null;
  }

  var nameAndPatterns = value.asStruct();
  var name = nameAndPatterns[0].asString();
  var patterns = nameAndPatterns[1]
      .asArray()
      .map((v) {
        var idAndPattern = v.asStruct();
        var id = idAndPattern[0].asUint32();
        var pattern = idAndPattern[1].asString();
        switch (id) {
          case 0:
            return XdgFileChooserGlobPattern(pattern);
          case 1:
            return XdgFileChooserMimeTypePattern(pattern);
          default:
            return null;
        }
      })
      .where((p) => p != null)
      .cast<XdgFileChooserFilterPattern>();

  return XdgFileChooserFilter(name, patterns);
}

DBusValue encodeFilter(XdgFileChooserFilter filter) {
  return DBusStruct([
    DBusString(filter.name),
    DBusArray(
        DBusSignature('(us)'),
        filter.patterns.map((pattern) => DBusStruct(
            [DBusUint32(pattern._id), DBusString(pattern._pattern)])))
  ]);
}

DBusValue encodeFilters(Iterable<XdgFileChooserFilter> filters) {
  return DBusArray(
      DBusSignature('(sa(us))'), filters.map((f) => encodeFilter(f)));
}
