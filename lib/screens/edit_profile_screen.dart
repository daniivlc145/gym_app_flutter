import 'package:flutter/material.dart';
import 'package:gym_app/models/Usuario.dart';
import 'package:gym_app/screens/add_gimnasio_screen.dart';
import 'package:gym_app/services/user_service.dart';
import 'package:gym_app/utils/validators.dart';
import 'package:gym_app/services/gimnasio_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _nombreUsuarioForoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final UserService _userService = UserService();
  final GimnasioService _gimnasioService = GimnasioService();

  Future<Usuario>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
  }

  Future<Usuario> _getUserData() async {
    final userDataMap = await _userService.getCurrentUserData();
    final usuario = Usuario.fromMap(userDataMap);
    if (usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty) {
      await precacheImage(NetworkImage(usuario.fotoUsuario!), context);
    }
    return usuario;
  }

  Future<List<Map<String, dynamic>>> _getGimnasiosUsuario() async {
    try {
      final gimnasiosCompletos = await _gimnasioService.getGimnasiosDeUsuarioActivo();
      return gimnasiosCompletos;
    } catch (e) {
      print('Error al obtener gimnasios: $e');
      return [];
    }
  }

  void _showAdministrarGimnasios() async {
    List<Map<String, dynamic>> gimnasios = await _getGimnasiosUsuario();
    String? selectedGimnasioId;

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
            builder: (_, controller) => Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFECF0F1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Mis Gimnasios", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddGimnasioScreen()),
                                );
                                gimnasios = await _getGimnasiosUsuario();
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF1ABC9C),
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(12),
                              ),
                              child: Icon(Icons.add, size: 24),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: gimnasios.isEmpty
                            ? Center(
                          child: Text(
                            'Aún no tienes gimnasios en tu lista',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                            : ListView.builder(
                          controller: controller,
                          padding: EdgeInsets.all(16.0),
                          itemCount: gimnasios.length,
                          itemBuilder: (context, index) {
                            final gimnasio = gimnasios[index];
                            final gimnasioId = gimnasio['pk_gimnasio']?.toString() ?? '';
                            final nombre = gimnasio['nombre'] ?? 'Sin nombre';
                            final ciudad = gimnasio['ciudad'] ?? 'Sin ciudad';
                            final codigoPostal = gimnasio['codigo_postal']?.toString() ?? '';
                            final cadena = gimnasio['cadena_gimnasio'];
                            final logo = cadena?['logo'] ?? '';
                            final isSelected = selectedGimnasioId == gimnasioId;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedGimnasioId = isSelected ? null : gimnasioId;
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                color: isSelected ? Color(0xFF1ABC9C).withOpacity(0.2) : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
                                    backgroundColor: Colors.grey[200],
                                    child: logo.isEmpty ? Icon(Icons.fitness_center, color: Colors.grey) : null,
                                  ),
                                  title: Text(nombre),
                                  subtitle: Text('$ciudad${codigoPostal.isNotEmpty ? ', $codigoPostal' : ''}'),
                                  trailing: isSelected ? Icon(Icons.check, color: Color(0xFF1ABC9C)) : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedGimnasioId != null)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FloatingActionButton.extended(
                        onPressed: () async {
                          try {
                            await _gimnasioService.eliminarGymAUsuario(selectedGimnasioId!);
                            Navigator.pop(context);
                            setState(() {

                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gimnasio eliminado correctamente'),
                                backgroundColor: Color(0xFF1ABC9C),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al eliminar gimnasio: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.delete),
                        label: Text('Eliminar'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
      ),
    );
  }

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _nombreUsuarioForoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar perfil')),
      body: FutureBuilder<Usuario>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return Center(child: Text('No se pudieron cargar los datos.'));

          final usuario = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _nombreUsuarioController,
                          validator: (value) => Validators.validateUsername(value ?? ''),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                            labelText: usuario.nombreUsuario,
                            hintText: 'Nombre de usuario',
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _descripcionController,
                          validator: (value) => Validators.validateDescripcion(value ?? ''),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.edit),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                            labelText: usuario.descripcion ?? '',
                            hintText: 'Descripción del perfil',
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _nombreUsuarioForoController,
                          validator: (value) => Validators.validateUsernameForo(value ?? ''),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.forum),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                            labelText: usuario.nombreUsuarioForo ?? usuario.nombreUsuario,
                            hintText: 'Nombre de usuario en foros',
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _showAdministrarGimnasios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF1ABC9C),
                          side: BorderSide(color: Color(0xFF1ABC9C), width: 2),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center),
                            SizedBox(width: 10),
                            Text("Mis Gimnasios"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
