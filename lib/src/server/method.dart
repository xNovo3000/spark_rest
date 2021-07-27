// enum
class Method {

	factory Method.fromValue(final String value) => values.singleWhere((method) => method.name == value);

	const Method._({
		required this.name,
	});

	final String name;

	@override String toString() => name;

	// instances
	static const Method head = Method._(name: 'HEAD');
	static const Method get = Method._(name: 'GET');
	static const Method post = Method._(name: 'POST');
	static const Method put = Method._(name: 'PUT');
	static const Method patch = Method._(name: 'PATCH');
	static const Method delete = Method._(name: 'DELETE');
	static const Method options = Method._(name: 'OPTIONS');

	// list
	static const List<Method> values = [head, get, post, put, patch, delete, options];

}