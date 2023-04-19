import 'dart:developer';

import 'package:dglk_flutter_dev_kit/architecture/src/repo_base_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './reactor.dart';

abstract class CubitListener<T, D extends RepoResponse<T>, S> extends Cubit<S> {
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

  void typedEmit(RepoResponse<T> data) {
    if (data is D) {
      emitOnResponse(data);
    } else {
      log(data.runtimeType.toString());
    }
  }

  void emitOnResponse(D response);

  void setLoading({D? data});
}
