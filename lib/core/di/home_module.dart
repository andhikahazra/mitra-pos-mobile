import 'package:injectable/injectable.dart';
import 'package:mitrapos/data/home/datasources/home_local_data_source.dart';

/// Module for registering dependencies in the home feature
@module
abstract class HomeModule {
  @lazySingleton
  HomeLocalDataSource get homeLocalDataSource => HomeLocalDataSourceImpl();
}
