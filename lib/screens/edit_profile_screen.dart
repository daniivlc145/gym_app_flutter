import 'package:flutter/material.dart';
import 'package:gym_app/models/Usuario.dart';
import 'package:gym_app/screens/add_gimnasio_screen.dart';
import 'package:gym_app/services/user_service.dart';
import 'package:gym_app/utils/validators.dart';
import 'package:gym_app/services/gimnasio_service.dart';
import 'package:gym_app/models/Gimnasio.dart';

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

  List<Gimnasio> _gimnasios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
  }

  Future<Usuario> _getUserData() async {
    final userDataMap = await _userService.getCurrentUserData();
    final usuario = Usuario.fromMap(userDataMap);
    return usuario;
  }

  Future<List<Gimnasio>> _getGimnasiosUsuario() async {
    try {
      final gimnasiosCompletos = await _gimnasioService.getGimnasiosDeUsuarioActivo();
      return gimnasiosCompletos;
    } catch (e) {
      print('Error al obtener gimnasios: $e');
      return [];
    }
  }

  void _showAdministrarGimnasios() async {
    setState(() {
      _isLoading = true;
    });
    _gimnasios = await _getGimnasiosUsuario();

    Set<String> selectedGimnasios = {};
    bool isDeleting = false;
    bool gimnasiosModificados = false;

    setState(() {
      _isLoading = false;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: selectedGimnasios.isNotEmpty
              ? FloatingActionButton.extended(
            onPressed: isDeleting
                ? null
                : () async {
              try {
                setState(() {
                  isDeleting = true;
                });

                // Eliminar todos los gimnasios seleccionados
                for (String gymId in selectedGimnasios) {
                  await _gimnasioService.eliminarGymAUsuario(gymId);
                }

                // Actualizar la lista después de eliminar
                _gimnasios = await _getGimnasiosUsuario();
                setState(() {
                  selectedGimnasios.clear();
                  isDeleting = false;
                });

                gimnasiosModificados = true;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gimnasio(s) eliminado(s) correctamente'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              } catch (e) {
                print(e);
                setState(() {
                  isDeleting = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar gimnasio(s): $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            icon: isDeleting
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onError,
                strokeWidth: 2,
              ),
            )
                : Icon(Icons.delete),
            label: Text(isDeleting
                ? 'Eliminando...'
                : 'Eliminar (${selectedGimnasios.length})'),
          )
              : null,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (_, controller) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mis Gimnasios",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddGimnasioScreen()),
                              );

                              // Si se añadió un gimnasio, actualizar la lista
                              if (result == true) {
                                gimnasiosModificados = true;
                              }

                              _gimnasios = await _getGimnasiosUsuario();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(12),
                            ),
                            child: Icon(Icons.add, size: 24),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _gimnasios.isEmpty
                          ? Center(
                        child: Text(
                          'Aún no tienes gimnasios en tu lista',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                          : ListView.builder(
                        controller: controller,
                        padding: EdgeInsets.all(16.0),
                        itemCount: _gimnasios.length,
                        itemBuilder: (context, index) {
                          final gimnasio = _gimnasios[index];
                          final isSelected =
                          selectedGimnasios.contains(gimnasio.pk_gimnasio);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedGimnasios.remove(gimnasio.pk_gimnasio);
                                } else {
                                  selectedGimnasios.add(gimnasio.pk_gimnasio);
                                }
                              });
                            },
                            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            highlightColor:
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.error.withOpacity(0.15)
                                  : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: gimnasio.logo != null &&
                                      gimnasio.logo!.isNotEmpty
                                      ? NetworkImage(gimnasio.logo!)
                                      : null,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  child: gimnasio.logo == null || gimnasio.logo!.isEmpty
                                      ? Icon(Icons.fitness_center,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5))
                                      : null,
                                ),
                                title: Text(
                                  gimnasio.nombre,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  gimnasio.ubicacion,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                trailing: AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: isSelected ? 1.0 : 0.0,
                                  child: Icon(Icons.check,
                                      color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ),
                          );
                        },
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
    if (gimnasiosModificados) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _editarPerfil(
      String nombreUsuario, String descripcion, String nombreUsuarioForo) async {
    try {
      await _userService.updateUserDataFromEditProfile(
          nombreUsuario, descripcion, nombreUsuarioForo);
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
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData)
            return Center(child: Text('No se pudieron cargar los datos.'));

          final usuario = snapshot.data!;
          if (_nombreUsuarioController.text.isEmpty) {
            _nombreUsuarioController.text = usuario.nombreUsuario;
          }
          if (_descripcionController.text.isEmpty) {
            _descripcionController.text = usuario.descripcion ?? '';
          }
          if (_nombreUsuarioForoController.text.isEmpty) {
            _nombreUsuarioForoController.text =
                usuario.nombreUsuarioForo ?? usuario.nombreUsuario;
          }
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
                            prefixIcon: Icon(Icons.person,
                              color: Theme.of(context).iconTheme.color,
                            ),
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
                            prefixIcon: Icon(Icons.edit,
                              color: Theme.of(context).iconTheme.color,
                            ),
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
                            prefixIcon: Icon(Icons.forum,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                            labelText: usuario.nombreUsuarioForo ?? usuario.nombreUsuario,
                            hintText: 'Nombre de usuario en foros',
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _editarPerfil(
                              _nombreUsuarioController.text,
                              _descripcionController.text,
                              _nombreUsuarioForoController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          "Guardar",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _showAdministrarGimnasios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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