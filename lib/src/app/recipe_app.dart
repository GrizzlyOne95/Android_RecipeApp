import 'package:flutter/material.dart';

import '../data/local/app_database.dart';
import '../data/repositories/app_repositories.dart';
import '../features/shell/app_shell.dart';
import 'app_theme.dart';
import 'recipe_app_scope.dart';

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key, this.repositories});

  final AppRepositories? repositories;

  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  AppDatabase? _ownedDatabase;
  late final AppRepositories _repositories;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    if (widget.repositories case final injectedRepositories?) {
      _repositories = injectedRepositories;
    } else {
      _ownedDatabase = AppDatabase();
      _repositories = AppRepositories(_ownedDatabase!);
    }
    _initialization = _repositories.initialize();
  }

  @override
  void dispose() {
    _ownedDatabase?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RecipeAppScope(
      repositories: _repositories,
      child: MaterialApp(
        title: 'Kitchen Ledger',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: FutureBuilder<void>(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _InitializationError(error: snapshot.error.toString());
            }

            if (snapshot.connectionState != ConnectionState.done) {
              return const _InitializationLoading();
            }

            return const AppShell();
          },
        ),
      ),
    );
  }
}

class _InitializationLoading extends StatelessWidget {
  const _InitializationLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _InitializationError extends StatelessWidget {
  const _InitializationError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Database startup failed.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
