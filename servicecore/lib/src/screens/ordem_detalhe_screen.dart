import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/ordem_servico/ordem_servico_bloc.dart';
import '../blocs/ordem_servico/ordem_servico_event.dart';
import '../blocs/ordem_servico/ordem_servico_state.dart';
import '../models/ordem_servico.dart';
import '../repository/ordem_servico_repository.dart';
import '../shared/constants/app_colors.dart';

class OrdemDetalheScreen extends StatefulWidget {
  final int ordemId;

  const OrdemDetalheScreen({
    Key? key,
    required this.ordemId,
  }) : super(key: key);

  @override
  State<OrdemDetalheScreen> createState() => _OrdemDetalheScreenState();
}

class _OrdemDetalheScreenState extends State<OrdemDetalheScreen> {
  OrdemServico? ordem;
  bool isLoading = true;
  bool isFinalizando = false;
  final TextEditingController _observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarOrdem();
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _carregarOrdem() async {
    try {
      setState(() => isLoading = true);
      final ordemCarregada = await ordemServicoRepository.buscarOrdemPorId(widget.ordemId);
      setState(() {
        ordem = ordemCarregada;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar ordem: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _iniciarAtendimento() async {
    if (ordem == null) return;

    try {
      setState(() => isFinalizando = true);
      await ordemServicoRepository.iniciarAtendimento(ordem!.id);

      await _carregarOrdem();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atendimento iniciado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar atendimento: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => isFinalizando = false);
    }
  }

  Future<void> _finalizarOrdem() async {
    if (ordem == null) return;

    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Ordem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja finalizar esta ordem de serviço?'),
            const SizedBox(height: 16),
            TextField(
              controller: _observacoesController,
              decoration: const InputDecoration(
                labelText: 'Observações finais (opcional)',
                hintText: 'Digite observações sobre o serviço...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirma != true) return;

    try {
      setState(() => isFinalizando = true);
      await ordemServicoRepository.concluirOrdem(ordem!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordem finalizada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );

        context.read<OrdemServicoBloc>().add(OrdemServicoRefreshRequested());
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar ordem: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => isFinalizando = false);
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return const Color(0xFF856404); // Aguardando
      case 1: return AppColors.success; // Em Andamento
      case 2: return AppColors.error; // Cancelada
      case 3: return AppColors.success; // Concluída
      case 4: return AppColors.info; // Exportada
      default: return AppColors.textSecondary;
    }
  }

  Color _getPrioridadeColor(int prioridade) {
    switch (prioridade) {
      case 0: return AppColors.textSecondary; // Baixa
      case 1: return Colors.blue; // Normal
      case 2: return AppColors.warning; // Alta
      case 3: return AppColors.error; // Urgente
      default: return AppColors.textSecondary;
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Não definido';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: color ?? AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (ordem == null) return const SizedBox.shrink();

    switch (ordem!.status) {
      case 0: // Aguardando Atendimento
        return ElevatedButton.icon(
          onPressed: isFinalizando ? null : _iniciarAtendimento,
          icon: isFinalizando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.play_arrow),
          label: Text(isFinalizando ? 'Iniciando...' : 'Iniciar Atendimento'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        );

      case 1: // Em Andamento
      case 4: // Exportada
        return ElevatedButton.icon(
          onPressed: isFinalizando ? null : _finalizarOrdem,
          icon: isFinalizando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.check_circle),
          label: Text(isFinalizando ? 'Finalizando...' : 'Finalizar Ordem'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        );

      case 3: // Concluída
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Text(
                'Ordem Finalizada',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case 2: // Cancelada
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Ordem Cancelada',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Ordem #${widget.ordemId}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Carregando detalhes da ordem...'),
                ],
              ),
            )
          : ordem == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      const Text('Ordem não encontrada'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/dashboard'),
                        child: const Text('Voltar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(ordem!.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getStatusColor(ordem!.status)),
                              ),
                              child: Text(
                                ordem!.statusName,
                                style: TextStyle(
                                  color: _getStatusColor(ordem!.status),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getPrioridadeColor(ordem!.prioridade).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getPrioridadeColor(ordem!.prioridade)),
                            ),
                            child: Text(
                              ordem!.prioridadeName,
                              style: TextStyle(
                                color: _getPrioridadeColor(ordem!.prioridade),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildInfoCard(
                        title: 'Título',
                        content: ordem!.titulo,
                        icon: Icons.assignment,
                      ),

                      if (ordem!.descricao != null && ordem!.descricao!.isNotEmpty)
                        _buildInfoCard(
                          title: 'Descrição',
                          content: ordem!.descricao!,
                          icon: Icons.description,
                        ),

                      if (ordem!.dataExecutar != null)
                        _buildInfoCard(
                          title: 'Data de Execução',
                          content: _formatarData(ordem!.dataExecutar),
                          icon: Icons.schedule,
                          color: AppColors.primary,
                        ),

                      _buildInfoCard(
                        title: 'Data de Abertura',
                        content: _formatarData(ordem!.dataAbertura),
                        icon: Icons.calendar_today,
                      ),

                      if (ordem!.cliente != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Informações do Cliente',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          title: 'Nome',
                          content: ordem!.cliente!.nome,
                          icon: Icons.person,
                        ),

                        if (ordem!.cliente!.endereco != null && ordem!.cliente!.endereco!.isNotEmpty)
                          _buildInfoCard(
                            title: 'Endereço',
                            content: ordem!.cliente!.endereco!,
                            icon: Icons.location_on,
                          ),

                        if (ordem!.cliente!.telefone != null && ordem!.cliente!.telefone!.isNotEmpty)
                          _buildInfoCard(
                            title: 'Telefone',
                            content: ordem!.cliente!.telefone!,
                            icon: Icons.phone,
                          ),

                        if (ordem!.cliente!.email != null && ordem!.cliente!.email!.isNotEmpty)
                          _buildInfoCard(
                            title: 'Email',
                            content: ordem!.cliente!.email!,
                            icon: Icons.email,
                          ),
                      ],

                      const SizedBox(height: 32),

                      Center(child: _buildActionButton()),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}