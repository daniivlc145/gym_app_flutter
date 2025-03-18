import 'package:flutter/material.dart';
import 'package:gym_app/screens/login_screen.dart';
import 'package:gym_app/utils/validators.dart';

class SignupScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String _selectedCountryCode = '+34';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+34', 'name': 'España', 'flag': '🇪🇸'},
    {'code': '+1', 'name': 'EE.UU.', 'flag': '🇺🇸'},
    // Añade más países aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*Text(
              'REGISTRO',
              style: TextStyle(
                color: Color(0xff38434E),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),*/
            SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _nombreUsuarioController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        labelText: 'Nombre de usuario',
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        labelText: 'Correo Electrónico',
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.info),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        labelText: 'Nombre',
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _apellidosController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.info),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        labelText: 'Apellidos',
                      ),
                      validator: (value) {
                        return null;
                      },
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
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        labelText: 'Contraseña',
                      ),
                      obscureText: true,
                      validator: (value) => Validators.validatePassword(value),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            onChanged: (String? newValue) {
                              _selectedCountryCode = newValue!;
                            },
                            items: _countryCodes.map<DropdownMenuItem<String>>((Map<String, String> country) {
                              return DropdownMenuItem<String>(
                                value: country['code'],
                                child: Row(
                                  children: [
                                    Text(country['flag']!),
                                    SizedBox(width: 8),
                                    Text(country['code']!),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff1ABC9C),
                    ),
                    child: const Text(
                      'REGISTRAR',
                      style: TextStyle(
                        color: Color(0xffECF0F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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