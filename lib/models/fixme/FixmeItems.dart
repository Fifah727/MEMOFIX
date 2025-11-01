class BugItem {
  final int id_bug;
  final String description;
  final String cause;
  final String impact;
  final String deadline;
  final String statut; // en_cours / corrigé / abandonné
  final DateTime date_creation;
  final DateTime? date_cloture;
  final String categorie; // catégorie
  int avancement; // 0-100%
  final String icon;

  BugItem({
    this.id_bug = 0,
    this.description = "",
    this.cause = "",
    this.impact = "",
    this.deadline = "",
    this.icon = "",
    this.statut = "en_cours",
    required this.date_creation,
    this.date_cloture,
    this.categorie = "",
    this.avancement = 0,
  });

  factory BugItem.fromMap(Map<String, dynamic> map) {
    // date_creation : jamais null par défaut, mais prudence
    DateTime dateCreation;
    if (map['date_creation'] != null) {
      dateCreation = DateTime.parse(map['date_creation']);
    } else {
      dateCreation = DateTime.now(); // fallback
    }

    // date_cloture : peut être null
    DateTime? dateCloture;
    if (map['date_cloture'] != null) {
      dateCloture = DateTime.tryParse(map['date_cloture']);
    }

    return BugItem(
      id_bug: map['id_bug'] ?? 0,
      description: map['description'] ?? "",
      cause: map['cause'] ?? "",
      impact: map['impact'] ?? "",
      deadline: map['deadline'] ?? "",
      icon: map['icon'] ?? "",
      statut: map['statut'] ?? "en_cours",
      date_creation: dateCreation,
      date_cloture: dateCloture,
      categorie: map['categorie'] ?? "",
      avancement: map['avancement'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_bug': id_bug,
      'description': description,
      'cause': cause,
      'impact': impact,
      'deadline': deadline,
      'icon': icon,
      'statut': statut,
      'date_creation': date_creation.toIso8601String(),
      'date_cloture': date_cloture?.toIso8601String(),
      'categorie': categorie,
      'avancement': avancement,
    };
  }
}

class ObjectifItem {
  final int id_obj;
  final String periode;
  final String valeur_cible;
  final int id_bug;
  final DateTime date_creation;
  String statut; // en_cours / fait / abandonné

  ObjectifItem({
    this.id_obj = 0,
    this.periode = "",
    this.valeur_cible = "",
    required this.id_bug,
    required this.date_creation,
    this.statut = "en_cours",
  });

  factory ObjectifItem.fromMap(Map<String, dynamic> map) {
    return ObjectifItem(
      id_obj: map['id_obj'] ?? 0,
      periode: map['periode'] ?? "",
      valeur_cible: map['valeur_cible'] ?? "",
      id_bug: map['id_bug'],
      date_creation: DateTime.parse(map['date_creation']),
      statut: map['statut'] ?? "en_cours",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_obj': id_obj,
      'periode': periode,
      'valeur_cible': valeur_cible,
      'id_bug': id_bug,
      'date_creation': date_creation.toIso8601String(),
      'statut': statut,
    };
  }
}

class BugProgressItem {
  final int id_progress;
  final int id_bug;
  final DateTime date_modif;
  final String commentaire;
  final int avancement; // 0-100%

  BugProgressItem({
    this.id_progress = 0,
    required this.id_bug,
    required this.date_modif,
    this.commentaire = "",
    this.avancement = 0,
  });

  factory BugProgressItem.fromMap(Map<String, dynamic> map) {
    return BugProgressItem(
      id_progress: map['id_progress'] ?? 0,
      id_bug: map['id_bug'],
      date_modif: DateTime.parse(map['date_modif']),
      commentaire: map['commentaire'] ?? "",
      avancement: map['avancement'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_progress': id_progress,
      'id_bug': id_bug,
      'date_modif': date_modif.toIso8601String(),
      'commentaire': commentaire,
      'avancement': avancement,
    };
  }
}

class UtilisateurItem {
  final int id_u;
  final String nom_u;
  final String? mdp_u;
  final String? avatar;
  final String? schema_lock;
  final DateTime? datecreation_u;

  UtilisateurItem({
    this.id_u = 0,
    this.nom_u = "",
    this.mdp_u,
    this.avatar,
    this.schema_lock,
    this.datecreation_u,
  });

  factory UtilisateurItem.fromMap(Map<String, dynamic> map) {
    return UtilisateurItem(
      id_u: map['id_u'] ?? 0,
      nom_u: map['nom_u'] ?? "",
      mdp_u: map['mdp_u'],
      avatar: map['avatar'],
      schema_lock: map['schema_lock'],
      datecreation_u: map['datecreation_u'] != null
          ? DateTime.tryParse(map['datecreation_u'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_u': id_u,
      'nom_u': nom_u,
      'mdp_u': mdp_u,
      'avatar': avatar,
      'schema_lock': schema_lock,
      'datecreation_u': datecreation_u?.toIso8601String(),
    };
  }
}
