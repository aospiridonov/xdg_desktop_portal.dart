import 'package:dbus/dbus.dart';

import '../xdg_desktop_portal_client.dart';
import '../xdg_portal_request.dart';

/// Portal to send email.
class XdgEmailPortal {
  /// The client that is connected to this portal.
  XdgDesktopPortalClient client;

  XdgEmailPortal(this.client);

  /// Present a window to compose an email.
  Future<void> composeEmail({
    String parentWindow = '',
    String? address,
    Iterable<String> addresses = const [],
    Iterable<String> cc = const [],
    Iterable<String> bcc = const [],
    String? subject,
    String? body,
  }) async {
    var request = XdgPortalRequest(client, () async {
      var options = <String, DBusValue>{};
      options['handle_token'] = DBusString(client.generateToken());
      if (address != null) {
        options['address'] = DBusString(address);
      }
      if (addresses.isNotEmpty) {
        options['addresses'] = DBusArray.string(addresses);
      }
      if (cc.isNotEmpty) {
        options['cc'] = DBusArray.string(cc);
      }
      if (bcc.isNotEmpty) {
        options['bcc'] = DBusArray.string(bcc);
      }
      if (subject != null) {
        options['subject'] = DBusString(subject);
      }
      if (body != null) {
        options['body'] = DBusString(body);
      }
      var result = await client.callMethod(
        'org.freedesktop.portal.Email',
        'ComposeEmail',
        [DBusString(parentWindow), DBusDict.stringVariant(options)],
        replySignature: DBusSignature('o'),
      );
      return result.returnValues[0].asObjectPath();
    });
    await request.stream.first;
  }
}
