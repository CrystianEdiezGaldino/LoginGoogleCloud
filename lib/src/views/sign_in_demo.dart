import 'package:flutter/material.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class SignInDemo extends StatelessWidget {
  const SignInDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login do Google Cloud'),
        ),
        body: Consumer<AuthController>(
          builder: (context, authController, _) {
            if (authController.isInitializing) {
              // Exibe o CircularProgressIndicator enquanto estiver inicializando
              return const CircularProgressIndicator();
            } else {
              // Se não estiver inicializando, mostra o FutureBuilder
              return FutureBuilder(
                future: authController.updateContactText(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Exibe o CircularProgressIndicator enquanto está carregando
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else {
                    return _buildBody(
                        context, authController, authController.contactText);
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AuthController authController, String contactText) {
    if (authController.currentUser != null) {
      return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: GoogleUserCircleAvatar(
                    identity: authController.currentUser!,
                  ),
                  title: Text(authController.currentUser!.displayName ?? ''),
                  subtitle: Text(authController.currentUser!.email),
                ),
              ),
            ),
            const Text(
              'Conectado com sucesso.',
              style: TextStyle(fontSize: 26),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                contactText,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            SizedBox(
              width: 200,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: authController.signOut,
                child: const Text('Sair'),
              ),
            ),
            SizedBox(
              width: 200,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: authController.updateContactText,
                child: const Text('Atualizar'),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('Você não está conectado.'),
          ElevatedButton(
            onPressed: authController.signIn,
            child: const Text('ENTRAR'),
          ),
        ],
      );
    }
  }
}
