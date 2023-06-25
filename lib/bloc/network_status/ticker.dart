class Ticker {
  const Ticker();

  Stream<int> tick({required int seconds}) {
    return Stream.periodic(Duration(seconds: seconds), (x) => x);
  }
}
