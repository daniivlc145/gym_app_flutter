import 'package:flutter/material.dart';
import 'package:gym_app/models/Usuario.dart';
import 'package:gym_app/services/user_service.dart';
import 'package:gym_app/utils/validators.dart';
import 'package:gym_app/services/gimnasio_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _nombreUsuarioForoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final UserService _userService = UserService();
  final GimnasioService _gimnasioService = GimnasioService();
  Future<Usuario>? _userDataFuture;
  Future<List<Map<String, dynamic>>>? _gimnasiosFuture;

  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
    _gimnasiosFuture = _getGimnasiosDeUsuario();
  }

  Future<Usuario> _getUserData() async {
    final userDataMap = await _userService.getCurrentUserData();
    final usuario = Usuario.fromMap(userDataMap);

    if (usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty) {
      await precacheImage(NetworkImage(usuario.fotoUsuario!), context);
    }

    return usuario;
  }

  Future<List<Map<String, dynamic>>> _getGimnasiosDeUsuario() async {
    final gimnasios = await _gimnasioService.getGimnasiosDeUsuarioActivo();
    _isExpanded = List<bool>.filled(gimnasios.length, false);
    return gimnasios;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar perfil')),
      body: FutureBuilder(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData) return Center(child: Text('No se pudieron cargar los datos.'));

            final usuario = snapshot.data!;

            return Center(
              child: Column(
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
                              validator: (value) =>
                                  Validators.validateUsername(value ?? ''),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                ),
                                labelText: usuario.nombreUsuario,
                                hintText: 'Nombre de usuario',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _descripcionController,
                              validator: (value) =>
                                  Validators.validateDescripcion(value ?? ''),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.edit),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                ),
                                labelText: usuario.descripcion,
                                hintText: 'Descripción del perfil',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _nombreUsuarioForoController,
                              validator: (value) =>
                                  Validators.validateUsernameForo(value ?? ''),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.forum),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                ),
                                hintText: 'Nombre de usuario en foros',
                                labelText: usuario.nombreUsuarioForo ?? usuario.nombreUsuario,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      )
                  ),

                ],
              ),
            );
          }
      ),
    );
  }
}