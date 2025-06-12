import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/ordem_servico/ordem_servico_bloc.dart';
import '../blocs/ordem_servico/ordem_servico_event.dart';
import '../blocs/ordem_servico/ordem_servico_state.dart';
import '../models/ordem_servico.dart';
import '../shared/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrdemServicoBloc>().add(OrdemServicoLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _handleSearch(String value) {
    context.read<OrdemServicoBloc>().add(OrdemServicoSearchChanged(value));
  }

  void _handleRefresh() {
    context.read<OrdemServicoBloc>().add(OrdemServicoRefreshRequested());
  }

  void _handleConcluirOrdem(int ordemId) {
    context.read<OrdemServicoBloc>().add(OrdemServicoConcluirRequested(ordemId));
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return const Color(0xFF856404); // Aguardando
      case 1: return const Color(0xFF28A745); // Em Andamento
      case 2: return const Color(0xFFDC3545); // Cancelada
      case 3: return const Color(0xFF28A745); // Concluída
      case 4: return const Color(0xFF17A2B8); // Exportada
      default: return const Color(0xFF6C757D);
    }
  }

  Color _getPrioridadeColor(int prioridade) {
    switch (prioridade) {
      case 0: return const Color(0xFF6C757D); // Baixa
      case 1: return const Color(0xFF007BFF); // Normal
      case 2: return const Color(0xFFFFC107); // Alta
      case 3: return const Color(0xFFDC3545); // Urgente
      default: return const Color(0xFF6C757D);
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Não definido';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusButton(OrdemServico ordem, bool isLoading) {
    switch (ordem.status) {
      case 0: // Aguardando Atendimento
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFC107)),
          ),
          child: const Text(
            '⏳ Aguardando',
            style: TextStyle(
              color: Color(0xFF856404),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case 1: // Em Andamento
      case 4: // Exportada
        return ElevatedButton(
          onPressed: isLoading ? null : () => _handleConcluirOrdem(ordem.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLoading ? AppColors.disabled : AppColors.success,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Text('✅', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                isLoading ? 'Concluindo...' : 'Concluir',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

      case 3: // Concluída
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD1EDDB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success),
          ),
          child: const Text(
            '✅ Concluída',
            style: TextStyle(
              color: Color(0xFF155724),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case 2: // Cancelada
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8D7DA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error),
          ),
          child: const Text(
            '❌ Cancelada',
            style: TextStyle(
              color: Color(0xFF721C24),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOrdemCard(OrdemServico ordem, bool isLoading) {
    return GestureDetector(
      onTap: () {
        context.go('/ordem/${ordem.id}');
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '#${ordem.id} - ${ordem.titulo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPrioridadeColor(ordem.prioridade).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getPrioridadeColor(ordem.prioridade)),
                  ),
                  child: Text(
                    ordem.prioridadeName,
                    style: TextStyle(
                      color: _getPrioridadeColor(ordem.prioridade),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            if (ordem.dataExecutar != null)
              Text(
                '📅 Agendamento: ${_formatarData(ordem.dataExecutar)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

            const SizedBox(height: 6),

            Text(
              ordem.descricao ?? 'Sem descrição disponível',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            if (ordem.cliente != null) ...[
              Text(
                '👤 ${ordem.cliente!.nome}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (ordem.cliente!.endereco != null)
                Text(
                  '📍 ${ordem.cliente!.endereco}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],

            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Criado: ${_formatarData(ordem.dataAbertura)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Toque para ver detalhes',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (ordem.status == 1 || ordem.status == 4)
                    GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLoading ? AppColors.disabled : AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoading)
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              const Icon(Icons.check, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              isLoading ? 'Aguarde...' : 'Finalizar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildStatusButton(ordem, isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(OrdemServico ordem, bool isLoading) {
    return GestureDetector(
      onTap: () {
        _handleConcluirOrdem(ordem.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isLoading ? AppColors.disabled : AppColors.success,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const Icon(Icons.check, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              isLoading ? 'Aguarde...' : 'Finalizar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, List<OrdemServico>> _agruparPorStatus(List<OrdemServico> ordens) {
    final Map<int, List<OrdemServico>> grupos = {};

    for (var ordem in ordens) {
      grupos[ordem.status] ??= [];
      grupos[ordem.status]!.add(ordem);
    }

    return grupos;
  }

  Widget _buildStatusSection(int status, List<OrdemServico> ordens, int? concluindoOrdemId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ordens.first.statusName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ordens.length.toString(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ...ordens.map((ordem) => _buildOrdemCard(
            ordem,
            concluindoOrdemId == ordem.id,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go('/login');
            }
          },
        ),
        BlocListener<OrdemServicoBloc, OrdemServicoState>(
          listener: (context, state) {
            if (state is OrdemServicoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'OS Control',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('Sair', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: AppColors.primary, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por título, descrição ou cliente',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              Expanded(
                child: BlocBuilder<OrdemServicoBloc, OrdemServicoState>(
                  builder: (context, state) {
                    if (state is OrdemServicoLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Carregando ordens de serviço...'),
                          ],
                        ),
                      );
                    }

                    if (state is OrdemServicoError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar ordens',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<OrdemServicoBloc>().add(OrdemServicoLoadRequested()),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is OrdemServicoLoaded) {
                      final ordens = state.ordensFiltradas;

                      if (ordens.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.assignment, size: 64, color: AppColors.textLight),
                              const SizedBox(height: 16),
                              Text(
                                state.searchText.isNotEmpty
                                  ? 'Nenhuma ordem encontrada'
                                  : 'Nenhuma ordem de serviço',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.searchText.isNotEmpty
                                  ? 'Tente buscar por outros termos'
                                  : 'Você não possui ordens de serviço no momento',
                              ),
                            ],
                          ),
                        );
                      }

                      final ordensAgrupadas = _agruparPorStatus(ordens);

                      return RefreshIndicator(
                        onRefresh: () async => _handleRefresh(),
                        color: AppColors.primary,
                        child: ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              color: const Color(0xFFF8F9FA),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total: ${state.ordens.length} ordem(ns)',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  ),
                                  if (state.searchText.isNotEmpty)
                                    Text(
                                      'Filtradas: ${ordens.length}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                    ),
                                ],
                              ),
                            ),

                            ...ordensAgrupadas.entries.map((entry) =>
                              _buildStatusSection(entry.key, entry.value, state.concluindoOrdemId)
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}