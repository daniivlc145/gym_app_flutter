import 'package:flutter/material.dart';
import 'package:gym_app/screens/login_screen.dart';
import 'package:gym_app/utils/validators.dart';
import 'package:gym_app/services/auth_service.dart';
import 'package:gym_app/models/Usuario.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  final FocusNode _nombreUsuarioFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _apellidosFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _telefonoFocus = FocusNode();

  String _selectedCountryCode = '+34';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+34', 'name': 'España', 'flag': '🇪🇸'},
    {'code': '+1', 'name': 'EE.UU.', 'flag': '🇺🇸'},
    {'code': '+31', 'name':'Paises Bajos', 'flag':'🇳🇱'}
  ];

  void _tryRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        Usuario nuevoUsuario = Usuario(
          nombre: _nombreController.text,
          apellidos: _apellidosController.text,
          telefono: _selectedCountryCode + _telefonoController.text,
          correo: _emailController.text,
          nombreUsuario: _nombreUsuarioController.text,
        );

        await AuthService().signUp(
          nuevoUsuario.nombreUsuario,
          nuevoUsuario.correo,
          nuevoUsuario.nombre,
          nuevoUsuario.apellidos,
          _passwordController.text,
          nuevoUsuario.telefono,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Registro'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          focusNode: _nombreUsuarioFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_emailFocus);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Nombre de usuario',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su nombre de usuario';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_nombreFocus);
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
                          controller: _nombreController,
                          focusNode: _nombreFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_apellidosFocus);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.info),
                            labelText: 'Nombre',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su nombre';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _apellidosController,
                          focusNode: _apellidosFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.info),
                            labelText: 'Apellidos',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese sus apellidos';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.next,
                          obscureText: true,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_telefonoFocus);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.colorScheme.primary),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCountryCode,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCountryCode = newValue!;
                                  });
                                },
                                items: _countryCodes.map<DropdownMenuItem<String>>(
                                        (Map<String, String> country) {
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
                              focusNode: _telefonoFocus,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _tryRegister(),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                labelText: 'Teléfono',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su teléfono';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _tryRegister,
                          child: Text('REGISTRAR'),
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

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _emailController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _nombreUsuarioFocus.dispose();
    _emailFocus.dispose();
    _nombreFocus.dispose();
    _apellidosFocus.dispose();
    _passwordFocus.dispose();
    _telefonoFocus.dispose();
    super.dispose();
  }
}