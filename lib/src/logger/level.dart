// enum
class Level {

	const Level._({
		required this.name,
		required this.color,
	});

	final String name;
	final String color;

	// enums
	static const Level debug = Level._(name: 'DEBUG', color: '\x1B[37m');
	static const Level info = Level._(name: 'INFO', color: '\x1B[34m');
	static const Level warning = Level._(name: 'WARN', color: '\x1B[33m');
	static const Level error = Level._(name: 'ERR', color: '\x1B[31m');

	// container
	static const List<Level> values = [debug, info, warning, error];

}