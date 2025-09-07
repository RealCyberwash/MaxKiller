import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'endpoints/endpoint.dart';

///
abstract interface class HlamTamApi {
  ///
  Future<R> sendVersioned<R extends HlamTamResponse>(
    int version,
    List<EndpointFactory<R>> candidates,
  );

  ///
  Future<R> send<R extends HlamTamResponse>(Endpoint<R> endpoint);
}
