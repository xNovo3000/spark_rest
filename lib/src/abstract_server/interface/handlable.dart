abstract class Handlable<U, V> {
  
  Future<V> onHandle(U param);

}