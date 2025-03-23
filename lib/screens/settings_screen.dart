import 'package:flutter/material.dart';
import 'package:gym_app/screens/login_screen.dart';
import 'package:gym_app/services/auth_service.dart';
import 'package:gym_app/services/user_service.dart';
import 'package:gym_app/models/usuario.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  File? _imageFile;

  final UserService _userService = UserService();
  Future<Usuario>? _userDataFuture;

  bool isDarkMode = false;

  void _changeMode(BuildContext context) {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void _cambiarContrasena(BuildContext context) {

  }

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
  }

  Future<Usuario> _getUserData() async {
    final userDataMap = await _userService.getCurrentUserData();
    return Usuario.fromMap(userDataMap);
  }

  void _logout() async {
    try {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );

      await AuthService().signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future <void> _cambiarImagen() async {
    try{
      if (Platform.isAndroid) {
        await requestPermission();
      }
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }

    }catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al escoger imagen: $e')),
      );
    }
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isDenied ||
          await Permission.photos.isPermanentlyDenied) {
        await Permission.photos.request();
      }
    }
  }

  void _guardarCambiosUsuario(String nombre, String apellidos, String telefono) async {
    try {
      await _userService.updateUserDataFromSettings(nombre, apellidos, telefono, _imageFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _userDataFuture = _getUserData();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
            color: Color(0xff38434E),
            onPressed: () => _changeMode(context),
          ),
        ],
      ),
      body: FutureBuilder<Usuario>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se pudieron cargar los datos del usuario.'));
          } else {
            final usuario = snapshot.data!;
            _nombreController.text = usuario.nombre;
            _apellidosController.text = usuario.apellidos;
            _telefonoController.text = usuario.telefono;
            _correoController.text = usuario.correo;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty
                            ? NetworkImage(usuario.fotoUsuario!)
                            : AssetImage('assets/usuario.png') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _cambiarImagen();
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              labelText: 'Nombre',
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _apellidosController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              labelText: 'Apellidos',
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _telefonoController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              labelText: 'Teléfono',
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _correoController,
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.mail),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              labelText: 'Correo Electrónico',
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _guardarCambiosUsuario(_nombreController.text, _apellidosController.text, _telefonoController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff1ABC9C),
                    ),
                    child: const Text(
                      'GUARDAR CAMBIOS',
                      style: TextStyle(
                        color: Color(0xffECF0F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => _cambiarContrasena(context),
                    child: Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        color: Color(0xff1ABC9C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => _showConfirmationDialog(context),
                    child: Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }
}