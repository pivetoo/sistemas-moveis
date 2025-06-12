import 'package:equatable/equatable.dart';
import '../../models/ordem_servico.dart';

abstract class OrdemServicoState extends Equatable {
  const OrdemServicoState();
  @override
  List<Object?> get props => [];
}

class OrdemServicoInitial extends OrdemServicoState {}

class OrdemServicoLoading extends OrdemServicoState {}

class OrdemServicoLoaded extends OrdemServicoState {
  final List<OrdemServico> ordens;
  final List<OrdemServico> ordensFiltradas;
  final String searchText;
  final bool isRefreshing;
  final int? concluindoOrdemId;

  const OrdemServicoLoaded({
    required this.ordens,
    required this.ordensFiltradas,
    this.searchText = '',
    this.isRefreshing = false,
    this.concluindoOrdemId,
  });

  @override
  List<Object?> get props => [
    ordens,
    ordensFiltradas,
    searchText,
    isRefreshing,
    concluindoOrdemId,
  ];

  OrdemServicoLoaded copyWith({
    List<OrdemServico>? ordens,
    List<OrdemServico>? ordensFiltradas,
    String? searchText,
    bool? isRefreshing,
    int? concluindoOrdemId,
    bool clearConcluindoOrdemId = false,
  }) {
    return OrdemServicoLoaded(
      ordens: ordens ?? this.ordens,
      ordensFiltradas: ordensFiltradas ?? this.ordensFiltradas,
      searchText: searchText ?? this.searchText,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      concluindoOrdemId: clearConcluindoOrdemId ? null : (concluindoOrdemId ?? this.concluindoOrdemId),
    );
  }
}

class OrdemServicoError extends OrdemServicoState {
  final String message;
  const OrdemServicoError(this.message);
  @override
  List<Object?> get props => [message];
}