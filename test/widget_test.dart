import 'package:ecobot/esp32.dart';
import 'package:ecobot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('El registro temporal entra solo como visitante', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 740);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());

    await tap(tester, find.text('Registro de prueba'));
    await tap(tester, find.text('Crear perfil temporal'));
    expect(find.text('Escribe un alias de prueba'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Perfil de prueba');
    await tap(tester, find.text('Crear perfil temporal'));

    expect(find.text('Hola, Perfil de prueba'), findsOneWidget);
    await tap(tester, find.byTooltip('Open navigation menu'));
    expect(find.text('Información'), findsOneWidget);
    expect(find.text('Configuración'), findsNothing);
    expect(find.text('Usuarios'), findsNothing);
    expect(find.text('Historial'), findsNothing);

    await tap(tester, find.text('Demostración'));
    await tap(tester, find.byTooltip('Avanzar'));
    expect(find.text('Avanzar'), findsOneWidget);
    await tap(tester, find.text('STOP'));
    expect(find.text('Detenido'), findsOneWidget);
  });

  testWidgets('Operador simula la ruta y registra acciones', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1250, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tap(tester, find.text('Iniciar sesión de prueba'));
    await tap(tester, find.text('Recuperar contraseña'));
    expect(find.text('Recuperación de contraseña'), findsOneWidget);
    await tap(tester, find.text('Volver al inicio de sesión'));
    await tap(tester, find.text('Abrir consola'));
    expect(find.text('Configuración'), findsNothing);
    await tap(tester, find.text('Abrir control'));

    await tap(tester, find.text('Modo automático'));
    expect(find.text('Avanzar'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Derecha'), findsOneWidget);
    await tap(tester, find.text('STOP'));
    await tap(tester, find.text('Recolector'));
    expect(find.text('Detenido'), findsOneWidget);
    expect(find.text('Recolector activo'), findsOneWidget);

    await tap(tester, find.text('Historial'));
    expect(find.text('Modo automático activado'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);
    expect(find.text('Activar recolector'), findsOneWidget);
  });

  testWidgets('Administrador agrega una zona y configura la URL', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1250, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tap(tester, find.text('Iniciar sesión de prueba'));
    await tap(tester, find.text('Operador'));
    await tap(tester, find.text('Administrador').last);
    await tap(tester, find.text('Abrir consola'));
    await tap(tester, find.text('Zonas de trabajo'));
    await tap(tester, find.text('Agregar zona').last);
    await tester.enterText(find.byType(TextFormField), 'Laboratorio');
    await tap(tester, find.text('Agregar'));
    await tap(tester, find.text('Laboratorio'));
    await tap(tester, find.text('Estado').first);
    expect(find.text('Zona activa · Laboratorio'), findsOneWidget);

    await tap(tester, find.text('Configuración'));
    await tester.enterText(find.byType(TextField), 'ftp://127.0.0.1/command');
    await tap(tester, find.text('Validar URL'));
    expect(find.textContaining('Usa una URL HTTP'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'http://127.0.0.1/cmd');
    await tap(tester, find.text('Validar URL'));
    expect(find.text('GET http://127.0.0.1/cmd?cmd=S'), findsOneWidget);
  });

  test('El contrato HTTP conserva los códigos del ESP32', () {
    final endpoint = Uri.parse('http://192.168.4.1/command');
    final service = Esp32Service(endpoint);
    expect(
      RobotCommand.values.map(
        (command) => service.commandUri(command).queryParameters['cmd'],
      ),
      orderedEquals(['F', 'B', 'L', 'R', 'S', 'C1', 'C0']),
    );
    expect(
      () => Esp32Service(Uri.parse('http://user:pass@localhost/cmd')),
      throwsArgumentError,
    );
  });
}
