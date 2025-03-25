import 'package:flutter/material.dart';

import '../models/Usuario.dart';
import '../services/user_service.dart';

class PerfilAmigoScreen extends StatefulWidget {
  final String amigoId;

  const PerfilAmigoScreen({Key? key, required this.amigoId}) : super(key: key);

  @override
  _PerfilAmigoScreenState createState() => _PerfilAmigoScreenState();
}

class _PerfilAmigoScreenState extends State<PerfilAmigoScreen> {
  final UserService _userService = UserService();
  Future<Usuario>? _amigoDataFuture;

  @override
  void initState() {
    super.initState();
    _amigoDataFuture = _getAmigoData();
  }

  Future<Usuario> _getAmigoData() async {
    try {
      final userDataMap = await _userService.getUserDataById(widget.amigoId);
      final usuario = Usuario.fromMap(userDataMap);

      if (usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty) {
        await precacheImage(NetworkImage(usuario.fotoUsuario!), context);
      }

      return usuario;
    } catch (e) {
      print('Error al obtener datos de amigo: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Perfil de Amigo'),
        ),
        body: FutureBuilder<Usuario>(
          future: _amigoDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No se pudieron cargar los datos del usuario.'));
            } else {
              final usuario = snapshot.data!;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty
                                ? NetworkImage(usuario.fotoUsuario!)
                                : AssetImage('assets/usuario.png') as ImageProvider,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: Column(
                              children: [
                                Text(
                                  usuario.nombreUsuario,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  ),
                                ),
                                // Aquí puedes añadir botones específicos para perfil de amigo
                                // Por ejemplo, botón de enviar mensaje o ver entrenamientos
                              ],
                            )
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text(
                            usuario.descripcion ?? '',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        )
    );
  }
}