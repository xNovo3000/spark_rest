/// An interface for all handlable components
abstract class Handlable<R, P> {
  /// Called every time an handling is needed.
  ///
  /// Do not call this function, it is called from SparkREST from you.
  Future<R> onHandle(final P param);
}
