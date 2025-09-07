import 'package:max_killer/shared/core/network/hlamtam/endpoints/selector.dart';
import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'endpoint.dart';

///
class EndpointSelectorImpl implements EndpointSelector {
  @override
  Endpoint<R> pick<R extends HlamTamResponse>(
    int version,
    List<EndpointFactory<R>> candidates,
  ) {
    for (final candidate in candidates) {
      final endpoint = candidate();
      if (endpoint.supports(version)) return endpoint;
    }
    throw StateError('No supported revision for v=$version');
  }
}
