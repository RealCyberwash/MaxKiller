import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'operations/operation.dart';

///
abstract interface class HlamTamApi {
  ///
  Future<R> sendVersioned<R extends HlamTamResponse>(
    int version,
    List<HlamTamOperationFactory<R>> candidates,
  );

  ///
  Future<R> send<R extends HlamTamResponse>(HlamTamOperation<R> operation);
}
