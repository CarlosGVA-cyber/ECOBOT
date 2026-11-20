import 'package:flutter/material.dart';

import 'ui.dart';

enum AccessPage {
  welcome('Bienvenida'),
  login('Inicio de sesión'),
  register('Registro'),
  recovery('Recuperación de contraseña');

  const AccessPage(this.title);
  final String title;
}

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});
  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  AccessPage page = AccessPage.welcome;
  final name = TextEditingController();
  final form = GlobalKey<FormState>();
  Role role = Role.operator;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void openConsole(BuildContext context, Session session) =>
      Navigator.of(context)
          .pushReplacementNamed('/console', arguments: session);

  void show(AccessPage destination) => setState(() => page = destination);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: page == AccessPage.welcome
            ? null
            : BackButton(onPressed: () => show(AccessPage.welcome)),
        title: const Brand(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final hero = Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF16382E), Color(0xFF11243A)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.smart_toy_outlined,
                          size: 58,
                          color: mint,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Robótica para la recolección de residuos',
                          style: theme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Explora el control del robot, sus zonas de trabajo y el registro de operaciones.',
                        ),
                      ],
                    ),
                  );
                  final card = Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'DEMOSTRACIÓN LOCAL',
                          style: TextStyle(
                            color: mint,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(page.title, style: theme.headlineSmall),
                        const SizedBox(height: 16),
                        ...switch (page) {
                          AccessPage.welcome => [
                            const Text(
                              'Explora ECOBOT con perfiles de prueba. Los cambios se pierden al cerrar la sesión.',
                            ),
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: () => show(AccessPage.login),
                              child: const Text('Iniciar sesión de prueba'),
                            ),
                            OutlinedButton(
                              onPressed: () => show(AccessPage.register),
                              child: const Text('Registro de prueba'),
                            ),
                            TextButton(
                              onPressed: () => openConsole(
                                context,
                                const Session(Role.visitor, 'Visitante'),
                              ),
                              child: const Text('Entrar como visitante'),
                            ),
                          ],
                          AccessPage.login => [
                            const Text(
                              'Elige un perfil predefinido para explorar sus permisos. Este acceso de prueba no solicita credenciales.',
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Role>(
                              initialValue: role,
                              decoration: const InputDecoration(
                                labelText: 'Perfil de prueba',
                              ),
                              items: Role.values
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => role = value ?? Role.operator),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => openConsole(
                                context,
                                Session(role, role.label),
                              ),
                              child: const Text('Abrir consola'),
                            ),
                            TextButton(
                              onPressed: () => show(AccessPage.recovery),
                              child: const Text('Recuperar contraseña'),
                            ),
                          ],
                          AccessPage.register => [
                            const Text(
                              'Crea un perfil temporal de visitante con un alias ficticio.',
                            ),
                            const SizedBox(height: 16),
                            Form(
                              key: form,
                              child: TextFormField(
                                controller: name,
                                maxLength: 40,
                                decoration: const InputDecoration(
                                  labelText: 'Alias de prueba',
                                ),
                                validator: (value) =>
                                    (value ?? '').trim().isEmpty
                                    ? 'Escribe un alias de prueba'
                                    : null,
                              ),
                            ),
                            FilledButton(
                              onPressed: () {
                                if (form.currentState!.validate()) {
                                  openConsole(
                                    context,
                                    Session(Role.visitor, name.text.trim()),
                                  );
                                }
                              },
                              child: const Text('Crear perfil temporal'),
                            ),
                          ],
                          AccessPage.recovery => [
                            const Text(
                              'Esta es una vista de demostración. La recuperación por correo requiere un servicio de autenticación. Puedes volver a entrar seleccionando un perfil de prueba.',
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => show(AccessPage.login),
                              child: const Text('Volver al inicio de sesión'),
                            ),
                          ],
                        },
                      ],
                    ),
                  );
                  if (constraints.maxWidth >= 760) {
                    return Row(
                      children: [
                        Expanded(child: hero),
                        const SizedBox(width: 24),
                        Expanded(child: card),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      if (page == AccessPage.welcome) ...[
                        hero,
                        const SizedBox(height: 16),
                      ],
                      card,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
