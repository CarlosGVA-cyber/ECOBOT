import 'esp32_transport_stub.dart'
    if (dart.library.io) 'esp32_transport_io.dart'
    as transport;

enum RobotCommand {
  forward('F', 'Avanzar'),
  backward('B', 'Retroceder'),
  left('L', 'Izquierda'),
  right('R', 'Derecha'),
  stop('S', 'STOP'),
  collectorOn('C1', 'Activar recolector'),
  collectorOff('C0', 'Desactivar recolector');

  const RobotCommand(this.code, this.label);
  final String code;
  final String label;
}

/// Proposed firmware contract: `GET <endpoint>?cmd=<code>`.
class Esp32Service {
  Esp32Service(this.endpoint) {
    if (!isValidEndpoint(endpoint)) {
      throw ArgumentError('Se requiere una URL HTTP(S) sin credenciales.');
    }
  }

  final Uri endpoint;

  static bool isValidEndpoint(Uri uri) =>
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.hasAuthority &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      !uri.hasQuery &&
      !uri.hasFragment;

  Uri commandUri(RobotCommand command) =>
      endpoint.replace(queryParameters: {'cmd': command.code});

  Future<void> send(RobotCommand command) =>
      transport.send(commandUri(command));
}
