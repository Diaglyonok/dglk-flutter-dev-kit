import './cubit_listener.dart';
import 'repo_base_response.dart';

mixin Reactor<LST, ResponseType extends RepoResponse<LST>> {
  final List<CubitListener> listeners = [];
  final List<void Function(ResponseType)> dataListeners = [];

  void addDataListener(void Function(ResponseType) listener) {
    dataListeners.add(listener);
  }

  void removeDataListener(void Function(ResponseType) listener) {
    dataListeners.remove(listener);
  }

  void addListener(CubitListener listener) {
    listeners.add(listener);
  }

  void removeListener(CubitListener listener) {
    listeners.remove(listener);
  }

  void setLoading({required ResponseType currentData}) {
    for (var listener in listeners) {
      if (listener.type == currentData.type || currentData.type == null) {
        listener.typedEmit(currentData, isLoading: true);
      }
    }
  }

  void provideDataToListeners(ResponseType data) {
    for (var listener in listeners) {
      if (listener.type == data.type) {
        listener.typedEmit(data);
      }
    }

    for (var listener in dataListeners) {
      listener.call(data);
    }
  }
}
