import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note/db/database_service.dart';
import 'package:note/extensions/format_date.dart';
import 'package:note/models/note.dart';
import 'package:note/utils/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabasesService dbService = DatabasesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Simple Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).pushNamed('add-note');
        },
        child: const Icon(Icons.note_add_rounded),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabasesService.boxName).listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Tidak ada data'),
            );
          } else {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final note = box.getAt(index);
                return NoteCard(
                  note: note,
                  databasesService: dbService,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.databasesService,
  });

  final Note note;
  final DatabasesService databasesService;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.key.toString()),
      background: Text(''),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          databasesService.deleteNote(note).then((value) => {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    content: Text('Catatan Berhasil Dihapus'),
                  ),
                )
              });
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: ListTile(
          onTap: () {
            GoRouter.of(context).pushNamed(AppRoutes.editNote, extra: note);
          },
          title: Text(
            note.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(note.desc),
          trailing: Text('Dibuat pada : \n ${note.createdAt.formatDate()}'),
        ),
      ),
    );
  }
}
