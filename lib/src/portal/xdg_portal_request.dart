import 'dart:async';

import 'package:dbus/dbus.dart';

import 'xdg_desktop_portal_client.dart';
import 'xdg_portal_response.dart';

/// Exception thrown when a portal request fails due to it being cancelled.
class XdgPortalRequestCancelledException implements Exception {
  @override
  String toString() => 'Request was cancelled';
}

/// Exception thrown when a portal request fails.
class XdgPortalRequestFailedException implements Exception {
  @override
  String toString() => 'Request failed';
}

/// A request sent to a portal.
class XdgPortalRequest {
  /// The client that is the request is from.
  XdgDesktopPortalClient client;

  /// Stream containing the single result returned from the portal.
  Stream<Map<String, DBusValue>> get stream => _controller.stream;

  final Future<DBusObjectPath> Function() _send;
  late final StreamController<Map<String, DBusValue>> _controller;
  final _listenCompleter = Completer();
  late final DBusRemoteObject _object;
  var _haveResponse = false;

  XdgPortalRequest(this.client, this._send) {
    _controller = StreamController<Map<String, DBusValue>>(
        onListen: _onListen, onCancel: _onCancel);
  }

  /// Send the request.
  Future<void> _onListen() async {
    var path = await _send();
    _object = DBusRemoteObject(client.bus, name: client.name, path: path);
    client.addRequest(path, this);
    _listenCompleter.complete();
  }

  Future<void> _onCancel() async {
    // Ensure that we have started the stream
    await _listenCompleter.future;

    // If got a response, then the request object has already been removed.
    if (!_haveResponse) {
      try {
        await _object.callMethod('org.freedesktop.portal.Request', 'Close', [],
            replySignature: DBusSignature(''));
      } on DBusMethodResponseException {
        // Ignore errors, as the request may have completed before the close request was received.
      }
    }
  }

  void handleResponse(
      XdgPortalResponse response, Map<String, DBusValue> result) {
    _haveResponse = true;
    switch (response) {
      case XdgPortalResponse.success:
        _controller.add(result);
        return;
      case XdgPortalResponse.cancelled:
        _controller.addError(XdgPortalRequestCancelledException());
        break;
      case XdgPortalResponse.other:
      default:
        _controller.addError(XdgPortalRequestFailedException());
        break;
    }
    _controller.close();
  }
}
