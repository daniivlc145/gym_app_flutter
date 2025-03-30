import 'package:flutter/material.dart';
import 'package:gym_app/screens/friend_profile_screen.dart';
import 'package:gym_app/models/Usuario.dart';
import 'package:gym_app/services/user_service.dart';
import 'package:gym_app/screens/add_friends_screen.dart';
import 'package:gym_app/services/gimnasio_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final GimnasioService _gimnasioService = GimnasioService();
  Future<Usuario>? _userDataFuture;
  Future<List<Map<String, dynamic>>>? _gimnasiosFuture;
  List<dynamic> _amigos = [];
  List<dynamic> _solicitudesRecibidas = [];
  List<dynamic> _solicitudesEnviadas = [];


  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
    _gimnasiosFuture = _getGimnasiosDeUsuarioActivo();
  }

  Future<Usuario> _getUserData() async {
    final userDataMap = await _userService.getCurrentUserData();
    final usuario = Usuario.fromMap(userDataMap);
    if (usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty) {
      await precacheImage(NetworkImage(usuario.fotoUsuario!), context);
    }
    return usuario;
  }



  void _showListaAmigos() async {
    final List<String> opciones = ['Amigos', 'Solicit. Recibidas', 'Solicit. Enviadas'];
    String opcionSeleccionada = 'Amigos';

    _amigos = await _userService.getAmigos();
    _solicitudesRecibidas = await _userService.getSolicitudesRecibidas();
    _solicitudesEnviadas = await _userService.getSolicitudesEnviadas();

    setState(() {});

    try {
      final amigos = await _userService.getAmigos();
      final solicitudesRecibidas = await _userService.getSolicitudesRecibidas();
      final solicitudesEnviadas = await _userService.getSolicitudesEnviadas();

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (_, controller) => GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFECF0F1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFFECF0F1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: Color(0xff38434E), width: 1),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: opcionSeleccionada,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff38434E)),
                                  dropdownColor: Color(0xFFECF0F1),
                                  items: opciones.map((opcion) => DropdownMenuItem(value: opcion, child: Text(opcion, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff38434E))))).toList(),
                                  onChanged: (nuevaOpcion) => setState(() => opcionSeleccionada = nuevaOpcion!),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (opcionSeleccionada == 'Amigos')
                                IconButton(icon: Icon(Icons.person_add, color: Color(0xff38434E)), onPressed: () {Navigator.of(context).pop(); _showAddAmigos();}),
                              IconButton(icon: Icon(Icons.close, color: Color(0xff38434E)), onPressed: () => Navigator.of(context).pop()),
                            ],
                          ),
                        ],
                      ),
                      Expanded(child: _buildContenidoLista(opcionSeleccionada, amigos, solicitudesRecibidas, solicitudesEnviadas, context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildContenidoLista(String opcion, List amigos, List solicitudesRecibidas, List solicitudesEnviadas, BuildContext context) {
    switch (opcion) {
      case 'Amigos':
        return amigos.isEmpty ? Center(child: Text('No tienes amigos', style: TextStyle(fontSize: 16, color: Color(0xff38434E)))) :
        ListView.builder(
          itemCount: amigos.length,
          itemBuilder: (context, index) {
            final amigo = amigos[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: amigo['foto_usuario'] != null ? NetworkImage(amigo['foto_usuario']) : AssetImage('assets/usuario.png') as ImageProvider),
              title: Text(amigo['nombre_usuario']),
              subtitle: Text('${amigo['nombre']} ${amigo['apellidos']}'),
              trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _mostrarDialogoEliminarAmigo(amigo['pk_usuario'])),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilAmigoScreen(amigoId: amigo['pk_usuario']))),
            );
          },
        );
      case 'Solicit. Recibidas':
        return solicitudesRecibidas.isEmpty ? Center(child: Text('No tienes solicitudes recibidas', style: TextStyle(fontSize: 16, color: Color(0xff38434E)))) :
        ListView.builder(
          itemCount: solicitudesRecibidas.length,
          itemBuilder: (context, index) {
            final solicitud = solicitudesRecibidas[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: solicitud['foto_usuario'] != null ? NetworkImage(solicitud['foto_usuario']) : AssetImage('assets/usuario.png') as ImageProvider),
              title: Text(solicitud['nombre_usuario']),
              subtitle: Text('${solicitud['nombre']} ${solicitud['apellidos']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () => _aceptarSolicitudAmistad(solicitud['pk_usuario'])),
                  IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => _rechazarSolicitudAmistad(solicitud['pk_usuario'])),
                ],
              ),
            );
          },
        );
      case 'Solicit. Enviadas':
        return solicitudesEnviadas.isEmpty ? Center(child: Text('No tienes solicitudes enviadas', style: TextStyle(fontSize: 16, color: Color(0xff38434E)))) :
        ListView.builder(
          itemCount: solicitudesEnviadas.length,
          itemBuilder: (context, index) {
            final solicitud = solicitudesEnviadas[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: solicitud['foto_usuario'] != null ? NetworkImage(solicitud['foto_usuario']) : AssetImage('assets/usuario.png') as ImageProvider),
              title: Text(solicitud['nombre_usuario']),
              subtitle: Text('${solicitud['nombre']} ${solicitud['apellidos']}'),
              trailing: IconButton(icon: Icon(Icons.cancel, color: Colors.red), onPressed: () => _cancelarSolicitudAmistad(solicitud['pk_usuario'], setState)),
            );
          },
        );
      default: return Container();
    }
  }

  void _aceptarSolicitudAmistad(String usuarioId) async {
    try {
      await _userService.aceptarSolicitudAmistad(usuarioId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud aceptada'), backgroundColor: Colors.green));
      _showListaAmigos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _rechazarSolicitudAmistad(String usuarioId) async {
    try {
      await _userService.eliminarSolicitudRecibida(usuarioId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud rechazada'), backgroundColor: Colors.green));
      _showListaAmigos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _cancelarSolicitudAmistad(String usuarioId, Function setStateModal) async {
    try {
      await _userService.eliminarSolicitudEnviada(usuarioId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud cancelada')));

      Navigator.of(context).pop();

      _showListaAmigos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddAmigos() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddFriendScreen()));
  }

  void _mostrarDialogoEliminarAmigo(String amigoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Amigo'),
        content: Text('¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _showListaAmigos());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _editarPerfil(){}

  Future<List<Map<String, dynamic>>> _getGimnasiosDeUsuarioActivo() async {
    return await _gimnasioService.getGimnasiosDeUsuarioActivo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: FutureBuilder<Usuario>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return Center(child: Text('No se pudieron cargar los datos.'));

          final usuario = snapshot.data!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: CircleAvatar(radius: 50, backgroundImage: usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty ? NetworkImage(usuario.fotoUsuario!) : AssetImage('assets/usuario.png') as ImageProvider),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(usuario.nombreUsuario, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(width: 10),
                              ElevatedButton(onPressed: _showListaAmigos, style: ElevatedButton.styleFrom(backgroundColor: Color(0xffECF0F1), shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), child: Icon(Icons.people, color: Color(0xff38434E))),
                            ],
                          ),
                          ElevatedButton(onPressed: _editarPerfil, style: ElevatedButton.styleFrom(backgroundColor: Color(0xffECF0F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), child: Text('Editar Perfil', style: TextStyle(color: Color(0xff38434E)))),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(children: [Padding(padding: EdgeInsets.only(left: 30), child: Text(usuario.descripcion ?? '', style: TextStyle(fontSize: 16), textAlign: TextAlign.left))]),
                _buildPanelGimnasios(),

              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildPanelGimnasios() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _gimnasiosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No hay gimnasios disponibles.'));

        final gimnasios = snapshot.data!;

        return ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              gimnasios[index]['isExpanded'] = !isExpanded;
            });
          },
          children: gimnasios.map<ExpansionPanel>((gimnasio) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(gimnasio['nombre']),
                );
              },
              body: ListTile(
                title: Text('Ciudad: ${gimnasio['ciudad']}'),
                subtitle: Text('Código Postal: ${gimnasio['codigo_postal']}'),
              ),
              isExpanded: gimnasio['isExpanded'] ?? false,
            );
          }).toList(),
        );
      },
    );
  }
}