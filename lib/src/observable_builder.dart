part of flutter_video_compress;

class ObservableBuilder<T> {
  final T _value;
  final StreamController<T> _observable = StreamController();

  ObservableBuilder(this._value) : assert(_value != null);

  void next(T value) {
    _observable.add(value);
  }

  Subscription subscribe(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    _observable.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    return Subscription(_unsubscribe);
  }

  void _unsubscribe() {
    _observable
      ..add(_value)
      ..close();
  }
}

class Subscription {
  final VoidCallback unsubscribe;
  const Subscription(this.unsubscribe);
}
