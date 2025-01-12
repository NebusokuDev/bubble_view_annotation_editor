import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undo/undo.dart';

class HistoryNotifier extends ChangeNotifier {
  final ChangeStack _history = ChangeStack();

  bool get canRedo => _history.canRedo;

  bool get canUndo => _history.canUndo;

  void redo() {
    _history.redo();
    notifyListeners();
  }

  void undo() {
    _history.undo();
    notifyListeners();
  }

  void addChange(Change change) {
    _history.add(change);
    notifyListeners();
  }
}

final historyProvider = ChangeNotifierProvider((ref) => HistoryNotifier());
