/// If you read this source code, you may find this surprise.
/// a small subscription library

part of flutter_video_compress;

class ObservableBuilder<T> {
  final StreamController<T> _observable = StreamController();
  bool _notSubscribed = true;

  void next(T value) {
    _observable.add(value);
  }

  Subscription subscribe(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    _notSubscribed = false;
    _observable.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    return Subscription(_observable.close);
  }
}

class Subscription {
  final VoidCallback unsubscribe;
  const Subscription(this.unsubscribe);
}
