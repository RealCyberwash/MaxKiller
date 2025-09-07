@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:max_killer/core/log.dart';
import 'package:max_killer/core/network/hlamtam/api.dart';
import 'package:max_killer/core/network/hlamtam/client.dart';
import 'package:max_killer/core/network/hlamtam/constants.dart';
import 'package:max_killer/core/network/hlamtam/exceptions/protocol.dart';

void main() {
  const phone = '+79880749532';

  group('HlamTamClient (Test server)', () {
    late HlamTamClient client;
    late HlamTamApi api;

    setUpAll(() async {
      log.setLevel(LogLevel.trace);

      client = HlamTamClient();
      await client.connect(HlamTamDomain.tg, HlamTamTcp.port);
      api = HlamTamApi(client: client, version: HlamTamTcp.protocolVersion);
    });

    tearDownAll(() async {
      await client.close();
    });

    test(
      'START_AUTH → real response',
      timeout: const Timeout(Duration(seconds: 20)),
      () async {
        try {
          final res = await api.auth.startAuth(phone: phone);

          expect(res.token, isA<String>());
        } on ProtocolError catch (e) {
          throw e;
        }
      },
    );
  });
}
