import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/ordem_servico_repository.dart';
import '../../models/ordem_servico.dart';
import 'ordem_servico_event.dart';
import 'ordem_servico_state.dart';

class OrdemServicoBloc extends Bloc<OrdemServicoEvent, OrdemServicoState> {
  final OrdemServicoRepository _repository;

  OrdemServicoBloc({required OrdemServicoRepository repository})
      : _repository = repository,
        super(OrdemServicoInitial()) {

    on<OrdemServicoLoadRequested>(_onLoadRequested);
    on<OrdemServicoRefreshRequested>(_onRefreshRequested);
    on<OrdemServicoSearchChanged>(_onSearchChanged);
    on<OrdemServicoConcluirRequested>(_onConcluirRequested);
  }

  Future<void> _onLoadRequested(
    OrdemServicoLoadRequested event,
    Emitter<OrdemServicoState> emit,
  ) async {
    try {
      emit(OrdemServicoLoading());
      final ordens = await _repository.buscarMinhasOrdens();

      emit(OrdemServicoLoaded(
        ordens: ordens,
        ordensFiltradas: ordens,
      ));
    } catch (e) {
      emit(OrdemServicoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshRequested(
    OrdemServicoRefreshRequested event,
    Emitter<OrdemServicoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is OrdemServicoLoaded) {
        emit(currentState.copyWith(isRefreshing: true));

        final ordens = await _repository.buscarMinhasOrdens();
        final ordensFiltradas = _filtrarOrdens(ordens, currentState.searchText);

        emit(currentState.copyWith(
          ordens: ordens,
          ordensFiltradas: ordensFiltradas,
          isRefreshing: false,
        ));
      }
    } catch (e) {
      emit(OrdemServicoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSearchChanged(
    OrdemServicoSearchChanged event,
    Emitter<OrdemServicoState> emit,
  ) {
    final currentState = state;
    if (currentState is OrdemServicoLoaded) {
      final ordensFiltradas = _filtrarOrdens(currentState.ordens, event.searchText);

      emit(currentState.copyWith(
        searchText: event.searchText,
        ordensFiltradas: ordensFiltradas,
      ));
    }
  }

  Future<void> _onConcluirRequested(
    OrdemServicoConcluirRequested event,
    Emitter<OrdemServicoState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is OrdemServicoLoaded) {
        emit(currentState.copyWith(concluindoOrdemId: event.ordemId));

        await _repository.concluirOrdem(event.ordemId);

        final ordens = await _repository.buscarMinhasOrdens();
        final ordensFiltradas = _filtrarOrdens(ordens, currentState.searchText);

        emit(currentState.copyWith(
          ordens: ordens,
          ordensFiltradas: ordensFiltradas,
          clearConcluindoOrdemId: true,
        ));
      }
    } catch (e) {
      final currentState = state;
      if (currentState is OrdemServicoLoaded) {
        emit(currentState.copyWith(clearConcluindoOrdemId: true));
      }
      emit(OrdemServicoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  List<OrdemServico> _filtrarOrdens(List<OrdemServico> ordens, String searchText) {
    if (searchText.trim().isEmpty) {
      return ordens;
    }

    final textoBusca = searchText.toLowerCase().trim();
    return ordens.where((ordem) {
      return ordem.titulo.toLowerCase().contains(textoBusca) ||
             (ordem.descricao?.toLowerCase().contains(textoBusca) ?? false) ||
             (ordem.cliente?.nome.toLowerCase().contains(textoBusca) ?? false);
    }).toList();
  }
}