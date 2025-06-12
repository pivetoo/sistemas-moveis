import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'src/blocs/auth/auth_bloc.dart';
import 'src/blocs/auth/auth_event.dart';
import 'src/blocs/ordem_servico/ordem_servico_bloc.dart';
import 'src/repository/auth_repository.dart';
import 'src/repository/ordem_servico_repository.dart';
import 'src/router/app_router.dart';
import 'shared/constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => authRepository,
        ),
        Provider<OrdemServicoRepository>(
          create: (_) => ordemServicoRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<OrdemServicoBloc>(
            create: (context) => OrdemServicoBloc(
              repository: context.read<OrdemServicoRepository>(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final router = AppRouter.createRouter(authBloc);

    return MaterialApp.router(
      title: 'ServiceCore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}