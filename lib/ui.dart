import 'package:flutter/material.dart';

const mint = Color(0xFF65EDAC);
const panel = Color(0xFF111E2C);
const background = Color(0xFF080F18);

enum Role {
  admin('Administrador'),
  operator('Operador'),
  visitor('Visitante');

  const Role(this.label);
  final String label;
}

class Session {
  const Session(this.role, this.name);
  final Role role;
  final String name;
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: mint.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.eco_outlined, color: mint),
        ),
        const SizedBox(width: 10),
        const Text(
          'ECOBOT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: panel,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFF24364A)),
    ),
    child: SizedBox(
      width: double.infinity,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  );
}
