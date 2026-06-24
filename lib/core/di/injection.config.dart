// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../data/auth/datasources/auth_remote_datasource.dart' as _i691;
import '../../data/auth/repositories/auth_repository_impl.dart' as _i388;
import '../../data/history/datasources/history_remote_data_source.dart'
    as _i168;
import '../../data/history/repositories/history_repository_impl.dart' as _i996;
import '../../data/home/datasources/home_local_data_source.dart' as _i912;
import '../../data/home/datasources/home_remote_data_source.dart' as _i892;
import '../../data/home/repositories/home_repository_impl.dart' as _i382;
import '../../data/incoming_goods/datasources/incoming_goods_remote_datasource.dart'
    as _i4;
import '../../data/incoming_goods/repositories/incoming_goods_repository_impl.dart'
    as _i928;
import '../../data/products/datasources/product_remote_datasource.dart'
    as _i165;
import '../../data/products/repositories/products_repository_impl.dart'
    as _i906;
import '../../data/transactions/datasources/transactions_remote_data_source.dart'
    as _i59;
import '../../data/transactions/repositories/transactions_repository_impl.dart'
    as _i704;
import '../../domain/auth/repositories/auth_repository.dart' as _i626;
import '../../domain/auth/usecases/get_profile_usecase.dart' as _i520;
import '../../domain/auth/usecases/login_usecase.dart' as _i551;
import '../../domain/history/repositories/history_repository.dart' as _i550;
import '../../domain/home/repositories/home_repository.dart' as _i536;
import '../../domain/home/usecases/get_dashboard_data.dart' as _i511;
import '../../domain/incoming_goods/repositories/incoming_goods_repository.dart'
    as _i954;
import '../../domain/incoming_goods/usecases/get_incoming_goods.dart' as _i454;
import '../../domain/incoming_goods/usecases/get_suppliers.dart' as _i298;
import '../../domain/incoming_goods/usecases/save_incoming_goods.dart' as _i830;
import '../../domain/products/repositories/products_repository.dart' as _i744;
import '../../domain/products/usecases/get_categories.dart' as _i914;
import '../../domain/products/usecases/get_products.dart' as _i696;
import '../../domain/transactions/repositories/transactions_repository.dart'
    as _i748;
import '../../domain/transactions/usecases/get_customer_history.dart' as _i362;
import '../../domain/transactions/usecases/save_transaction.dart' as _i337;
import '../../presentation/auth/controller/auth_controller.dart' as _i968;
import '../../presentation/home/controller/home_controller.dart' as _i888;
import '../../presentation/incoming_goods/bloc/incoming_goods_controller.dart'
    as _i598;
import '../../presentation/products/controller/product_controller.dart' as _i46;
import '../network/dio_client.dart' as _i667;
import 'home_module.dart' as _i473;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final homeModule = _$HomeModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i912.HomeLocalDataSource>(
      () => homeModule.homeLocalDataSource,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i667.DioClient>(
      () => _i667.DioClient(gh<_i361.Dio>(), gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i4.IncomingGoodsRemoteDataSource>(
      () => _i4.IncomingGoodsRemoteDataSourceImpl(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i954.IncomingGoodsRepository>(
      () => _i928.IncomingGoodsRepositoryImpl(
        gh<_i4.IncomingGoodsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i691.AuthRemoteDataSource>(
      () => _i691.AuthRemoteDataSourceImpl(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i168.HistoryRemoteDataSource>(
      () => _i168.HistoryRemoteDataSourceImpl(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i892.HomeRemoteDataSource>(
      () => _i892.HomeRemoteDataSourceImpl(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i165.ProductRemoteDataSource>(
      () => _i165.ProductRemoteDataSourceImpl(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i59.TransactionsRemoteDataSource>(
      () => _i59.TransactionsRemoteDataSourceImpl(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i744.ProductsRepository>(
      () => _i906.ProductsRepositoryImpl(gh<_i165.ProductRemoteDataSource>()),
    );
    gh.lazySingleton<_i626.AuthRepository>(
      () => _i388.AuthRepositoryImpl(
        gh<_i691.AuthRemoteDataSource>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i536.HomeRepository>(
      () => _i382.HomeRepositoryImpl(gh<_i892.HomeRemoteDataSource>()),
    );
    gh.factory<_i511.GetDashboardData>(
      () => _i511.GetDashboardData(gh<_i536.HomeRepository>()),
    );
    gh.lazySingleton<_i748.TransactionsRepository>(
      () => _i704.TransactionsRepositoryImpl(
        gh<_i59.TransactionsRemoteDataSource>(),
      ),
    );
    gh.factory<_i454.GetIncomingGoods>(
      () => _i454.GetIncomingGoods(gh<_i954.IncomingGoodsRepository>()),
    );
    gh.factory<_i298.GetSuppliers>(
      () => _i298.GetSuppliers(gh<_i954.IncomingGoodsRepository>()),
    );
    gh.factory<_i830.SaveIncomingGoods>(
      () => _i830.SaveIncomingGoods(gh<_i954.IncomingGoodsRepository>()),
    );
    gh.lazySingleton<_i550.HistoryRepository>(
      () => _i996.HistoryRepositoryImpl(gh<_i168.HistoryRemoteDataSource>()),
    );
    gh.lazySingleton<_i520.GetProfileUseCase>(
      () => _i520.GetProfileUseCase(gh<_i626.AuthRepository>()),
    );
    gh.factory<_i888.HomeBloc>(
      () => _i888.HomeBloc(getDashboardData: gh<_i511.GetDashboardData>()),
    );
    gh.lazySingleton<_i914.GetCategories>(
      () => _i914.GetCategories(gh<_i744.ProductsRepository>()),
    );
    gh.lazySingleton<_i696.GetProducts>(
      () => _i696.GetProducts(gh<_i744.ProductsRepository>()),
    );
    gh.factory<_i598.IncomingGoodsController>(
      () => _i598.IncomingGoodsController(
        getSuppliers: gh<_i298.GetSuppliers>(),
        saveIncomingGoods: gh<_i830.SaveIncomingGoods>(),
        getIncomingGoods: gh<_i454.GetIncomingGoods>(),
      ),
    );
    gh.lazySingleton<_i551.LoginUseCase>(
      () => _i551.LoginUseCase(gh<_i626.AuthRepository>()),
    );
    gh.lazySingleton<_i362.GetCustomerHistory>(
      () => _i362.GetCustomerHistory(gh<_i748.TransactionsRepository>()),
    );
    gh.factory<_i337.SaveTransaction>(
      () => _i337.SaveTransaction(gh<_i748.TransactionsRepository>()),
    );
    gh.factory<_i46.ProductController>(
      () => _i46.ProductController(
        gh<_i696.GetProducts>(),
        gh<_i914.GetCategories>(),
      ),
    );
    gh.factory<_i968.AuthController>(
      () => _i968.AuthController(
        loginUseCase: gh<_i551.LoginUseCase>(),
        getProfileUseCase: gh<_i520.GetProfileUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$HomeModule extends _i473.HomeModule {}
