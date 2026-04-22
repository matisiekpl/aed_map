import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/pending_change.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingChangesRepository {
  static const String _storageKey = 'pending_changes_v1';

  Future<List<PendingChange>> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    return PendingChange.decodeList(jsonString);
  }

  Future<void> register(PendingChange change) async {
    final prefs = await SharedPreferences.getInstance();
    var changes = await fetch();
    changes.removeWhere((existing) => existing.defibrillatorId == change.defibrillatorId);
    changes.add(change);
    await prefs.setString(_storageKey, PendingChange.encodeList(changes));
  }

  Future<List<PendingChange>> reconcile(List<Defibrillator> freshDataset) async {
    final prefs = await SharedPreferences.getInstance();
    var changes = await fetch();
    final freshIds = freshDataset.map((defibrillator) => defibrillator.id).toSet();
    final freshById = {for (final defibrillator in freshDataset) defibrillator.id: defibrillator};

    changes.removeWhere((change) {
      switch (change.type) {
        case PendingChangeType.add:
          return freshIds.contains(change.defibrillatorId);
        case PendingChangeType.edit:
          final freshDefibrillator = freshById[change.defibrillatorId];
          if (freshDefibrillator == null) return false;
          return Defibrillator.tagsEqual(change.snapshot, freshDefibrillator);
        case PendingChangeType.delete:
          return !freshIds.contains(change.defibrillatorId);
      }
    });

    await prefs.setString(_storageKey, PendingChange.encodeList(changes));
    return changes;
  }
}