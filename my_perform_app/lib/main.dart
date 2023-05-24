import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MainApp());

Future<List<String>> readDatabase() async {
  final String data = await rootBundle.loadString('assets/bdd.txt');
  final List<String> lines = data.split('\n');
  return lines;
}

class MainApp extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyPerform',
      home: AuthScreen(
        emailController: emailController,
        passController: passController,
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passController;

  const AuthScreen({
    Key? key,
    required this.emailController,
    required this.passController,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool passToggle = true;

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url : $Exception');
    }
  }

  void _submitForm() async {
    void showInvalidCredentialsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          widget.passController.clear();
          return AlertDialog(
            title: const Text('Erreur d\'identification'),
            content: const Text(
                'Désolé, votre adresse mail et/ou mot de passe est incorrect.'),
            actions: <Widget>[
              TextButton(
                child: const Text('D\'accord'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    }

    if (_formKey.currentState!.validate()) {
      final database = await readDatabase();
      final email = widget.emailController.text.trim().toLowerCase();
      final password = widget.passController.text.trim();

      bool isAuthenticated = false;

      for (var line in database) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final storedEmail = parts[0].trim();
          final storedPassword = parts[1].trim();

          if (email == storedEmail && password == storedPassword) {
            isAuthenticated = true;
            debugPrint('Correspondance trouvée');
            break;
          }
        }
      }

      if (isAuthenticated) {
        widget.emailController.clear();
        widget.passController.clear();
      } else {
        showInvalidCredentialsDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'MyPerform - Connexion',
                textAlign: TextAlign.left,
              ),
            ),
            Image.asset(
              'assets/images/logoMyPerform.png',
              height: 50,
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(225, 100, 20, 1.0),
      ),
      backgroundColor: const Color.fromRGBO(232, 182, 173, 1.0),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Bienvenue sur",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                const Text(
                  "MyPerform",
                  style: TextStyle(
                      fontSize: 47.5,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 54),
                SizedBox(
                  height: 75,
                  width: 325,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: widget.emailController,
                    decoration: const InputDecoration(
                      labelText: "Adresse Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value ?? '');
                      if (value?.isEmpty ?? true) {
                        return "Veuillez entrer une adresse mail valide";
                      } else if (!emailValid) {
                        return "Veuillez entrer une adresse mail valide";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 75,
                  width: 325,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: widget.passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return "Veuillez entrer un mot de passe valide";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _submitForm,
                  child: Container(
                    height: 50,
                    width: 250,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(225, 100, 20, 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Connexion",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous n'avez pas de compte ?",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        TextButton(
                          onPressed: _launchUrl,
                          child: const Text(
                            "Inscrivez-vous",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                const Text("Developed by Group B"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
