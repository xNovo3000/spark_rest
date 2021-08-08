/// A convenience class that contains all registred objects
abstract class Context {
  /// Registers an object in this [Context]
  void register(Object object);

  /// Finds a single instance with type [T]
  T findInstanceOfType<T>();

  /// Finds all the instances with type [T]
  Iterable<T> findInstancesOfType<T>();
}
