import 'package:flutter/material.dart';
import 'package:gym_app/models/Cadena.dart';
import 'package:gym_app/models/Gimnasio.dart';
import 'package:gym_app/services/cadena_gimnasio_service.dart';
import 'package:gym_app/services/gimnasio_service.dart';
import '../widgets/cadena_card.dart';

class AddGimnasioScreen extends StatefulWidget {
  @override
  _AddGimnasioScreenState createState() => _AddGimnasioScreenState();
}

class _AddGimnasioScreenState extends State<AddGimnasioScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _codigoPostalController = TextEditingController();
  final GimnasioService _gimnasioService = GimnasioService();
  final CadenaGimnasioService _cadenaGimnasioService = CadenaGimnasioService();
  List<Gimnasio> _resultados = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  final FocusNode _focusNode = FocusNode();
  bool _showFilters = false;
  int _filterCount = 0;
  List<Cadena> _cadenas = [];
  Set<String> _selectedCadenas = {};
  Set<String> _gimnasiosUsuarioIds = {};
  Set<String> _selectedGimnasios = {};
  bool _showAddButton = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showFilters) {
        setState(() {
          _showFilters = false;
        });
      }
    });
    _loadCadenas();
    _getGimnasiosUsuario();
  }

  void _loadCadenas() async {
    try {
      final cadenas = await _cadenaGimnasioService.getListaDeCadenasGym();
      setState(() {
        _cadenas = cadenas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar cadenas: $e')));
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedGimnasios.clear();
      _showAddButton = false;
    });
  }

  Future<void> _getGimnasiosUsuario() async {
    try {
      final gimnasios = await _gimnasioService.getGimnasiosDeUsuarioActivo();
      setState(() {
        _gimnasiosUsuarioIds = gimnasios.map((g) => g.pk_gimnasio).toSet();
      });
    } catch (e) {}
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
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al añadir gimnasios: $e'),
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
      await _getGimnasiosUsuario();
      final nombre = _searchController.text;
      final codigoPostal = _codigoPostalController.text;
      final cadenas = _selectedCadenas.toList();
      final gimnasios = await _gimnasioService.buscarGimnasios(
        nombre: nombre,
        codigoPostal: codigoPostal,
        cadenas: cadenas,
      );
      final List<Gimnasio> gimnasiosFiltrados = gimnasios.where((gimnasio) => !_gimnasiosUsuarioIds.contains(gimnasio.pk_gimnasio)).toList();
      setState(() {
        _resultados = gimnasiosFiltrados;
        _isSearching = false;
        _filterCount = (codigoPostal.isNotEmpty ? 1 : 0) + (cadenas.isNotEmpty ? 1 : 0);
        _showFilters = false;
        _clearSelection();
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
      );
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  bool _isApplyButtonEnabled() {
    return _codigoPostalController.text.isNotEmpty || _selectedCadenas.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir gimnasio', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Buscar',
                        hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: colorScheme.outline)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: colorScheme.outline)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                      ),
                      onSubmitted: (_) => _buscarGimnasios(),
                    ),
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(Icons.filter_list, color: colorScheme.primary),
                        if (_filterCount > 0)
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: colorScheme.error,
                              child: Text(
                                '$_filterCount',
                                style: textTheme.labelSmall?.copyWith(color: colorScheme.onError, fontSize: 12),
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
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: _showFilters
                  ? Container(
                key: ValueKey<bool>(_showFilters),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _codigoPostalController,
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Cod. Postal',
                          labelStyle: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: colorScheme.outline),
                    const SizedBox(height: 10),
                    Text(
                      'Cadenas / Gimnasios Disponibles',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 300,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: _cadenas.length,
                        itemBuilder: (context, index) {
                          final cadena = _cadenas[index];
                          return CadenaCard(
                            id: cadena.pk_cadena_gimnasio,
                            nombre: cadena.nombre,
                            logo: cadena.logo ?? '',
                            isSelected: _selectedCadenas.contains(cadena.pk_cadena_gimnasio),
                            onTap: () {
                              _toggleCadenaSelection(cadena.pk_cadena_gimnasio);
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: colorScheme.outline),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _toggleFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            foregroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Cerrar',
                            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _isApplyButtonEnabled() ? _buscarGimnasios : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            foregroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Aplicar',
                            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
            _isSearching
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : Expanded(
              child: _hasSearched && _resultados.isEmpty
                  ? Center(child: Text('No se encontraron gimnasios', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)))
                  : ListView.builder(
                itemCount: _resultados.length,
                itemBuilder: (context, index) {
                  final gimnasio = _resultados[index];
                  final isSelected = _selectedGimnasios.contains(gimnasio.pk_gimnasio);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedGimnasios.remove(gimnasio.pk_gimnasio);
                        } else {
                          _selectedGimnasios.add(gimnasio.pk_gimnasio);
                        }
                      });
                    },
                    child: Container(
                      color: isSelected ? colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: gimnasio.logo != null && gimnasio.logo!.isNotEmpty
                              ? NetworkImage(gimnasio.logo!)
                              : null,
                          backgroundColor: colorScheme.surfaceVariant,
                          child: gimnasio.logo == null || gimnasio.logo!.isEmpty
                              ? Icon(Icons.fitness_center, color: colorScheme.primary)
                              : null,
                        ),
                        title: Text(gimnasio.nombre, style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
                        subtitle: Text(
                          '${gimnasio.ciudad}${gimnasio.codigo_postal != null && gimnasio.codigo_postal != "NULL" && gimnasio.codigo_postal!.isNotEmpty ? ", ${gimnasio.codigo_postal}" : ""}',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                        ),
                        trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedGimnasios.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _addSelectedGyms,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        label: Text('Añadir (${_selectedGimnasios.length})', style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
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