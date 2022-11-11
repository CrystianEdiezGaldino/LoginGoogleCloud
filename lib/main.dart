// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

void main() {
  runApp(
    const MaterialApp(
      title: "Login com GOOGLE CLOUD",
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  const SignInDemo({Key? key}) : super(key: key);

  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser; // recebe os dados do usuário do google
  String _contactText = ''; //outros dados do usuário

  /// aqui eu salvo o dados do usuário

  @override
  void initState() {
    super.initState();

    //iniciou pagina ele ja inicia o serviço do google verifica se tem alguma conta logada;
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        // salvo os dados da conta
      });
      if (_currentUser != null) {
        //verifico se tem está logado
        _handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
  }

//função async recebe os dados da api do google
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Carregando informações de contato...';
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      // se o conseguir loga ele retorna os dados
      setState(() {
        _contactText = 'A API People deu um${response.statusCode} '
            'resposta. Verifique os logs para obter detalhes.';
      });
      // ignore: avoid_print
      print('API de pessoas ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'eu vejo que você sabe $namedContact!';
      } else {
        _contactText = 'Nenhum contato para exibir.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      // ignore: avoid_print
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    // o que vem do google  ?
    //_idToken: string
    //displayName: string
    //email: string
    //id: string
    //photoUrl:string
    //serverAuthCode: string
    if (user != null) {
      return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: GoogleUserCircleAvatar(
                    identity: user,
                  ),
                  title: Text(user.displayName ?? ''),
                  subtitle: Text(user.email),
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
                _contactText,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            SizedBox(
              width: 200,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _handleSignOut,
                child: const Text('Sair'),
              ),
            ),
            SizedBox(
              width: 200,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Atualizar'),
                onPressed: () => _handleGetContact(user),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('Você não esta conectado.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('ENTRAR'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login do Google Cloud'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
