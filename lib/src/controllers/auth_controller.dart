import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService authService = AuthService();
  String contactText = "";
  GoogleSignInAccount? currentUser;
  bool isInitializing = true; // Adicionando a propriedade

  AuthController() {
    init();
  }

  Future<void> init() async {
    isInitializing = true; // Indica que a inicialização está em andamento
    notifyListeners();

    await authService.init();
    updateContactText();

    isInitializing = false; // Indica que a inicialização foi concluída
    notifyListeners();
  }

  Future<void> signIn() async {
    await authService.signIn();
    updateContactText();
  }

  Future<void> signOut() async {
    await authService.signOut();
    updateContactText();
  }

  Future<void> updateContactText() async {
    contactText = await authService.getContactText() ?? "";
    notifyListeners();
  }
}
