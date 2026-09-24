import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/framework/app_cubit.dart';
import 'core/framework/app_preferences.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/forgot_password_cubit.dart';
import 'features/auth/presentation/bloc/sign_in_cubit.dart';
import 'features/clients/data/datasources/clients_remote_datasource.dart';
import 'features/clients/data/repositories/clients_repository_impl.dart';
import 'features/clients/domain/repositories/clients_repository.dart';
import 'features/clients/domain/usecases/add_contact.dart';
import 'features/clients/domain/usecases/create_client.dart';
import 'features/clients/domain/usecases/get_client_detail.dart';
import 'features/clients/domain/usecases/get_clients.dart';
import 'features/clients/domain/usecases/set_certificates_email.dart';
import 'features/clients/presentation/bloc/client_detail_cubit.dart';
import 'features/clients/presentation/bloc/clients_list_cubit.dart';
import 'features/quotation/data/datasources/quotation_remote_datasource.dart';
import 'features/quotation/data/repositories/quotation_repository_impl.dart';
import 'features/quotation/domain/repositories/quotation_repository.dart';
import 'features/quotation/domain/usecases/get_quotations.dart';
import 'features/quotation/domain/usecases/log_client_response.dart';
import 'features/quotation/domain/usecases/save_draft.dart';
import 'features/quotation/domain/usecases/send_quotation.dart';
import 'features/quotation/domain/usecases/send_reminder.dart';
import 'features/quotation/presentation/bloc/quotation_detail_cubit.dart';
import 'features/quotation/presentation/bloc/quotation_form_cubit.dart';
import 'features/quotation/presentation/bloc/quotations_list_cubit.dart';
import 'features/requests/data/datasources/requests_remote_datasource.dart';
import 'features/requests/data/repositories/requests_repository_impl.dart';
import 'features/requests/domain/entities/inspection_request.dart';
import 'features/requests/domain/repositories/requests_repository.dart';
import 'features/requests/domain/usecases/assign_client.dart';
import 'features/requests/domain/usecases/get_request_detail.dart';
import 'features/requests/domain/usecases/get_requests.dart';
import 'features/requests/presentation/bloc/requests_list_cubit.dart';

final getIt = GetIt.instance;

/// Manual DI wiring. Must complete before [App] is built, since [AppCubit]
/// reads [AppPreferences] synchronously in its constructor.
Future<void> setupDependencies() async {
  const storage = FlutterSecureStorage();
  final preferences = AppPreferences(storage);
  await preferences.init();

  getIt.registerSingleton<AppPreferences>(preferences);
  getIt.registerSingleton<AppCubit>(AppCubit(preferences));

  _registerAuth(storage);
  _registerRequests();
  _registerQuotation();
  _registerClients();
}

void _registerAuth(FlutterSecureStorage storage) {
  getIt
    ..registerLazySingleton(AuthRemoteDataSource.new)
    ..registerLazySingleton(() => AuthLocalDataSource(storage))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton(() => SignIn(getIt()))
    ..registerLazySingleton(() => SignOut(getIt()))
    ..registerLazySingleton(() => GetCurrentUser(getIt()))
    ..registerLazySingleton(() => ResetPassword(getIt()))
    ..registerLazySingleton(() => AuthCubit(getIt(), getIt()))
    ..registerFactory(() => SignInCubit(getIt()))
    ..registerFactory(() => ForgotPasswordCubit(getIt()));
}

void _registerRequests() {
  getIt
    ..registerLazySingleton(RequestsRemoteDataSource.new)
    ..registerLazySingleton<RequestsRepository>(
      () => RequestsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetRequests(getIt()))
    ..registerLazySingleton(() => GetRequestDetail(getIt()))
    ..registerLazySingleton(() => AssignClient(getIt()))
    ..registerFactory(() => RequestsListCubit(getIt()));
}

void _registerQuotation() {
  getIt
    ..registerLazySingleton(QuotationRemoteDataSource.new)
    ..registerLazySingleton<QuotationRepository>(
      () => QuotationRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetQuotations(getIt()))
    ..registerLazySingleton(() => SaveDraft(getIt()))
    ..registerLazySingleton(() => SendQuotation(getIt(), getIt()))
    ..registerLazySingleton(() => LogClientResponse(getIt(), getIt()))
    ..registerLazySingleton(() => SendReminder(getIt()))
    ..registerFactory(() => QuotationsListCubit(getIt()))
    ..registerFactoryParam<QuotationFormCubit, InspectionRequest, void>(
      (request, _) => QuotationFormCubit(
        request: request,
        saveDraft: getIt(),
        sendQuotation: getIt(),
      ),
    )
    ..registerFactoryParam<QuotationDetailCubit, String, void>(
      (requestId, _) => QuotationDetailCubit(
        requestId: requestId,
        repository: getIt(),
        logClientResponse: getIt(),
        getRequestDetail: getIt(),
      ),
    );
}

void _registerClients() {
  getIt
    ..registerLazySingleton(ClientsRemoteDataSource.new)
    ..registerLazySingleton<ClientsRepository>(
      () => ClientsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetClients(getIt()))
    ..registerLazySingleton(() => GetClientDetail(getIt()))
    ..registerLazySingleton(() => CreateClient(getIt()))
    ..registerLazySingleton(() => AddContact(getIt()))
    ..registerLazySingleton(() => SetCertificatesEmail(getIt()))
    ..registerFactory(() => ClientsListCubit(getIt(), getIt()))
    ..registerFactoryParam<ClientDetailCubit, String, void>(
      (clientId, _) => ClientDetailCubit(
        clientId: clientId,
        getClientDetail: getIt(),
        getRequests: getIt(),
      ),
    );
}
