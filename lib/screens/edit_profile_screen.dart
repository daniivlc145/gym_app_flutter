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
  Future<List<Map<String, dynamic>>>? _cadenasGymFuture;
  Future<List<Map<String, dynamic>>>? _gimnasiosUsuarioFuture;


  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
    _cadenasGymFuture = _getListaDeCadenasGym();
    _gimnasiosUsuarioFuture = _getGimnasiosUsuario();
  }



  Future<List<Map<String, dynamic>>> _getListaDeCadenasGym() async {
    return await _gimnasioService.getListaDeCadenasGym();
  }

  Future<List<Map<String, dynamic>>> _getGimnasiosUsuario() async {
    return await _gimnasioService.getGimnasiosDeUsuarioActivo();
  }

  Future<Usuario> _getUserData() async {
    final userDataMap = await _userService.getCurrentUserData();
    final usuario = Usuario.fromMap(userDataMap);

    if (usuario.fotoUsuario != null && usuario.fotoUsuario!.isNotEmpty) {
      await precacheImage(NetworkImage(usuario.fotoUsuario!), context);
    }

    return usuario;
  }

  void _showAdministrarGimnasios() async {
    try {
      final cadenas = await _cadenasGymFuture;
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Mis Gimnasios",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Acción para añadir un nuevo gimnasio
                        },
                        child: Text("Añadir"),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 3 / 2,
                          ),
                          itemCount: cadenas?.length ?? 0,
                          itemBuilder: (context, index) {
                            final cadena = cadenas![index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    cadena['logo'],
                                    height: 50,
                                    width: 50,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    cadena['nombre'],
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
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
                          SizedBox(height: 25),
                          ElevatedButton(
                              onPressed: _showAdministrarGimnasios,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF1ABC9C),
                                  side: BorderSide(color: Color(0xFF1ABC9C), width: 2),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fitness_center),
                                  SizedBox(width: 15),
                                  Text("Mis Gimnasios")
                                ],
                              ),
                          )
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