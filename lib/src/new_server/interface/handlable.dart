abstract class Handlable<R, P> {

  Future<R> onHandle(final P param);

}