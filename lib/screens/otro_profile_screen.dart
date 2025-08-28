import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/Usuario.dart';
import '../services/user_service.dart';

class OtroProfileScreen extends StatefulWidget {
  final String userId;

  const OtroProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<OtroProfileScreen> createState() => _OtroProfileScreenState();
}

class _OtroProfileScreenState extends State<OtroProfileScreen> {
  final UserService _userService = UserService();
  Usuario? usuario;
  bool? esAmigo;
  bool solicitudEnviada = false;
  bool solicitudRecibida = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkRelationshipAndLoadData();
  }

  Future<void> _checkRelationshipAndLoadData() async {
    try {
      final currentUserId = _userService.supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      // 1. Comprobar relación
      final solicitudes = await _userService.supabase
          .from('solicitud_amistad')
          .select()
          .or(
          'and(fk_usuario_origen.eq.${currentUserId},fk_usuario_destino.eq.${widget.userId}),'
              'and(fk_usuario_origen.eq.${widget.userId},fk_usuario_destino.eq.${currentUserId})')
          .maybeSingle();

      if (solicitudes != null) {
        if (solicitudes['estado'] == 'aceptado') {
          esAmigo = true;
        } else if (solicitudes['estado'] == 'pendiente') {
          if (solicitudes['fk_usuario_origen'] == currentUserId) {
            solicitudEnviada = true;
          } else {
            solicitudRecibida = true;
          }
        }
      } else {
        esAmigo = false;
      }

      // 2. Cargar datos del usuario (mínimos aunque no sean amigos)
      final userDataMap = await _userService.getUserDataById(widget.userId);
      usuario = Usuario.fromMap(userDataMap);

      if (usuario!.fotoUsuario != null && usuario!.fotoUsuario!.isNotEmpty) {
        await precacheImage(NetworkImage(usuario!.fotoUsuario!), context);
      }
    } catch (e) {
      print("❌ Error en _checkRelationshipAndLoadData: $e");
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
          body: Center(
              child: Platform.isAndroid
                  ? const CircularProgressIndicator()
                  : const CupertinoActivityIndicator()));
    }

    if (usuario == null) {
      return Scaffold(
        body: Center(child: Text("No se pudo cargar el perfil")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(usuario!.nombreUsuario),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: usuario!.fotoUsuario != null &&
                  usuario!.fotoUsuario!.isNotEmpty
                  ? NetworkImage(usuario!.fotoUsuario!)
                  : AssetImage('assets/usuario.png') as ImageProvider,
            ),
            const SizedBox(height: 15),
            Text(
              usuario!.nombreUsuario,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Caso: Amigo aceptado
            if (esAmigo == true) ...[
              Text(usuario!.descripcion ?? '',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Text("Aquí puedes cargar entrenamientos de tu amigo 👇"),
              // TODO: usar TrainingService para traer entrenamientos de este user
            ],

            // Caso: Solicitud pendiente enviada
            if (solicitudEnviada) ...[
              Icon(Icons.lock, size: 80, color: Colors.grey),
              Text("Solicitud enviada, esperando confirmación..."),
              ElevatedButton(
                onPressed: () async {
                  await _userService.eliminarSolicitudEnviada(widget.userId);
                  setState(() {
                    solicitudEnviada = false;
                    esAmigo = false;
                  });
                },
                child: Text("Cancelar solicitud"),
              )
            ],

            // Caso: Solicitud pendiente recibida
            if (solicitudRecibida) ...[
              Icon(Icons.lock, size: 80, color: Colors.grey),
              Text("${usuario!.nombreUsuario} quiere ser tu amigo"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        await _userService
                            .aceptarSolicitudAmistad(widget.userId);
                        setState(() {
                          solicitudRecibida = false;
                          esAmigo = true;
                        });
                      },
                      child: Text("Aceptar")),
                  SizedBox(width: 10),
                  TextButton(
                      onPressed: () async {
                        await _userService
                            .eliminarSolicitudRecibida(widget.userId);
                        setState(() {
                          solicitudRecibida = false;
                          esAmigo = false;
                        });
                      },
                      child: Text("Denegar"))
                ],
              )
            ],

            // Caso: No amigos
            if (esAmigo == false && !solicitudEnviada && !solicitudRecibida) ...[
              Icon(Icons.lock, size: 80, color: Colors.grey),
              Text(
                "${usuario!.nombreUsuario} y tú no sois amigos",
                style: TextStyle(fontSize: 16),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _userService.enviarSolicitudAmistad(widget.userId);
                  setState(() {
                    solicitudEnviada = true;
                  });
                },
                child: Text("Enviar solicitud"),
              )
            ]
          ],
        ),
      ),
    );
  }
}