import 'package:max_killer/shared/core/network/hlamtam/operations/selector.dart';
import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'operation.dart';

///
class HlamTamOperationSelectorImpl implements HlamTamOperationSelector {
  @override
  HlamTamOperation<R> pick<R extends HlamTamResponse>(
    int version,
    List<HlamTamOperationFactory<R>> candidates,
  ) {
    for (final candidate in candidates) {
      final operation = candidate();
      if (operation.supports(version)) return operation;
    }
    throw StateError('No supported revision for v=$version');
  }
}
