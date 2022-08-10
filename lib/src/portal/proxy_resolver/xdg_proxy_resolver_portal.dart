import 'package:dbus/dbus.dart';

import '../xdg_desktop_portal_client.dart';

/// Portal to use system proxy.
class XdgProxyResolverPortal {
  /// The client that is connected to this portal.
  XdgDesktopPortalClient client;

  XdgProxyResolverPortal(this.client);

  /// Looks up which proxy to use to connect to [uri].
  /// 'direct://' is returned when no proxy is needed.
  Future<List<String>> lookup(String uri) async {
    var result = await client.callMethod(
      'org.freedesktop.portal.ProxyResolver',
      'Lookup',
      [DBusString(uri)],
      replySignature: DBusSignature('as'),
    );
    return result.returnValues[0].asStringArray().toList();
  }

  /// Read all the the settings in the given [namespaces].
  /// Globbing is allowed on trailing sections, e.g. 'com.example.*'.
  Future<Map<String, Map<String, DBusValue>>> readAll(
      Iterable<String> namespaces) async {
    var result = await client.callMethod('org.freedesktop.portal.Settings',
        'ReadAll', [DBusArray.string(namespaces)],
        replySignature: DBusSignature('a{sa{sv}}'));
    return result.returnValues[0].asDict().map(
        (key, value) => MapEntry(key.asString(), value.asStringVariantDict()));
  }
}
