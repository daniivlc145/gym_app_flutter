import 'package:flutter/material.dart';
import '../utils/validators.dart';

class ForgotPassword extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Añade un padding horizontal
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Asegura que el contenido esté centrado horizontalmente
            children: [
              Text(
                'RECUPERACIÓN DE CONTRASEÑA',
                textAlign: TextAlign.center, // Centra el texto horizontalmente
                style: TextStyle(
                  color: Color(0xff38434E),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Introduce el correo electrónico asociado a tu cuenta. Una vez hecho click en ENVIAR, '
                    'recibirás un mail con instrucciones para establecer una nueva contraseña.',
                textAlign: TextAlign.center, // Centra el texto horizontalmente
                style: TextStyle(
                  color: Color(0xff38434E),
                  fontSize: 16,
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
                              BorderRadius.all(Radius.circular(50))),
                          labelText: 'Correo Electrónico',
                        ),
                        validator: (value) => Validators.validateEmail(value),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff1ABC9C),
                      ),
                      child: const Text(
                        'ENVIAR',
                        style: TextStyle(
                            color: Color(0xffECF0F1),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}