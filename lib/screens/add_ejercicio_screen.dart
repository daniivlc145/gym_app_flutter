import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:gym_app/services/ejercicio_service.dart';
import '../models/Ejercicio.dart';

class AddEjercicioScreen extends StatefulWidget {
  final List<Ejercicio> ejerciciosYaAnadidos;

  const AddEjercicioScreen({Key? key, required this.ejerciciosYaAnadidos}) : super(key: key);

  @override
  _AddEjercicioScreenState createState() => _AddEjercicioScreenState();
}

class _AddEjercicioScreenState extends State<AddEjercicioScreen> {
  final EjercicioService _ejercicioService = EjercicioService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _grupoMuscularOptions = [];
  List<String> _equipamientoOptions = [];

  String? _selectedGroup;
  String? _selectedEquipment;

  List<Ejercicio> _ejerciciosEncontrados = [];

  bool _isSearching = false;
  bool _hasSearched = false;
  final FocusNode _focusNode = FocusNode();
  bool _showFilters = false;
  bool _isLoading = false;

  Set<int> _ejerciciosAnadidosIds = {};
  Set<int> _ejerciciosSeleccionados = {};

  bool _isDropdownOpen = false;
  int _filterCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showFilters) {
        setState(() => _showFilters = false);
      }
    });
    _loadFilterValues();
    _cargarEjerciciosYaAnadidos();
    _updateFilterCount();
  }

  void _cargarEjerciciosYaAnadidos() {
    _ejerciciosAnadidosIds = widget.ejerciciosYaAnadidos.map((e) => e.pk_ejercicio).toSet();
  }

  Future<void> _loadFilterValues() async {
    setState(() => _isLoading = true);
    try {
      final grupoMuscular = await _ejercicioService.getDistinctGrupoMuscular();
      final equipamiento = await _ejercicioService.getDistinctEquipamiento();
      setState(() {
        _grupoMuscularOptions = grupoMuscular;
        _equipamientoOptions = equipamiento;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar filtros: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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

  void _clearFilter(String category) {
    setState(() {
      if (category == 'grupo_muscular') {
        _selectedGroup = null;
      } else if (category == 'equipamiento') {
        _selectedEquipment = null;
      }
      _updateFilterCount();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedGroup = null;
      _selectedEquipment = null;
      _updateFilterCount();
    });
  }

  Future<void> _buscarEjercicios() async {
    setState(() {
      _isSearching = true;
      _showFilters = false;
    });

    try {
      List<Ejercicio> ejercicios = await _ejercicioService.buscarEjercicios(
        nombre: _searchController.text.trim(),
        grupoMuscular: _selectedGroup != null ? [_selectedGroup!] : null,
        equipamiento: _selectedEquipment != null ? [_selectedEquipment!] : null,
      );
      ejercicios = ejercicios.where((e) => !_ejerciciosAnadidosIds.contains(e.pk_ejercicio)).toList();
      setState(() {
        _ejerciciosEncontrados = ejercicios;
        _hasSearched = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar ejercicios. $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _confirmarSeleccion() {
    final selectedEjercicios = _ejerciciosEncontrados
        .where((ejercicio) => _ejerciciosSeleccionados.contains(ejercicio.pk_ejercicio))
        .toList();

    Navigator.pop(context, selectedEjercicios);
  }

  void _updateFilterCount() {
    setState(() {
      _filterCount = (_selectedGroup != null ? 1 : 0) + (_selectedEquipment != null ? 1 : 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Añadir ejercicios')),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
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
                          decoration: InputDecoration(
                            hintText: 'Buscar',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          onSubmitted: (_) => _buscarEjercicios(),
                        ),
                      ),
                      IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.filter_list),
                            if (_filterCount > 0)
                              Positioned(
                                right: 0,
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: colorScheme.error,
                                  child: Text(
                                    _filterCount.toString(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onError,
                                      fontSize: 12,
                                    ),
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
                if (_showFilters)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(color: colorScheme.primary, width: 1.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterDropdown(
                              label: 'Grupo Muscular',
                              category: 'grupo_muscular',
                              values: _grupoMuscularOptions,
                              selectedValue: _selectedGroup,
                            ),
                            _buildFilterDropdown(
                              label: 'Equipamiento',
                              category: 'equipamiento',
                              values: _equipamientoOptions,
                              selectedValue: _selectedEquipment,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text("Limpiar filtros"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surface,
                                    foregroundColor: colorScheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _clearAllFilters,
                                ),
                                const SizedBox(width: 18),
                                ElevatedButton(
                                  onPressed: _buscarEjercicios,
                                  child: const Text('Aplicar filtros'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : _hasSearched && _ejerciciosEncontrados.isEmpty
                        ? const Center(child: Text('No se encontraron ejercicios'))
                        : ListView.builder(
                      itemCount: _ejerciciosEncontrados.length,
                      itemBuilder: (context, index) {
                        final ejercicio = _ejerciciosEncontrados[index];
                        return _buildEjercicioCard(ejercicio);
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_isDropdownOpen)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.15)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _ejerciciosSeleccionados.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _confirmarSeleccion,
          child: Text('Añadir ${_ejerciciosSeleccionados.length} ejercicios'),
        ),
      )
          : null,
    );
  }

  Widget _buildEjercicioCard(Ejercicio ejercicio) {
    final isSelected = _ejerciciosSeleccionados.contains(ejercicio.pk_ejercicio);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(ejercicio.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Grupo muscular: ${ejercicio.grupo_muscular}'),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                _ejerciciosSeleccionados.add(ejercicio.pk_ejercicio);
              } else {
                _ejerciciosSeleccionados.remove(ejercicio.pk_ejercicio);
              }
            });
          },
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _ejerciciosSeleccionados.remove(ejercicio.pk_ejercicio);
            } else {
              _ejerciciosSeleccionados.add(ejercicio.pk_ejercicio);
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String category,
    required List<String> values,
    required String? selectedValue,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  value: selectedValue,
                  items: values.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          if (_isDropdownOpen && value == selectedValue)
                            const Icon(Icons.check, size: 18, color: Colors.green),
                          if (_isDropdownOpen && value == selectedValue)
                            const SizedBox(width: 6),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (category == 'grupo_muscular') {
                        _selectedGroup = _selectedGroup == value ? null : value;
                      } else if (category == 'equipamiento') {
                        _selectedEquipment = _selectedEquipment == value ? null : value;
                      }
                      _updateFilterCount();
                    });
                  },
                  hint: const Text('Seleccionar'),
                  onMenuStateChange: (isOpen) {
                    setState(() => _isDropdownOpen = isOpen);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary, width: 1),
                      color: colorScheme.surface,
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary),
                      color: colorScheme.surface,
                    ),
                    elevation: 4,
                    offset: const Offset(0, 4),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
            if (selectedValue != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Borrar selección',
                onPressed: () => _clearFilter(category),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

}


// Extensión para togglear Sets
extension ToggleSet<T> on Set<T> {
  void toggle(T value) {
    contains(value) ? remove(value) : add(value);
  }
}