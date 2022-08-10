import 'package:dbus/dbus.dart';

/// A choice to give the user in a file chooser dialog.
/// Normally implemented as a combo box.
class XdgFileChooserChoice {
  /// Unique ID for this choice.
  final String id;

  /// User-visible label for this choice.
  final String label;

  /// User visible value labels keyed by ID.
  final Map<String, String> values;

  /// ID of the initiially selected value in [values].
  final String initialSelection;

  XdgFileChooserChoice(
      {required this.id,
      required this.label,
      this.values = const {},
      this.initialSelection = ''});

  DBusValue _encode() {
    return DBusStruct([
      DBusString(id),
      DBusString(label),
      DBusArray(
          DBusSignature('(ss)'),
          values.entries.map(
              (e) => DBusStruct([DBusString(e.key), DBusString(e.value)]))),
      DBusString(initialSelection)
    ]);
  }
}

DBusValue encodeChoices(Iterable<XdgFileChooserChoice> choices) {
  return DBusArray(
      DBusSignature('(ssa(ss)s)'), choices.map((c) => c._encode()));
}

Map<String, String> decodeChoicesResult(DBusValue? value) {
  if (value == null || value.signature != DBusSignature('a(ss)')) {
    return {};
  }

  var result = <String, String>{};
  for (var v in value.asArray()) {
    var ids = v.asStruct();
    var choiceId = ids[0].asString();
    var valueId = ids[1].asString();
    result[choiceId] = valueId;
  }

  return result;
}
