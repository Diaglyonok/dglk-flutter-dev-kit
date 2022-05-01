import './cubit_listener.dart';

mixin Reactor<LST, ResponseType> {
  final List<CubitListener> listeners = [];

  void addListener(CubitListener listener) {
    listeners.add(listener);
  }

  void removeListener(CubitListener listener) {
    listeners.remove(listener);
  }

  void setLoading({LST? type}) {
    for (var listener in listeners) {
      if (listener.type == type || type == null) {
        listener.setLoading();
      }
    }
  }

  void provideDataToListeners(ResponseType data, {LST? type}) {
    for (var listener in listeners) {
      if (listener.type == type || type == null) {
        listener.typedEmit(data);
      }
    }
  }
}
