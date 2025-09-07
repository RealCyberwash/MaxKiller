import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'endpoint.dart';

///
abstract interface class EndpointSelector {
  ///
  Endpoint<R> pick<R extends HlamTamResponse>(
    int version,
    List<EndpointFactory<R>> candidates,
  );
}
