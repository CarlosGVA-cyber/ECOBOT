# ECOBOT

Consola académica Flutter para demostrar la operación de un robot recolector de residuos. La aplicación abre en **demostración local** y funciona sin ESP32, conexión de red o cuenta.

## Ejecutar la demostración

Con Flutter que incluya Dart 3.13.7 o compatible, desde la raíz del proyecto:

```powershell
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Desde la bienvenida, elige **Iniciar sesión de prueba** y selecciona un perfil predefinido. También puedes entrar como visitante o elegir **Registro de prueba** para crear un alias temporal de visitante. La pantalla de recuperación explica el flujo, que en esta demo no envía correo. Usa la barra lateral en pantallas anchas y el menú superior en pantallas compactas.

| Perfil | Funciones disponibles |
| --- | --- |
| Administrador | Panel, estado, control, zonas, historial, catálogo de perfiles y configuración del endpoint |
| Operador | Panel, estado, control manual y automático, recolector e historial |
| Visitante | Panel, información, estado y demostración interactiva |

Todos los perfiles incluyen ayuda y perfil. La selección de perfiles sirve para mostrar la interfaz de cada rol. El registro público de prueba siempre crea un visitante.

## Funciones implementadas y simuladas

- **Funcional en la app.** Navegación adaptable, validación de alias y URL, perfil, cierre de sesión, selección, creación y retiro de zonas de prueba, e historial de hasta 100 eventos durante la sesión.
- **Simulación.** Las flechas cambian la dirección virtual. STOP detiene el movimiento y cancela la ruta automática; el recolector dispone de su propio interruptor. El modo automático alterna direcciones cada dos segundos. El estado representa valores locales, sin telemetría del ESP32.
- **Sesiones y datos.** Este proyecto no incluye Firebase, contraseñas ni cuentas persistentes. El alias, el historial y los cambios de zonas y configuración se reinician al salir. El catálogo de usuarios muestra los perfiles de prueba y sus permisos.

## Integración propuesta con ESP32

[Esp32Service](lib/esp32.dart) acepta la URL completa del endpoint y prepara una solicitud GET con el parámetro `cmd`. Por ejemplo, `GET http://192.168.4.1/command?cmd=S`. Configuración valida y muestra la URL de ejemplo sin contactar al dispositivo.

| Código | Operación |
| --- | --- |
| F / B | Avanzar / retroceder |
| L / R | Izquierda / derecha |
| S | Detener movimiento |
| C1 / C0 | Encender / apagar el recolector |

El transporte nativo aplica un tiempo límite de tres segundos, rechaza redirecciones y espera una respuesta HTTP 2xx. La consola demo usa exclusivamente la simulación, incluso para perfiles de administrador y operador. El transporte web directo no está implementado. Antes de integrar control real hay que confirmar el contrato con el firmware, implementar autenticación y autorización reales, configurar permisos de red de la plataforma y ensayar las respuestas y los mecanismos de parada en el equipo físico. El modo automático no tiene un comando de firmware asignado.

## Compilar

```powershell
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

La compilación web se verificó y quedó en `build/web/`. Para servirla, configura un servidor estático con esa carpeta como raíz.

La compilación Android quedó pendiente. Este proyecto requiere Android SDK Platform 36 y que Gradle pueda resolver los artefactos Android del motor Flutter. El entorno de entrega tenía Platform 37.0 y carecía de esos artefactos en la caché sin conexión. Cuando la compilación termine correctamente, instala el APK de depuración con `adb install -r build/app/outputs/flutter-apk/app-debug.apk`.

El repositorio ignora compilaciones, configuración local, claves de firma y archivos de credenciales.
