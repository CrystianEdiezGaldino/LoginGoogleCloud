import 'package:appnew/src/app_module.dart';
import 'package:appnew/src/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/services.dart';
// Este projeto foi criado por Crystian Ediez Galdino com o propósito exclusivo de estudo.
// Nele, utilizamos o Modular para injeção de dependências e o Provider para gerenciamento de estado.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,

    // defini o app para não girar a tela
  ]);
  return runApp(
    ModularApp(module: AppModule(), child: const AppWidget()),
  );
}
