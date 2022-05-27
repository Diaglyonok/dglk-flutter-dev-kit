import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import './reactor.dart';

abstract class CubitListener<T, D, S> extends Cubit<S> {
  final Reactor _repository;
  final T type;

  CubitListener(S state, this._repository, this.type) : super(state) {
    _repository.addListener(this);
  }

  @override
  Future<void> close() {
    _repository.removeListener(this);
    return super.close();
  }

  void typedEmit(dynamic data, T? type) {
    if (data == null || data is D) {
      emitOnResponse(data, type);
    } else {
      log(data.runtimeType.toString());
    }
  }

  void emitOnResponse(D response, T? type);

  void setLoading({D? data});
}
