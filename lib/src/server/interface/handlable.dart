/// Convenience class for all handlable objects
abstract class Handlable<U, V> {
  /// Method called when something should be handled in this class
  Future<V> onHandle(U param);
}
