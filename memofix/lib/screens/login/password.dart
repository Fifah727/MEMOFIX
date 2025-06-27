import 'package:flutter/material.dart';
import 'package:memofix/screens/home.dart';

class Password extends StatefulWidget {
  final Function(int) onChangedStep;
  const Password({super.key, required this.onChangedStep});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  bool _isSecret = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _mdp = "";

  void _showAddBugDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connexion réussi'),
        content: Text("Bon retour parmis nous!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            onPressed: () => widget.onChangedStep(0),
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mot de passe".toUpperCase(),
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 50.0),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Definissez un mot de passe"),
                      SizedBox(height: 10.0),
                      TextFormField(
                        onChanged: (value) => setState(() {
                          _mdp = value;
                        }),
                        validator: (value) => value!.length < 6
                            ? "Le mot de passe soit être à 6 caractères minimum"
                            : null,
                        obscureText: _isSecret,
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: () => setState(() => _isSecret = !_isSecret),
                            child: Icon(
                              !_isSecret
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          hintText: "mot de passe",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: _mdp.length < 6
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _showAddBugDialog();
                                }
                              },
                        child: Text("Continuer".toUpperCase()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
