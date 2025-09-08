import 'package:flutter/material.dart';
import 'package:max_killer/app/app.dart';
import 'package:max_killer/app/di.dart';
import 'package:max_killer/shared/core/network/hlamtam/client.dart';
import 'package:max_killer/shared/core/network/hlamtam/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  await di<HlamTamClient>().connect(HlamTamDomain.tg, HlamTamTcp.port);
  runApp(const MaxKillerApp());
}
