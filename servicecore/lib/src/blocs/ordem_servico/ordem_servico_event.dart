import 'package:equatable/equatable.dart';

abstract class OrdemServicoEvent extends Equatable {
  const OrdemServicoEvent();
  @override
  List<Object?> get props => [];
}

class OrdemServicoLoadRequested extends OrdemServicoEvent {}

class OrdemServicoRefreshRequested extends OrdemServicoEvent {}

class OrdemServicoSearchChanged extends OrdemServicoEvent {
  final String searchText;
  const OrdemServicoSearchChanged(this.searchText);
  @override
  List<Object?> get props => [searchText];
}

class OrdemServicoConcluirRequested extends OrdemServicoEvent {
  final int ordemId;
  const OrdemServicoConcluirRequested(this.ordemId);
  @override
  List<Object?> get props => [ordemId];
}