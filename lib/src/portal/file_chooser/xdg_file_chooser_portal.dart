import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import '../xdg_desktop_portal_client.dart';

import '../xdg_portal_request.dart';
import 'xdg_file_chooser_choice.dart';
import 'xdg_file_chooser_filter.dart';
import 'xdg_file_chooser_portal_file_result.dart';

/// Portal to request access to files.
class XdgFileChooserPortal {
  /// The client that is connected to this portal.
  XdgDesktopPortalClient client;

  XdgFileChooserPortal(this.client);

  /// Ask to open one or more files.
  Stream<XdgFileChooserPortalOpenFileResult> openFile(
      {required String title,
      String parentWindow = '',
      String? acceptLabel,
      bool? modal,
      bool? multiple,
      bool? directory,
      Iterable<XdgFileChooserFilter> filters = const [],
      XdgFileChooserFilter? currentFilter,
      Iterable<XdgFileChooserChoice> choices = const []}) {
    var request = XdgPortalRequest(client, () async {
      var options = <String, DBusValue>{};
      options['handle_token'] = DBusString(client.generateToken());
      if (acceptLabel != null) {
        options['accept_label'] = DBusString(acceptLabel);
      }
      if (modal != null) {
        options['modal'] = DBusBoolean(modal);
      }
      if (multiple != null) {
        options['multiple'] = DBusBoolean(multiple);
      }
      if (directory != null) {
        options['directory'] = DBusBoolean(directory);
      }
      if (filters.isNotEmpty) {
        options['filters'] = encodeFilters(filters);
      }
      if (currentFilter != null) {
        options['current_filter'] = encodeFilter(currentFilter);
      }
      if (choices.isNotEmpty) {
        options['choices'] = encodeChoices(choices);
      }
      var result = await client.object.callMethod(
          'org.freedesktop.portal.FileChooser',
          'OpenFile',
          [
            DBusString(parentWindow),
            DBusString(title),
            DBusDict.stringVariant(options)
          ],
          replySignature: DBusSignature('o'));
      return result.returnValues[0].asObjectPath();
    });
    return request.stream.map((result) {
      var urisValue = result['uris'];
      var uris = urisValue?.signature == DBusSignature('as')
          ? urisValue!.asStringArray().toList()
          : <String>[];
      var choicesResult = decodeChoicesResult(result['choices']);
      var selectedFilter = decodeFilter(result['current_filter']);

      return XdgFileChooserPortalOpenFileResult(
          uris: uris, choices: choicesResult, currentFilter: selectedFilter);
    });
  }

  /// Ask for a location to save a file.
  Stream<XdgFileChooserPortalSaveFileResult> saveFile(
      {required String title,
      String parentWindow = '',
      String? acceptLabel,
      bool? modal,
      Iterable<XdgFileChooserFilter> filters = const [],
      XdgFileChooserFilter? currentFilter,
      Iterable<XdgFileChooserChoice> choices = const [],
      String? currentName,
      Uint8List? currentFolder,
      Uint8List? currentFile}) {
    var request = XdgPortalRequest(client, () async {
      var options = <String, DBusValue>{};
      options['handle_token'] = DBusString(client.generateToken());
      if (acceptLabel != null) {
        options['accept_label'] = DBusString(acceptLabel);
      }
      if (modal != null) {
        options['modal'] = DBusBoolean(modal);
      }
      if (filters.isNotEmpty) {
        options['filters'] = encodeFilters(filters);
      }
      if (currentFilter != null) {
        options['current_filter'] = encodeFilter(currentFilter);
      }
      if (choices.isNotEmpty) {
        options['choices'] = encodeChoices(choices);
      }
      if (currentName != null) {
        options['current_name'] = DBusString(currentName);
      }
      if (currentFolder != null) {
        options['current_folder'] = DBusArray.byte(currentFolder);
      }
      if (currentFile != null) {
        options['current_file'] = DBusArray.byte(currentFile);
      }
      var result = await client.callMethod(
          'org.freedesktop.portal.FileChooser',
          'SaveFile',
          [
            DBusString(parentWindow),
            DBusString(title),
            DBusDict.stringVariant(options)
          ],
          replySignature: DBusSignature('o'));
      return result.returnValues[0].asObjectPath();
    });
    return request.stream.map((result) {
      var urisValue = result['uris'];
      var uris = urisValue?.signature == DBusSignature('as')
          ? urisValue!.asStringArray().toList()
          : <String>[];
      var choicesResult = decodeChoicesResult(result['choices']);
      var selectedFilter = decodeFilter(result['current_filter']);

      return XdgFileChooserPortalSaveFileResult(
          uris: uris, choices: choicesResult, currentFilter: selectedFilter);
    });
  }

  /// Ask for a folder as a location to save one or more files.
  Stream<XdgFileChooserPortalSaveFilesResult> saveFiles(
      {required String title,
      String parentWindow = '',
      String? acceptLabel,
      bool? modal,
      Iterable<XdgFileChooserChoice> choices = const [],
      Uint8List? currentFolder,
      Iterable<Uint8List> files = const []}) {
    var request = XdgPortalRequest(client, () async {
      var options = <String, DBusValue>{};
      options['handle_token'] = DBusString(client.generateToken());
      if (acceptLabel != null) {
        options['accept_label'] = DBusString(acceptLabel);
      }
      if (modal != null) {
        options['modal'] = DBusBoolean(modal);
      }
      if (choices.isNotEmpty) {
        options['choices'] = encodeChoices(choices);
      }
      if (currentFolder != null) {
        options['current_folder'] = DBusArray.byte(currentFolder);
      }
      if (files.isNotEmpty) {
        options['files'] =
            DBusArray(DBusSignature('ay'), files.map((f) => DBusArray.byte(f)));
      }
      var result = await client.callMethod(
          'org.freedesktop.portal.FileChooser',
          'SaveFiles',
          [
            DBusString(parentWindow),
            DBusString(title),
            DBusDict.stringVariant(options)
          ],
          replySignature: DBusSignature('o'));
      return result.returnValues[0].asObjectPath();
    });
    return request.stream.map((result) {
      var urisValue = result['uris'];
      var uris = urisValue?.signature == DBusSignature('as')
          ? urisValue!.asStringArray().toList()
          : <String>[];
      var choicesResult = decodeChoicesResult(result['choices']);

      return XdgFileChooserPortalSaveFilesResult(
          uris: uris, choices: choicesResult);
    });
  }
}
