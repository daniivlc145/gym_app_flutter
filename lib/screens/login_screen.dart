import 'package:flutter/material.dart';
import 'package:gym_app/screens/home_screen.dart';
import 'package:gym_app/screens/forgot_password_screen.dart';
import 'package:gym_app/screens/signup_screen.dart';
import 'package:gym_app/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:gym_app/services/auth_service.dart';

import '../main.dart';
import '../widgets/theme_switch.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  void _tryLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await AuthService().logIn(
          _emailController.text,
          _passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _changeMode(BuildContext context) {
    Provider.of<MyAppState>(context, listen: false).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ThemeSwitch()
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  'INICIO DE SESIÓN',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          style: theme.textTheme.bodyLarge, // Adaptativo
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Correo Electrónico',
                          ),
                          validator: (value) =>
                              Validators.validateEmail(value ?? ''),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          style: theme.textTheme.bodyLarge,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          onFieldSubmitted: (_) {
                            _tryLogin(context);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'Contraseña',
                          ),
                          validator: (value) =>
                              Validators.validatePassword(value ?? ''),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Botón principal usando Theme
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () => _tryLogin(context),
                          child: Text(
                            'CONTINUAR',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.onPrimary
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()),
                          );
                        },
                        child: Text(
                          '¿Has olvidado tu contraseña?',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onBackground,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 180,
                        height: 60,
                        child: SignInWithAppleButton(
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 35),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()),
                          );
                        },
                        child: Text(
                          'Regístrate aquí',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onBackground,
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                          ),
                        ),
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