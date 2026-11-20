import 'dart:async';

import 'package:flutter/material.dart';

import 'esp32.dart';
import 'ui.dart';

enum Section {
  dashboard('Panel general', Icons.dashboard_outlined),
  control('Control', Icons.gamepad_outlined),
  status('Estado', Icons.monitor_heart_outlined),
  zones('Zonas de trabajo', Icons.map_outlined),
  history('Historial', Icons.history),
  users('Usuarios', Icons.group_outlined),
  settings('Configuración', Icons.settings_outlined),
  info('Información', Icons.info_outline),
  help('Ayuda', Icons.help_outline),
  profile('Perfil', Icons.person_outline);

  const Section(this.label, this.icon);
  final String label;
  final IconData icon;
}

class ConsoleScreen extends StatefulWidget {
  const ConsoleScreen({super.key, required this.session});
  final Session session;

  @override
  State<ConsoleScreen> createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends State<ConsoleScreen> {
  Section section = Section.dashboard;
  RobotCommand direction = RobotCommand.stop;
  bool collector = false;
  Timer? automatic;
  int routeStep = 0;
  final events = <({DateTime time, String label})>[];
  final zones = ['Patio central', 'Jardín norte', 'Zona de reciclaje'];
  String? activeZone = 'Patio central';
  final endpointField = TextEditingController(
    text: 'http://192.168.4.1/command',
  );
  Esp32Service service = Esp32Service(Uri.parse('http://192.168.4.1/command'));
  String? endpointError;

  Role get role => widget.session.role;
  List<Section> get sections => [
    Section.dashboard,
    if (role == Role.visitor) Section.info,
    Section.status,
    Section.control,
    if (role == Role.admin) Section.zones,
    if (role != Role.visitor) Section.history,
    if (role == Role.admin) ...[Section.users, Section.settings],
    Section.help,
    Section.profile,
  ];

  @override
  void dispose() {
    automatic?.cancel();
    endpointField.dispose();
    super.dispose();
  }

  void record(String event) {
    events.insert(0, (time: DateTime.now(), label: event));
    if (events.length > 100) events.removeLast();
  }

  void stopAutomatic() {
    automatic?.cancel();
    automatic = null;
  }

  void simulate(RobotCommand command) {
    setState(() {
      switch (command) {
        case RobotCommand.collectorOn:
          collector = true;
        case RobotCommand.collectorOff:
          collector = false;
        default:
          stopAutomatic();
          direction = command;
      }
      record(command.label);
    });
  }

  void toggleAutomatic(bool enabled) {
    setState(() {
      stopAutomatic();
      if (!enabled) {
        direction = RobotCommand.stop;
        record('Modo automático desactivado');
        return;
      }
      direction = RobotCommand.forward;
      routeStep = 0;
      record('Modo automático activado');
      const route = [
        RobotCommand.forward,
        RobotCommand.right,
        RobotCommand.forward,
        RobotCommand.left,
      ];
      automatic = Timer.periodic(const Duration(seconds: 2), (_) {
        setState(() {
          routeStep = (routeStep + 1) % route.length;
          direction = route[routeStep];
        });
      });
    });
  }

  void select(Section destination) => setState(() => section = destination);

  void signOut() => Navigator.of(context).pushReplacementNamed('/');

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: AppBar(
        title: const Brand(),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: mint.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'DEMO LOCAL',
              style: TextStyle(
                fontSize: 12,
                color: mint,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(child: SafeArea(child: menu(closeDrawer: true))),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Container(
                width: 228,
                decoration: const BoxDecoration(
                  color: panel,
                  border: Border(right: BorderSide(color: Color(0xFF24364A))),
                ),
                child: Material(type: MaterialType.transparency, child: menu()),
              ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(section),
                padding: EdgeInsets.all(wide ? 32 : 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.label,
                          style: const TextStyle(
                            color: mint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          section == Section.control && role == Role.visitor
                              ? 'Demostración'
                              : section.label,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 20),
                        ...content(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menu({bool closeDrawer = false}) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
    children: [
      for (final item in sections)
        ListTile(
          dense: true,
          selected: section == item,
          selectedColor: mint,
          selectedTileColor: mint.withValues(alpha: .10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(item.icon),
          title: Text(
            item == Section.control && role == Role.visitor
                ? 'Demostración'
                : item.label,
          ),
          onTap: () {
            if (closeDrawer) Navigator.of(context).pop();
            select(item);
          },
        ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Cerrar sesión'),
        onTap: signOut,
      ),
    ],
  );

  List<Widget> content() => switch (section) {
    Section.dashboard => dashboard(),
    Section.control => control(),
    Section.status => [statusPanel()],
    Section.zones => [zonePanel()],
    Section.history => [historyPanel()],
    Section.users => [
      Panel(
        child: Column(
          children: [
            const ListTile(
              title: Text('Perfiles predefinidos'),
              subtitle: Text('Permisos disponibles en esta demostración.'),
            ),
            for (final profile in Role.values)
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: mint),
                title: Text(profile.label),
                subtitle: Text(switch (profile) {
                  Role.admin => 'Control, zonas, historial y configuración',
                  Role.operator => 'Control, estado e historial',
                  Role.visitor => 'Información, estado y demostración',
                }),
              ),
          ],
        ),
      ),
    ],
    Section.settings => [settingsPanel()],
    Section.info => [
      const Panel(
        child: Text(
          'ECOBOT es un proyecto académico de robótica para la recolección de residuos. En la demostración puedes consultar el estado y probar el movimiento del robot virtual.',
        ),
      ),
    ],
    Section.help => [
      const Panel(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.gamepad_outlined),
              title: Text('Prueba el control'),
              subtitle: Text(
                'Usa las flechas para cambiar la dirección. STOP detiene el movimiento y cancela el modo automático.',
              ),
            ),
            ListTile(
              leading: Icon(Icons.recycling),
              title: Text('Recolector'),
              subtitle: Text('Enciéndelo y apágalo con su propio interruptor.'),
            ),
            ListTile(
              leading: Icon(Icons.memory),
              title: Text('ESP32'),
              subtitle: Text(
                'Esta consola simula las operaciones. Configuración permite validar la URL y ver una solicitud de ejemplo.',
              ),
            ),
          ],
        ),
      ),
    ],
    Section.profile => [
      Panel(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(widget.session.name),
          subtitle: Text('${role.label} · Perfil temporal'),
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: signOut,
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
      ),
    ],
  };

  List<Widget> dashboard() => [
    Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy_outlined, color: mint, size: 42),
          const SizedBox(height: 12),
          Text(
            'Hola, ${widget.session.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Robot virtual listo. Explora los controles y observa los cambios de estado en tiempo real.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => select(Section.control),
                icon: const Icon(Icons.gamepad_outlined),
                label: Text(
                  role == Role.visitor
                      ? 'Probar demostración'
                      : 'Abrir control',
                ),
              ),
              OutlinedButton(
                onPressed: () => select(Section.status),
                child: const Text('Ver estado'),
              ),
            ],
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    statusPanel(),
  ];

  Widget statusPanel() => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado simulado', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: [
            Chip(
              avatar: const Icon(Icons.open_with, size: 18),
              label: Text(
                direction == RobotCommand.stop ? 'Detenido' : direction.label,
              ),
            ),
            Chip(
              avatar: const Icon(Icons.recycling, size: 18),
              label: Text(
                collector ? 'Recolector activo' : 'Recolector apagado',
              ),
            ),
            Chip(
              avatar: const Icon(Icons.route, size: 18),
              label: Text(
                automatic == null ? 'Modo manual' : 'Modo automático',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Zona activa · ${activeZone ?? 'Sin asignar'}'),
        const SizedBox(height: 4),
        const Text('ESP32 · Sin conexión desde la demostración'),
      ],
    ),
  );

  List<Widget> control() => [
    Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Control manual', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Los comandos actúan sobre el robot virtual.'),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                drive(RobotCommand.forward, Icons.keyboard_arrow_up),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    drive(RobotCommand.left, Icons.keyboard_arrow_left),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6D78),
                        foregroundColor: background,
                      ),
                      onPressed: () => simulate(RobotCommand.stop),
                      child: const Text('STOP'),
                    ),
                    drive(RobotCommand.right, Icons.keyboard_arrow_right),
                  ],
                ),
                drive(RobotCommand.backward, Icons.keyboard_arrow_down),
              ],
            ),
          ),
          const Divider(height: 32),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Recolector'),
            subtitle: const Text('Activar mecanismo simulado'),
            value: collector,
            onChanged: (value) => simulate(
              value ? RobotCommand.collectorOn : RobotCommand.collectorOff,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Modo automático'),
            subtitle: const Text('Recorrer una ruta simulada'),
            value: automatic != null,
            onChanged: toggleAutomatic,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    statusPanel(),
  ];

  Widget drive(RobotCommand command, IconData icon) => IconButton.filledTonal(
    tooltip: command.label,
    onPressed: () => simulate(command),
    icon: Icon(icon),
  );

  Widget zonePanel() => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona una zona para la simulación.'),
        const SizedBox(height: 8),
        for (final zone in zones)
          ListTile(
            leading: Icon(
              activeZone == zone
                  ? Icons.check_circle
                  : Icons.location_on_outlined,
              color: mint,
            ),
            title: Text(zone),
            subtitle: activeZone == zone ? const Text('Zona activa') : null,
            selected: activeZone == zone,
            onTap: () => setState(() {
              activeZone = zone;
              record('Zona seleccionada · $zone');
            }),
            trailing: IconButton(
              tooltip: 'Quitar $zone',
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() {
                zones.remove(zone);
                if (activeZone == zone) activeZone = null;
                record('Zona retirada · $zone');
              }),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: addZone,
          icon: const Icon(Icons.add),
          label: const Text('Agregar zona'),
        ),
      ],
    ),
  );

  Future<void> addZone() async {
    var input = '';
    final form = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar zona'),
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(labelText: 'Nombre de la zona'),
            onChanged: (value) => input = value.trim(),
            validator: (_) {
              if (input.isEmpty) return 'Escribe un nombre';
              if (zones.any(
                (zone) => zone.toLowerCase() == input.toLowerCase(),
              )) {
                return 'Esa zona ya existe';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, input);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (!mounted || name == null) return;
    setState(() {
      zones.add(name);
      record('Zona agregada · $name');
    });
  }

  Widget historyPanel() => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Últimos 100 eventos de esta sesión'),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Todavía no hay actividad registrada.'),
          ),
        for (final event in events)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: mint),
            title: Text(event.label),
            subtitle: Text(
              MaterialLocalizations.of(context)
                  .formatTimeOfDay(TimeOfDay.fromDateTime(event.time)),
            ),
          ),
      ],
    ),
  );

  Widget settingsPanel() => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Endpoint del ESP32',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Configura y previsualiza la solicitud HTTP. Esta pantalla no establece conexión.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: endpointField,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'URL del endpoint',
            errorText: endpointError,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: applyEndpoint,
          child: const Text('Validar URL'),
        ),
        const SizedBox(height: 12),
        SelectableText('GET ${service.commandUri(RobotCommand.stop)}'),
      ],
    ),
  );

  void applyEndpoint() => setState(() {
    final uri = Uri.tryParse(endpointField.text.trim());
    if (uri == null || !Esp32Service.isValidEndpoint(uri)) {
      endpointError =
          'Usa una URL HTTP(S) sin credenciales, consulta ni fragmento.';
      return;
    }
    endpointError = null;
    service = Esp32Service(uri);
  });
}
