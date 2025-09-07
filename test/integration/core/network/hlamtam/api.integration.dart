@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:max_killer/core/log.dart';
import 'package:max_killer/core/network/hlamtam/api.dart';
import 'package:max_killer/core/network/hlamtam/client.dart';
import 'package:max_killer/core/network/hlamtam/constants.dart';

import '../../../../helpers/data_generators.dart';

void main() {
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
      timeout: const Timeout(Duration(seconds: 10)),
      () async {
        final result = await api.auth.startAuth(
          phone: TestDataGenerator.randomPhone(),
        );

        expect(result.token, isA<String>());
      },
    );
  });
}
