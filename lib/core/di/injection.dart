import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/services/theme_provider.dart';
import 'package:mitrapos/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
  getIt.registerLazySingleton(() => ThemeProvider());
}
