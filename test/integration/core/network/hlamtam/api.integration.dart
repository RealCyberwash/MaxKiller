@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:max_killer/features/auth/domain/auth_repository.dart';
import 'package:max_killer/features/auth/infrastructure/auth_repository_impl.dart';
import 'package:max_killer/shared/core/log.dart';
import 'package:max_killer/shared/core/network/hlamtam/api.dart';
import 'package:max_killer/shared/core/network/hlamtam/api_impl.dart';
import 'package:max_killer/shared/core/network/hlamtam/client.dart';
import 'package:max_killer/shared/core/network/hlamtam/constants.dart';
import 'package:max_killer/shared/core/network/hlamtam/endpoints/selector_impl.dart';

import '../../../../helpers/data_generators.dart';

void main() {
  group('HlamTamClient (Test server)', () {
    late HlamTamClient client;
    late HlamTamApi api;
    late AuthRepository auth;

    setUpAll(() async {
      log.setLevel(LogLevel.trace);

      client = HlamTamClient();
      await client.connect(HlamTamDomain.tg, HlamTamTcp.port);
      api = HlamTamApiImpl(
        client: client,
        version: HlamTamTcp.protocolVersion,
        endpointSelector: EndpointSelectorImpl(),
      );
      auth = AuthRepositoryImpl(api: api, version: HlamTamTcp.protocolVersion);
    });

    tearDownAll(() async {
      await client.close();
    });

    test(
      'START_AUTH → real response',
      timeout: const Timeout(Duration(seconds: 10)),
      () async {
        final result = await auth.startAuth(
          phone: TestDataGenerator.randomPhone(),
        );

        expect(result.token, isA<String>());
      },
    );
  });
}
