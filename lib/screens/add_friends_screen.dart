import 'package:flutter/material.dart';
import 'package:gym_app/services/user_service.dart';
import 'package:gym_app/screens/friend_profile_screen.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  List _resultados = [];
  bool _isSearching = false;

  void _buscarUsuarios(String query) async {
    if (query.isEmpty) {
      setState(() {
        _resultados = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final resultados = await _userService.buscarUsuarios(query);
      setState(() {
        _resultados = resultados;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }


  void _enviarSolicitudAmistad(String usuarioId) async {
    try {
      await _userService.enviarSolicitudAmistad(usuarioId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud enviada'), backgroundColor: Colors.green));
      setState(() {
        _buscarUsuarios(_searchController.text);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }


  void _cancelarSolicitudAmistad(String usuarioId) async {
    try {
      await _userService.eliminarSolicitudEnviada(usuarioId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud cancelada'), backgroundColor: Colors.green));
      setState(() {
        _buscarUsuarios(_searchController.text);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Añadir amigo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              ),
              onChanged: _buscarUsuarios,
            ),
          ),
          _isSearching ? CircularProgressIndicator() :
          Expanded(
            child: _resultados.isEmpty ? Center(child: Text('No se encontraron usuarios')) :
            ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final usuario = _resultados[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: usuario['foto_usuario'] != null ? NetworkImage(usuario['foto_usuario']) : AssetImage('assets/usuario.png') as ImageProvider),
                  title: Text(usuario['nombre_usuario']),
                  subtitle: Text('${usuario['nombre']} ${usuario['apellidos']}'),
                  trailing: FutureBuilder<bool>(
                    future: _userService.existeSolicitudAmistad(usuario['pk_usuario']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(strokeWidth: 2);
                      } else if (snapshot.hasError) {
                        return Icon(Icons.error);
                      } else {
                        bool existeSolicitud = snapshot.data ?? false;
                        return existeSolicitud
                            ? IconButton(icon: Icon(Icons.cancel, color: Colors.red), onPressed: () => _cancelarSolicitudAmistad(usuario['pk_usuario']))
                            : IconButton(icon: Icon(Icons.person_add, color: Color(0xff1ABC9C)), onPressed: () => _enviarSolicitudAmistad(usuario['pk_usuario']));
                      }
                    },
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilAmigoScreen(amigoId: usuario['pk_usuario']))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}