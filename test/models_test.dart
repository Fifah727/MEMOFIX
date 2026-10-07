import 'package:flutter_test/flutter_test.dart';
import 'package:memofix/core/config/app_config.dart';
import 'package:memofix/models/fixme/fixme_items.dart';
import 'package:memofix/models/memo_item.dart';

void main() {
  group('BugItem', () {
    test('fromMap applique les valeurs par défaut', () {
      final bug = BugItem.fromMap({});

      expect(bug.id_bug, 0);
      expect(bug.statut, 'en_cours');
      expect(bug.avancement, 0);
      expect(bug.deadline, isNull);
      expect(bug.date_cloture, isNull);
    });

    test('toMap puis fromMap conserve les données', () {
      final bug = BugItem(
        description: 'Fuite mémoire',
        cause: 'Listener non libéré',
        impact: 'Crash après 10 min',
        categorie: 'Dev',
        avancement: 40,
        deadline: DateTime(2026, 2, 1),
        date_creation: DateTime(2026, 1, 2, 3, 4, 5),
      );

      final copy = BugItem.fromMap(bug.toMap());

      expect(copy.description, bug.description);
      expect(copy.cause, bug.cause);
      expect(copy.impact, bug.impact);
      expect(copy.categorie, bug.categorie);
      expect(copy.avancement, 40);
      expect(copy.deadline, bug.deadline);
      expect(copy.date_creation, bug.date_creation);
    });

    test('une deadline invalide est ignorée', () {
      final bug = BugItem.fromMap({'deadline': 'pas-une-date'});

      expect(bug.deadline, isNull);
    });
  });

  group('MemoItem', () {
    test("l'égalité repose sur le texte et la date de création", () {
      final date = DateTime(2026, 5, 1);
      final a = MemoItem(text: 'x', createdAt: date, modifiedAt: date);
      final b = MemoItem(
        text: 'x',
        createdAt: date,
        modifiedAt: DateTime(2026, 6, 1),
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppConfig', () {
    test('aucun identifiant Spotify embarqué par défaut', () {
      expect(AppConfig.hasSpotifyCredentials, isFalse);
    });
  });
}
