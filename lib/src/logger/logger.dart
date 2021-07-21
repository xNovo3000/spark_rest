import 'package:spark_http/src/logger/level.dart';

abstract class Logger {

	Logger._();

	static void debug(final String caller, final String message) =>
		_fromLevel(Level.debug, caller, message);
	
	static void info(final String caller, final String message) =>
		_fromLevel(Level.info, caller, message);
	
	static void warning(final String caller, final String message) =>
		_fromLevel(Level.warning, caller, message);
	
	static void error(final String caller, final String message) =>
		_fromLevel(Level.error, caller, message);

	static void _fromLevel(final Level level, final String caller, final String message) =>
		print('${level.color}${DateTime.now()} - [${level.name}] $caller: $message\x1B[0m');

}