import 'dart:async';
import 'dart:math';

import 'package:dbus/dbus.dart';

import 'xdg_account_portal.dart';
import 'xdg_email_portal.dart';
import 'xdg_file_chooser_portal.dart';
import 'xdg_network_monitor_portal.dart';
import 'xdg_notification_portal.dart';
import 'xdg_location_portal.dart';
import 'xdg_open_uri_portal.dart';
import 'xdg_proxy_resolver_portal.dart';
import 'xdg_secret_portal.dart';
import 'xdg_settings_portal.dart';

/// A client that connects to the portals.
class XdgDesktopPortalClient {
  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  late final DBusRemoteObject _object;

  /// Portal for obtaining information about the user.
  late final XdgAccountPortal account;

  /// Portal to send email.
  late final XdgEmailPortal email;

  /// Portal to request access to files.
  late final XdgFileChooserPortal fileChooser;

  /// Portal to get location information.
  late final XdgLocationPortal location;

  /// Portal to monitor networking.
  late final XdgNetworkMonitorPortal networkMonitor;

  /// Portal to create notifications.
  late final XdgNotificationPortal notification;

  /// Portal to open URIs.
  late final XdgOpenUriPortal openUri;

  /// Portal to use system proxy.
  late final XdgProxyResolverPortal proxyResolver;

  /// Portal for retrieving application secret.
  late final XdgSecretPortal secret;

  /// Portal to access system settings.
  late final XdgSettingsPortal settings;

  /// Keep track of used request/session tokens.
  final _usedTokens = <String>{};

  /// Creates a new portal client. If [bus] is provided connect to the given D-Bus server.
  XdgDesktopPortalClient({DBusClient? bus})
      : _bus = bus ?? DBusClient.session(),
        _closeBus = bus == null {
    _object = DBusRemoteObject(_bus,
        name: 'org.freedesktop.portal.Desktop',
        path: DBusObjectPath('/org/freedesktop/portal/desktop'));
    account = XdgAccountPortal(_object, _generateToken);
    email = XdgEmailPortal(_object, _generateToken);
    fileChooser = XdgFileChooserPortal(_object, _generateToken);
    location = XdgLocationPortal(_object, _generateToken);
    networkMonitor = XdgNetworkMonitorPortal(_object);
    notification = XdgNotificationPortal(_object);
    openUri = XdgOpenUriPortal(_object, _generateToken);
    proxyResolver = XdgProxyResolverPortal(_object);
    secret = XdgSecretPortal(_object, _generateToken);
    settings = XdgSettingsPortal(_object);
  }

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    await networkMonitor.close();
    if (_closeBus) {
      await _bus.close();
    }
  }

  /// Generate a token for requests and sessions.
  String _generateToken() {
    final random = Random();
    String token;
    do {
      token = 'dart${random.nextInt(1 << 32)}';
    } while (_usedTokens.contains(token));
    _usedTokens.add(token);
    return token;
  }
}
