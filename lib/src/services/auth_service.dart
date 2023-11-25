// ignore_for_file: depend_on_referenced_packages

import 'dart:convert' show json;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);

  GoogleSignInAccount? currentUser;

  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      currentUser = account;
    });
    await _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> signOut() => _googleSignIn.disconnect();

  Future<String?> getContactText() async {
    if (currentUser != null) {
      final http.Response response = await http.get(
        Uri.parse('https://people.googleapis.com/v1/people/me/connections'
            '?requestMask.includeField=person.names'),
        headers: await currentUser!.authHeaders,
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
              'API de pessoas ${response.statusCode} response: ${response.body}');
        }
        return 'A API People deu um ${response.statusCode} resposta. Verifique os logs para obter detalhes.';
      }

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      final String? namedContact = _pickFirstNamedContact(data);

      return namedContact != null
          ? 'Eu vejo que você sabe $namedContact!'
          : 'Nenhum contato para exibir.';
    } else {
      return null;
    }
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
}
