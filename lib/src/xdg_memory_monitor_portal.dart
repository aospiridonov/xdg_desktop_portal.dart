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

/// Memory monitoring portal.
class XdgMemoryMonitorPortal {
  final DBusRemoteObject _object;
  late final DBusRemoteObjectSignalStream _changed;
  late final StreamController<LowMemoryWarning> _controller;

  XdgMemoryMonitorPortal(this._object) {
    _changed = DBusRemoteObjectSignalStream(
        object: _object,
        interface: 'org.freedesktop.portal.MemoryMonitor',
        name: 'LowMemoryWarning',
        signature: DBusSignature('y'));
    _controller = StreamController<LowMemoryWarning>();
    _changed.listen((signal) async {
      var value = signal.values[0].asByte();
      if (value == 50) {
        _controller.add(LowMemoryWarning.low);
      }
      if (value == 100) {
        _controller.add(LowMemoryWarning.medium);
      }
      if (value == 255) {
        _controller.add(LowMemoryWarning.critical);
      }
    });
  }

  /// Get the version of this portal.
  Future<int> getVersion() {
    _controller.add(LowMemoryWarning.critical);

    return _object
        .getProperty('org.freedesktop.portal.MemoryMonitor', 'version',
            signature: DBusSignature('u'))
        .then((v) => v.asUint32());
  }

  /// Get low memory warning stream.
  Stream<LowMemoryWarning> get lowMemoryWarning {
    return _controller.stream;
  }
}
