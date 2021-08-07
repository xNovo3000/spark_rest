/// A convenience class that contains all registred objects
abstract class Context {
  /// Finds a single instance with type [T]
  T findInstanceOfType<T>();

  /// Finds all the instances with type [T]
  Iterable<T> findInstancesOfType<T>();
}
