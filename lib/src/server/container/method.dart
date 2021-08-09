/// The class that contains all HTTP methods
class Method {

  /// Returns the method class from the name of the method
  factory Method.fromValue(final String value) => values[value]!;

  const Method._({
    required this.name,
  });

  /// The name of the method
  final String name;

  @override
  String toString() => name;

  /// The HEAD method
  static const Method head = Method._(name: 'HEAD');

  /// The GET method
  static const Method get = Method._(name: 'GET');

  /// The POST method
  static const Method post = Method._(name: 'POST');

  /// The PUT method
  static const Method put = Method._(name: 'PUT');

  /// The PATCH method
  static const Method patch = Method._(name: 'PATCH');

  /// The DELETE method
  static const Method delete = Method._(name: 'DELETE');

  /// The OPTIONS method
  static const Method options = Method._(name: 'OPTIONS');

  /// A constant Map of the methods
  static const Map<String, Method> values = {
    'HEAD': head,
    'GET': get,
    'POST': post,
    'PUT': put,
    'PATCH': patch,
    'DELETE': delete,
    'OPTIONS': options,
  };

}
