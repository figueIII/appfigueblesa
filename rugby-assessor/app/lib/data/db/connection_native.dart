import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Base de datos de la app en el almacenamiento privado del dispositivo, en un isolate de fondo:
/// las escrituras nunca bloquean el frame de la UI.
QueryExecutor openAppConnection() => driftDatabase(name: 'refassess');
