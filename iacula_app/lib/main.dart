import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await AppBootstrap.createProductionOverrides();

  runApp(ProviderScope(overrides: overrides, child: const IaculaApp()));
}
