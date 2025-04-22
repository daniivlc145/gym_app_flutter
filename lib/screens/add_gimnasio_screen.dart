import 'package:flutter/material.dart';
import 'package:gym_app/services/gimnasio_service.dart';
import '../widgets/cadena_card.dart';

class AddGimnasioScreen extends StatefulWidget {
  @override
  _AddGimnasioScreenState createState() => _AddGimnasioScreenState();
}

class _AddGimnasioScreenState extends State<AddGimnasioScreen> {
  // Controlador de la busqueda por nombre
  final TextEditingController _searchController = TextEditingController();
  // Controlador del codigo postal
  final TextEditingController _codigoPostalController = TextEditingController();
  // Instancia del servicio de gimnasio
  final GimnasioService _gimnasioService = GimnasioService();
  // Resultado de gimnasios encontrados en la busqueda
  List _resultados = [];
  // Estado de búsqueda activa
  bool _isSearching = false;
  // Estado de búsqueda realizada
  bool _hasSearched = false;
  final FocusNode _focusNode = FocusNode();
  // Estado de mostrar filtros
  bool _showFilters = false;
  // Contador de filtros
  int _filterCount = 0;
  // Lista de cadenas encontradas para filtro
  List<Map<String, dynamic>> _cadenas = [];
  // Lista de cadenas seleccionadas
  Set<String> _selectedCadenas = {};
  // Lista de gimnasios de usuario
  Set<String> _gimnasiosUsuario = {};
  // Lista de gimnasios seleccionados
  Set<String> _selectedGimnasios = {};
  bool _showAddButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _loadCadenas();
    _getGimnasiosUsuario();
  }

  void _loadCadenas() async {
    try {
      final cadenas = await _gimnasioService.getListaDeCadenasGym();
      setState(() {
        _cadenas = cadenas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar cadenas: $e'), backgroundColor: Colors.red));
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedGimnasios.clear();
      _showAddButton = false;
    });
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

  void _toggleCadenaSelection(String id) {
    setState(() {
      if (_selectedCadenas.contains(id)) {
        _selectedCadenas.remove(id);
      } else {
        _selectedCadenas.add(id);
      }
    });
  }

  void _addSelectedGyms() async {
    if (_selectedGimnasios.isEmpty) return;

    try {
      setState(() {
        _isSearching = true;
      });

      for (String gymId in _selectedGimnasios) {
        try {
          await _gimnasioService.addGymAUsuario(gymId);
        } catch (e) {
          throw e;
        }
      }

      setState(() {
        _selectedGimnasios.clear();
      });

      await _getGimnasiosUsuario();
      await _buscarGimnasios();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gimnasios añadidos correctamente'),
          backgroundColor: Color(0xFF1ABC9C),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al añadir gimnasios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _buscarGimnasios() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final gimnasiosUsuario = await _getGimnasiosUsuario();
      final idsUsuario = gimnasiosUsuario
          .where((g) => g['pk_gimnasio'] != null)
          .map((g) => g['pk_gimnasio'].toString())
          .toSet();

      final nombre = _searchController.text;
      final codigoPostal = _codigoPostalController.text;
      final cadenas = _selectedCadenas.toList();

      final resultados = await _gimnasioService.buscarGimnasios(
        nombre: nombre,
        codigoPostal: codigoPostal,
        cadenas: cadenas,
      );

      List<Map<String, dynamic>> gimnasiosFiltrados = [];

      for (var gimnasio in resultados) {
        final gimnasioId = gimnasio['pk_gimnasio'].toString();

        if (!idsUsuario.contains(gimnasioId)) {
          gimnasiosFiltrados.add({
            'pk_gimnasio': gimnasioId,
            'nombre': gimnasio['nombre'] ?? 'Nombre no disponible',
            'ciudad': gimnasio['ciudad'] ?? 'Ciudad no disponible',
            'codigo_postal': gimnasio['codigo_postal']?.toString() ?? '',
            'cadena_gimnasio': gimnasio['cadena_gimnasio'],
          });
        }
      }


      setState(() {
        _resultados = gimnasiosFiltrados;
        _isSearching = false;
        _filterCount = (codigoPostal.isNotEmpty ? 1 : 0) +
            (cadenas.isNotEmpty ? 1 : 0);
        _showFilters = false;
        _clearSelection();
      });

    } catch (e) {
      print('Error en _buscarGimnasios: $e');
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
      );
    }
  }


  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  bool _isApplyButtonEnabled() {
    return _codigoPostalController.text.isNotEmpty || _selectedCadenas.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Añadir gimnasio')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    onSubmitted: (_) => _buscarGimnasios(),
                  ),
                ),
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.filter_list),
                      if (_filterCount > 0)
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text(
                              '$_filterCount',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _toggleFilters,
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(sizeFactor: animation, child: child);
            },
            child: _showFilters
                ? Container(
              key: ValueKey<bool>(_showFilters),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _codigoPostalController,
                      decoration: InputDecoration(
                        labelText: 'Cod. Postal',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Cadenas / Gimnasios Disponibles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 300,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: _cadenas.length,
                      itemBuilder: (context, index) {
                        final cadena = _cadenas[index];
                        return CadenaCard(
                          id: cadena['pk_cadena_gimnasio'],
                          nombre: cadena['nombre'],
                          logo: cadena['logo'],
                          isSelected: _selectedCadenas.contains(cadena['pk_cadena_gimnasio']),
                          onTap: () {
                            _toggleCadenaSelection(cadena['pk_cadena_gimnasio']);
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _toggleFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF1ABC9C),
                        ),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _isApplyButtonEnabled() ? _buscarGimnasios : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF1ABC9C),
                        ),
                        child: Text(
                          'Aplicar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                : SizedBox.shrink(),
          ),
          _isSearching
              ? CircularProgressIndicator()
              : Expanded(
            child: _hasSearched && _resultados.isEmpty
                ? Center(child: Text('No se encontraron gimnasios'))
                : ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final gimnasio = _resultados[index];
                final gimnasioId = gimnasio['pk_gimnasio'].toString();
                final nombre = gimnasio['nombre'] ?? 'Nombre no disponible';
                final ciudad = gimnasio['ciudad'] ?? 'Ciudad no disponible';
                final codigoPostal = gimnasio['codigo_postal']?.toString() ?? '';
                final logoUrl = gimnasio['cadena_gimnasio']['logo'] ?? '';
                final isSelected = _selectedGimnasios.contains(gimnasioId);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGimnasios.remove(gimnasioId);
                      } else {
                        _selectedGimnasios.add(gimnasioId);
                      }
                    });
                  },
                  child: Container(
                    color: isSelected ? Color(0xFF1ABC9C).withOpacity(0.2) : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
                        backgroundColor: Colors.grey[200],
                        child: logoUrl.isEmpty ? Icon(Icons.image, color: Colors.grey) : null,
                      ),
                      title: Text(nombre),
                      subtitle: Text('$ciudad${codigoPostal != 'NULL' && codigoPostal.isNotEmpty ? ", $codigoPostal" : ""}'),
                      trailing: isSelected ? Icon(Icons.check, color: Color(0xFF1ABC9C)) : null,
                    ),
                  ),
                );
              },
            )
          ),
        ],
      ),
      floatingActionButton: _selectedGimnasios.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _addSelectedGyms,
        backgroundColor: Color(0xFF1ABC9C),
        label: Text('Añadir (${_selectedGimnasios.length})'),
        icon: Icon(Icons.add),
      )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _codigoPostalController.dispose();
    _focusNode.dispose();
    _selectedGimnasios.clear();
    super.dispose();
  }
}