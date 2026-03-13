import 'package:flutter/widgets.dart';

import '../data/repositories/app_repositories.dart';

class RecipeAppScope extends InheritedWidget {
  const RecipeAppScope({
    super.key,
    required this.repositories,
    required super.child,
  });

  final AppRepositories repositories;

  static RecipeAppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RecipeAppScope>();
    assert(scope != null, 'RecipeAppScope is missing from the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(RecipeAppScope oldWidget) {
    return oldWidget.repositories != repositories;
  }
}
