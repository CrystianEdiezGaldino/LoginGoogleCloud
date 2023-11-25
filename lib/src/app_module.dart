import 'package:appnew/src/services/auth_service.dart';
import 'package:appnew/src/views/sign_in_demo.dart';

import 'package:flutter_modular/flutter_modular.dart';

import 'controllers/auth_controller.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind(((i) => AuthService())),
        Bind(((i) => AuthController())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => const SignInDemo(),
        ),
      ];
}
