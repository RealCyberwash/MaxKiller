import 'package:get_it/get_it.dart';
import 'package:max_killer/features/auth/domain/auth_repository.dart';
import 'package:max_killer/features/auth/infrastructure/auth_repository_impl.dart';
import 'package:max_killer/shared/core/network/hlamtam/api.dart';
import 'package:max_killer/shared/core/network/hlamtam/api_impl.dart';
import 'package:max_killer/shared/core/network/hlamtam/client.dart';
import 'package:max_killer/shared/core/network/hlamtam/constants.dart';
import 'package:max_killer/shared/core/network/hlamtam/operations/selector_impl.dart';

///
const protocolVersion = HlamTamTcp.protocolVersion;

///
final di = GetIt.instance;

///
Future<void> setupDI() async {
  // core/network
  di.registerLazySingleton<HlamTamClient>(() => HlamTamClient());
  di.registerLazySingleton<HlamTamApi>(
    () => HlamTamApiImpl(
      client: di<HlamTamClient>(),
      version: protocolVersion,
      operationSelector: HlamTamOperationSelectorImpl(),
    ),
  );

  // features/auth
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(api: di<HlamTamApi>(), version: protocolVersion),
  );
}
