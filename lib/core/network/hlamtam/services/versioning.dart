import 'package:max_killer/core/network/hlamtam/endpoints/endpoint.dart';

///
typedef AnyEndpointFactory = Endpoint Function();

///
Endpoint pickAnyEndpointByVersion(
  int protocolVersion,
  List<AnyEndpointFactory> candidates,
) {
  for (final build in candidates) {
    final endpoint = build();
    if (endpoint.supports(protocolVersion)) return endpoint;
  }
  throw StateError('No supported endpoint for protocol v$protocolVersion');
}
