import 'package:flutter/material.dart';
import 'package:gym_app/screens/home_screen.dart';
import 'package:gym_app/screens/forgot_password_screen.dart';
import 'package:gym_app/screens/signup_screen.dart';
import 'package:gym_app/utils/validators.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:gym_app/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'INICIO DE SESIÓN',
              style: TextStyle(
                color: Color(0xff38434E),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))
                        ),
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
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        labelText: 'Contraseña',
                      ),
                      obscureText: true,
                      validator: (value) =>
                          Validators.validatePassword(value ?? ''),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
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
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                            (Route<dynamic> route) =>
                                false, // Remove all previous routes
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff1ABC9C),
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                          color: Color(0xffECF0F1),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
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
                      style: TextStyle(
                          color: Color(0xff38434E),
                          decoration: TextDecoration.underline,
                          fontSize: 16),
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
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      'Regístrate aquí',
                      style: TextStyle(
                          color: Color(0xff38434E),
                          decoration: TextDecoration.underline,
                          fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
