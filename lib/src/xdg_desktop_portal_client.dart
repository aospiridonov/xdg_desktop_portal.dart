import 'dart:async';
import 'package:dbus/dbus.dart';

class XdgSettingsPortal {
  /// The client that is connected to this portal.
  XdgDesktopPortalClient client;

  XdgSettingsPortal(this.client);

  Future<DBusValue> read(String namespace, String key) async {
    var result = await client._object.callMethod(
        'org.freedesktop.portal.Settings',
        'Read',
        [DBusString(namespace), DBusString(key)],
        replySignature: DBusSignature('v'));
    return result.returnValues[0].asVariant();
  }
}

/// A client that connects to the portals.
class XdgDesktopPortalClient {
  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  late final DBusRemoteObject _object;

  /// Portal to access system settings.
  late final XdgSettingsPortal settings;

  /// Creates a new portal client. If [bus] is provided connect to the given D-Bus server.
  XdgDesktopPortalClient({DBusClient? bus})
      : _bus = bus ?? DBusClient.session(),
        _closeBus = bus == null {
    _object = DBusRemoteObject(_bus,
        name: 'org.freedesktop.portal.Desktop',
        path: DBusObjectPath('/org/freedesktop/portal/desktop'));
    settings = XdgSettingsPortal(this);
  }

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    if (_closeBus) {
      await _bus.close();
    }
  }
}
