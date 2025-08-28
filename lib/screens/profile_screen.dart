import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/models/Usuario.dart';
import 'package:gym_app/services/user_service.dart';
import 'package:gym_app/screens/add_friends_screen.dart';
import 'package:gym_app/screens/otro_profile_screen.dart';
import 'package:gym_app/services/gimnasio_service.dart';
import 'package:gym_app/screens/edit_profile_screen.dart';
import 'package:gym_app/models/Gimnasio.dart';

import '../services/training_service.dart';
import '../widgets/training_feed_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final GimnasioService _gimnasioService = GimnasioService();
  Future<Usuario>? _userDataFuture;
  Future<List<Gimnasio>>? _gimnasiosFuture;
  Future<List<Map<String, dynamic>>>? _misEntrenamientosFuture;
  List<dynamic> _amigos = [];
  List<dynamic> _solicitudesRecibidas = [];
  List<dynamic> _solicitudesEnviadas = [];

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
    _gimnasiosFuture = _getGimnasiosDeUsuarioActivo();
    _misEntrenamientosFuture = TrainingService().getEntrenamientosUsuarioActivo();
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
    final theme = Theme.of(context);

    final List<String> opciones = ['Amigos', 'Solicit. Recibidas', 'Solicit. Enviadas'];
    String opcionSeleccionada = 'Amigos';

    // Las listas ahora son LOCALES al modal
    List<dynamic> amigos = await _userService.getAmigos();
    List<dynamic> solicitudesRecibidas = await _userService.getSolicitudesRecibidas();
    List<dynamic> solicitudesEnviadas = await _userService.getSolicitudesEnviadas();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => GestureDetector(
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
                  color: theme.colorScheme.background,
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
                              color: theme.colorScheme.background,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: theme.colorScheme.secondary, width: 1),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: opcionSeleccionada,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                                dropdownColor: theme.colorScheme.background,
                                items: opciones.map((opcion) => DropdownMenuItem(
                                    value: opcion,
                                    child: Text(
                                      opcion,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ))).toList(),
                                onChanged: (nuevaOpcion) {
                                  setStateModal(() {
                                    opcionSeleccionada = nuevaOpcion!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (opcionSeleccionada == 'Amigos')
                              IconButton(
                                icon: Icon(Icons.person_add, color: theme.colorScheme.secondary),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showAddAmigos();
                                },
                              ),
                            IconButton(
                              icon: Icon(Icons.close, color: theme.colorScheme.secondary),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: _buildContenidoLista(
                        opcionSeleccionada,
                        amigos,
                        solicitudesRecibidas,
                        solicitudesEnviadas,
                        context,
                        theme,
                        setStateModal, // Pasa el setStateModal aquí
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContenidoLista(
      String opcion,
      List amigos,
      List solicitudesRecibidas,
      List solicitudesEnviadas,
      BuildContext context,
      ThemeData theme,
      void Function(void Function()) setStateModal, // <--- ahora tienes setState del modal
      ) {
    switch (opcion) {
      case 'Amigos':
        return amigos.isEmpty
            ? Center(child: Text('No tienes amigos', style: theme.textTheme.bodyLarge))
            : ListView.builder(
          itemCount: amigos.length,
          itemBuilder: (context, index) {
            final amigo = amigos[index];
            return ListTile(
              leading: CircleAvatar(
                  backgroundImage: amigo['foto_usuario'] != null
                      ? NetworkImage(amigo['foto_usuario'])
                      : AssetImage('assets/usuario.png') as ImageProvider),
              title: Text(amigo['nombre_usuario'], style: theme.textTheme.bodyLarge),
              subtitle: Text('${amigo['nombre']} ${amigo['apellidos']}', style: theme.textTheme.bodyMedium),
              trailing: IconButton(
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                onPressed: () => _mostrarDialogoEliminarAmigo(
                  context,
                  amigo['pk_usuario'],
                  theme,
                      () async {
                    try {
                      await _userService.eliminarAmigo(amigo['pk_usuario']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Amigo eliminado'), backgroundColor: theme.colorScheme.error),
                      );
                      final nuevaLista = await _userService.getAmigos();
                      setStateModal(() {
                        amigos.clear();
                        amigos.addAll(nuevaLista);
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error eliminando amigo: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OtroProfileScreen(userId: amigo['pk_usuario']))),
            );
          },
        );
      case 'Solicit. Recibidas':
        return solicitudesRecibidas.isEmpty
            ? Center(child: Text('No tienes solicitudes recibidas', style: theme.textTheme.bodyLarge))
            : ListView.builder(
          itemCount: solicitudesRecibidas.length,
          itemBuilder: (context, index) {
            final solicitud = solicitudesRecibidas[index];
            return ListTile(
              leading: CircleAvatar(
                  backgroundImage: solicitud['foto_usuario'] != null
                      ? NetworkImage(solicitud['foto_usuario'])
                      : AssetImage('assets/usuario.png') as ImageProvider),
              title: Text(solicitud['nombre_usuario'], style: theme.textTheme.bodyLarge),
              subtitle: Text('${solicitud['nombre']} ${solicitud['apellidos']}', style: theme.textTheme.bodyMedium),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      try {
                        await _userService.aceptarSolicitudAmistad(solicitud['pk_usuario']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Solicitud aceptada'), backgroundColor: Colors.green),
                        );
                        final nuevasRecibidas = await _userService.getSolicitudesRecibidas();
                        final nuevosAmigos = await _userService.getAmigos();
                        setStateModal(() {
                          solicitudesRecibidas.clear();
                          solicitudesRecibidas.addAll(nuevasRecibidas);
                          amigos.clear();
                          amigos.addAll(nuevosAmigos);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },),
                  IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.error),
                    onPressed: () async {
                      try {
                        await _userService.eliminarSolicitudRecibida(solicitud['pk_usuario']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Solicitud rechazada'), backgroundColor: Colors.green),
                        );
                        final nuevasRecibidas = await _userService.getSolicitudesRecibidas();
                        setStateModal(() {
                          solicitudesRecibidas.clear();
                          solicitudesRecibidas.addAll(nuevasRecibidas);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },),
                ],
              ),
            );
          },
        );
      case 'Solicit. Enviadas':
        return solicitudesEnviadas.isEmpty
            ? Center(child: Text('No tienes solicitudes enviadas', style: theme.textTheme.bodyLarge))
            : ListView.builder(
          itemCount: solicitudesEnviadas.length,
          itemBuilder: (context, index) {
            final solicitud = solicitudesEnviadas[index];
            return ListTile(
              leading: CircleAvatar(
                  backgroundImage: solicitud['foto_usuario'] != null
                      ? NetworkImage(solicitud['foto_usuario'])
                      : AssetImage('assets/usuario.png') as ImageProvider),
              title: Text(solicitud['nombre_usuario'], style: theme.textTheme.bodyLarge),
              subtitle: Text('${solicitud['nombre']} ${solicitud['apellidos']}', style: theme.textTheme.bodyMedium),
              trailing: IconButton(
                  icon: Icon(Icons.cancel, color: theme.colorScheme.error),
                onPressed: () async {
                  try {
                    await _userService.eliminarSolicitudEnviada(solicitud['pk_usuario']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Solicitud cancelada')),
                    );
                    final nuevasEnviadas = await _userService.getSolicitudesEnviadas();
                    setStateModal(() {
                      solicitudesEnviadas.clear();
                      solicitudesEnviadas.addAll(nuevasEnviadas);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },),
            );
          },
        );
      default:
        return Container();
    }
  }

  void _showAddAmigos() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddFriendScreen()));
  }

  void _mostrarDialogoEliminarAmigo(
      BuildContext context,
      String amigoId,
      ThemeData theme,
      Future<void> Function() onConfirmEliminar,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Amigo', style: theme.textTheme.titleMedium),
        content: Text('¿Estás seguro?', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await onConfirmEliminar();
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: Text('Eliminar', style: TextStyle(color: theme.colorScheme.onError)),
          ),
        ],
      ),
    );
  }

  void _editarPerfil() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
    if (result == true) {
      setState(() {
        _gimnasiosFuture = _getGimnasiosDeUsuarioActivo();
      });
    }
  }

  Future<List<Gimnasio>> _getGimnasiosDeUsuarioActivo() async {
    return await _gimnasioService.getGimnasiosDeUsuarioActivo();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: FutureBuilder<Usuario>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No se pudieron cargar los datos.'));
          }

          final usuario = snapshot.data!;

          return SingleChildScrollView( // 👈 Hacemos TODA la pantalla scrollable
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- INFORMACIÓN DE PERFIL ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30, top: 20),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: (usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty)
                            ? NetworkImage(usuario.fotoUsuario!)
                            : AssetImage('assets/usuario.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              usuario.nombreUsuario,
                              style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _showListaAmigos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.background,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                              ),
                              child: Icon(Icons.people, color: theme.colorScheme.secondary),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _editarPerfil,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(color: theme.colorScheme.secondary),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Editar Perfil',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20),

                // --- DESCRIPCIÓN ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(usuario.descripcion ?? '', style: theme.textTheme.bodyLarge),
                ),

                SizedBox(height: 20),
                _buildPanelGimnasios(theme),
                _buildPanelEntrenamientos(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPanelGimnasios(ThemeData theme) {
    return FutureBuilder<List<Gimnasio>>(
        future: _gimnasiosFuture,
        builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: Platform.isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),);
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ExpansionTile(
            title: Text('Mis Gimnasios', style: theme.textTheme.titleMedium),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No hay gimnasios disponibles.', style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        );
      }

      final gimnasios = snapshot.data!;

      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: ExpansionTile(
    title: Text('Mis Gimnasios', style: theme.textTheme.titleMedium),
    children: [
    Container(
      constraints: BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: gimnasios.length,
        itemBuilder: (context, index) {
          final gimnasio = gimnasios[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: gimnasio.logo != null && gimnasio.logo!.isNotEmpty
              ? NetworkImage(gimnasio.logo!)
                  : null,
              backgroundColor: theme.colorScheme.surface,
              child: gimnasio.logo == null || gimnasio.logo!.isEmpty
              ? Icon(Icons.fitness_center, color: theme.colorScheme.secondary)
                  : null,
            ),
              title: Text(
                gimnasio.nombre,
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                gimnasio.ubicacion,
                style: theme.textTheme.bodyMedium,
              ),
          );
        },
      ),
    ),
    ],
    ),
      );
        },
    );
  }
  Widget _buildPanelEntrenamientos(ThemeData theme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _misEntrenamientosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator()
                : const CupertinoActivityIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar entrenamientos: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mis Entrenamientos', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'No has registrado entrenamientos.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final entrenamientos = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mis Entrenamientos', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // 👈 dejamos que el padre scrollee
                itemCount: entrenamientos.length,
                itemBuilder: (context, index) {
                  final entrenamiento = entrenamientos[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TrainingFeedCard(
                      trainingData: entrenamiento,
                      onUserTap: null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}