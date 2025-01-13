import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undo/undo.dart';

class HistoryNotifier extends StateNotifier<ChangeStack> {
  HistoryNotifier(super.state);

  ChangeStack _history = ChangeStack();

  bool get canRedo => state.canRedo;

  bool get canUndo => state.canUndo;

  void redo() {
    _history.redo();
    state = _history;
  }

  void undo() {
    _history.undo();
    state = _history;
  }

  void addChange(Change change) {
    _history.add(change);
    state = _history;
  }

  void clear() {
    _history = ChangeStack();
    state = _history;
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, ChangeStack>(
    (ref) => HistoryNotifier(ChangeStack()));
