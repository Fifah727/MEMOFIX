import 'package:flutter/material.dart';

class Terms extends StatefulWidget {
  final Function(int) onChangedStep;
  const Terms({super.key, required this.onChangedStep});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  late ScrollController _scrollController;
  bool _termsRead = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_termsRead &&
          _scrollController.offset >=
              _scrollController.position.maxScrollExtent - 20) {
        setState(() {
          _termsRead = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildScrollHint() {
    if (_termsRead) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Faites défiler jusqu'en bas pour accepter",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(width: 6),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
          title: Text(
            "Conditions d'utilisation",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => widget.onChangedStep(0),
            tooltip: "Retour",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              "Bienvenue sur notre application. En utilisant notre service, vous acceptez les présentes conditions générales d'utilisation. Veuillez les lire attentivement.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "1. Acceptation des conditions",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "En accédant à cette application, vous reconnaissez avoir lu, compris et accepté ces conditions dans leur intégralité. Si vous n'acceptez pas ces termes, veuillez ne pas utiliser l'application.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "2. Description du service",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Notre application offre des fonctionnalités visant à faciliter la gestion de vos tâches, fournir des contenus éducatifs, etc.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "3. Utilisation autorisée",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Vous vous engagez à utiliser cette application conformément à la loi, aux bonnes mœurs, et de manière à ne pas porter atteinte aux droits des tiers ou à la sécurité du service.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "4. Compte utilisateur",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Certains services peuvent nécessiter la création d'un compte. Vous êtes responsable de la confidentialité de vos identifiants et des activités réalisées avec votre compte.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "5. Protection des données personnelles",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Nous respectons votre vie privée. Les données collectées sont utilisées uniquement pour améliorer le service conformément à notre politique de confidentialité.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "6. Propriété intellectuelle",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Tous les contenus, logos, marques et éléments graphiques présents dans l'application sont protégés par le droit de la propriété intellectuelle. Leur reproduction est interdite sans autorisation.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "7. Limitation de responsabilité",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Nous déployons tous les efforts raisonnables pour assurer le bon fonctionnement de l'application, mais nous ne garantissons pas l'absence d'erreurs, interruptions ou pertes de données. L'utilisation se fait à vos risques et périls.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "8. Modifications des conditions",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Nous pouvons modifier ces conditions à tout moment. Les utilisateurs seront informés via l'application ou par email. L'utilisation continue après modification vaut acceptation des nouvelles conditions.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "9. Résiliation",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Nous nous réservons le droit de suspendre ou supprimer votre accès en cas de violation des présentes conditions.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "10. Contact",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Pour toute question relative à ces conditions, veuillez nous contacter à l'adresse : ssarobidyfifaliana@gmail.com",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildScrollHint(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _termsRead ? () => widget.onChangedStep(2) : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: _termsRead ? 4 : 0,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    "J'ACCEPTE",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
