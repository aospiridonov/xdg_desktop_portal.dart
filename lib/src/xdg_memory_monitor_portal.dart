import 'dart:async';

import 'package:dbus/dbus.dart';

/// Requested accuracy of location information.
enum LowMemoryWarning {
  /// Memory on the device is low, processes should free up unneeded resources so they can be used elsewhere.
  low,

  /// The device has even less free memory, so processes should try harder to free up unneeded resources.
  /// If your process does not need to stay running, it is a good time for it to quit.
  medium,

  /// The system will start terminating processes to reclaim memory, including background processes.
  critical
}

class _MemoryMonitorStreamController {
  final DBusRemoteObject portalObject;

  late final StreamController<LowMemoryWarning> controller;

  StreamSubscription? _lowMemoryWarningSubscription;

  /// Low level of memory monitor received from the portal.
  Stream<LowMemoryWarning> get stream => controller.stream;

  _MemoryMonitorStreamController({required this.portalObject}) {
    controller = StreamController<LowMemoryWarning>(
        onListen: _onListen, onCancel: _onCancel);
  }

  Future<void> _onListen() async {
    var lowMemoryWarning = DBusSignalStream(
      portalObject.client,
      interface: 'org.freedesktop.portal.MemoryMonitor',
      name: 'LowMemoryWarning',
      path: portalObject.path,
      signature: DBusSignature('u'),
    );

    _lowMemoryWarningSubscription = lowMemoryWarning.listen((signal) {
      var value = signal.values[0].asUint16();
      if (value == 50) {
        controller.add(LowMemoryWarning.low);
      }
      if (value == 100) {
        controller.add(LowMemoryWarning.medium);
      }
      if (value == 255) {
        controller.add(LowMemoryWarning.critical);
      }
    });
  }

  Future<void> _onCancel() async {
    await _lowMemoryWarningSubscription?.cancel();
  }
}

/// Memory monitoring portal.
class XdgMemoryMonitorPortal {
  final DBusRemoteObject _object;

  XdgMemoryMonitorPortal(this._object);

  /// Get the version of this portal.
  Future<int> getVersion() => _object
      .getProperty('org.freedesktop.portal.MemoryMonitor', 'version',
          signature: DBusSignature('u'))
      .then((v) => v.asUint32());

  /// Get low memory warning updates.
  Stream<LowMemoryWarning> get lowMemoryWarning {
    var controller = _MemoryMonitorStreamController(portalObject: _object);
    return controller.stream;
  }
}
