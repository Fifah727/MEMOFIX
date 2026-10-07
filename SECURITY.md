# Politique de sécurité

## Signaler une vulnérabilité

N'ouvrez **pas** d'issue publique. Utilisez *Security → Report a vulnerability*
(signalement privé GitHub) sur ce dépôt.

## Règles du projet

- Aucun secret (mot de passe, clé API, keystore) dans le dépôt : tout passe par
  `--dart-define` en local et par les *GitHub Secrets* en CI.
- Un scan de secrets (gitleaks) s'exécute à chaque push / pull request.
- Tout secret qui a déjà été commité doit être considéré comme compromis et **révoqué**,
  même après suppression du code (il reste dans l'historique Git).

## Périmètre

Application locale hors ligne : les données sont stockées sur l'appareil. La protection
repose sur le verrouillage du téléphone et sur le motif de l'application.
