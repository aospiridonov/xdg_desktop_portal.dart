import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

void main(List<String> args) async {
  var client = XdgDesktopPortalClient();
  client.memoryMonitor.lowMemoryWarning.listen((warning) => print(warning));
}
