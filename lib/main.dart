import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

const String urlFoto =
    'https://raw.githubusercontent.com/Max54522/foto-de-perfil/main/WhatsApp%20Image%202026-11-05%20at%2000.01.43.jpeg';

// ── Modelo ───────────────────────────────────────────────────
enum Prioridad { alta, media, baja }

Color colorPrioridad(Prioridad p) {
  switch (p) {
    case Prioridad.alta:
      return Colors.red;
    case Prioridad.media:
      return Colors.orange;
    case Prioridad.baja:
      return Colors.green;
  }
}

class Tarea {
  final String titulo;
  final bool completada;
  final Prioridad prioridad;

  const Tarea({
    required this.titulo,
    this.completada = false,
    this.prioridad = Prioridad.media,
  });

  Tarea copiarCon({bool? completada}) {
    return Tarea(
      titulo: titulo,
      completada: completada ?? this.completada,
      prioridad: prioridad,
    );
  }
}

// ── Estado ───────────────────────────────────────────────────
class TasksState {
  final List<Tarea> tareas;

  const TasksState({this.tareas = const []});

  int get completadas => tareas.where((t) => t.completada).length;
  int get pendientes => tareas.length - completadas;
}

class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier() : super(const TasksState());

  void agregar(String titulo, Prioridad prioridad) {
    state = TasksState(
      tareas: [...state.tareas, Tarea(titulo: titulo, prioridad: prioridad)],
    );
  }

  void eliminar(int indice) {
    final nuevas = [...state.tareas];
    nuevas.removeAt(indice);
    state = TasksState(tareas: nuevas);
  }

  void toggleCompletada(int indice) {
    final nuevas = [...state.tareas];
    nuevas[indice] =
        nuevas[indice].copiarCon(completada: !nuevas[indice].completada);
    state = TasksState(tareas: nuevas);
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>(
      (ref) => TasksNotifier(),
);

// ── App ──────────────────────────────────────────────────────
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _seccion = 0;

  final List<String> _titulos = ['Inicio', 'Tareas', 'Perfil'];

  final List<Widget> _pantallas = const [
    InicioScreen(),
    TareasScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_seccion]),
        backgroundColor: cs.primaryContainer,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: cs.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(urlFoto),
                  ),
                  const SizedBox(height: 10),
                  Text('Maximiliano javier Rodriguez Fabian',
                      style: TextStyle(color: cs.onPrimary, fontSize: 16)),
                  Text('mmmmaxi545.fabiannn.22@gmail.com',
                      style: TextStyle(color: cs.onPrimary, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: _seccion == 0,
              onTap: () {
                setState(() => _seccion = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text('Mis tareas'),
              selected: _seccion == 1,
              onTap: () {
                setState(() => _seccion = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi perfil'),
              selected: _seccion == 2,
              onTap: () {
                setState(() => _seccion = 2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _pantallas[_seccion],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (int indice) {
          setState(() => _seccion = indice);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ── Inicio: contador de pendientes con ref.watch ─────────────
class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tasksProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${state.pendientes}',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('tareas pendientes', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            '${state.completadas} completadas de ${state.tareas.length}',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Tareas: agregar, completar y eliminar ────────────────────
class TareasScreen extends ConsumerStatefulWidget {
  const TareasScreen({super.key});

  @override
  ConsumerState<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends ConsumerState<TareasScreen> {
  final TextEditingController _controller = TextEditingController();
  Prioridad _prioridad = Prioridad.media;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _agregar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    ref.read(tasksProvider.notifier).agregar(texto, _prioridad);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tasksProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Nueva tarea',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _agregar(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<Prioridad>(
                value: _prioridad,
                items: Prioridad.values
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    p.name,
                    style: TextStyle(color: colorPrioridad(p)),
                  ),
                ))
                    .toList(),
                onChanged: (nueva) {
                  if (nueva != null) setState(() => _prioridad = nueva);
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: cs.primary, size: 32),
                onPressed: _agregar,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: state.tareas.length,
              itemBuilder: (context, i) {
                final t = state.tareas[i];
                return ListTile(
                  leading: Checkbox(
                    value: t.completada,
                    onChanged: (_) =>
                        ref.read(tasksProvider.notifier).toggleCompletada(i),
                  ),
                  title: Text(
                    t.titulo,
                    style: TextStyle(
                      decoration:
                      t.completada ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    'Prioridad ${t.prioridad.name}',
                    style: TextStyle(
                      color: colorPrioridad(t.prioridad),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: cs.error),
                    onPressed: () =>
                        ref.read(tasksProvider.notifier).eliminar(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Perfil ───────────────────────────────────────────────────
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(urlFoto),
          ),
          const SizedBox(height: 16),
          const Text(
            'Maximiliano Javier Rodriguez Fabian',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Estudiante de Informática',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}