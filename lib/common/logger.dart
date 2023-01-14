import 'package:logger/logger.dart' show Logger, PrettyPrinter;

final logger = Logger(printer: PrettyPrinter(methodCount: 0, noBoxingByDefault: true));
