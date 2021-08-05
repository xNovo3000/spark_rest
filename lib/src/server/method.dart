/// The class that contains all HTTP methods
/// 
/// This class is still work-in-progress and it is not been implemented already.
/// Do not use this class for the moment.
class Method {

	/// Returns the method class from the name of the method
	factory Method.fromValue(final String value) => values.singleWhere((method) => method.name == value);

	/// Const private constructor
	/// 
	/// No one can create custom methods
	const Method._({
		required this.name,
	});

	/// The name of the method
	final String name;

	@override String toString() => name;

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

	/// A constant List of the values in this enum, in order of their declaration
	static const List<Method> values = [head, get, post, put, patch, delete, options];

}