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

  // ignore: avoid_annotating_with_dynamic
  void typedEmit(dynamic data) {
    if (data == null || data is D) {
      emitOnResponse(data);
    } else {
      log(data.runtimeType.toString());
    }
  }

  void emitOnResponse(D data);

  void setLoading();
}
