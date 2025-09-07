import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'operation.dart';

///
abstract interface class HlamTamOperationSelector {
  ///
  HlamTamOperation<R> pick<R extends HlamTamResponse>(
    int version,
    List<HlamTamOperationFactory<R>> candidates,
  );
}
