import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../services/forum_service.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ForumService _forumService = ForumService();
  final _formKey = GlobalKey<FormState>();

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _etiquetasCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();

  String? _selectedTopic;
  List<Map<String, dynamic>> _topics = [];
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _success = false; // ✅ nuevo estado

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final topics = await _forumService.getAllTopicsFull();
    setState(() {
      _topics = topics;
    });
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Solo se permiten 4 imágenes máximo")),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked != null) {
      final newImages =
      picked.take(4 - _selectedImages.length).map((e) => File(e.path));
      setState(() {
        _selectedImages.addAll(newImages);
      });
    }
  }

  Future<void> _crearPost() async {
    if (!_formKey.currentState!.validate() || _selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rellena todos los campos obligatorios")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final etiquetas = _etiquetasCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _forumService.createPost(
        titulo: _tituloCtrl.text,
        descripcion: _descripcionCtrl.text,
        fkTopic: _selectedTopic!,
        etiquetas: etiquetas,
        fotosLocales: _selectedImages,
      );

      // ✅ Mostrar check verde en pantalla blanca
      setState(() {
        _isLoading = false;
        _success = true;
      });

      // Redirigir tras 2 segundos
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context, true);
      });
    } catch (e, st) {
      // ✅ Mostrar en consola + snackbar
      debugPrint("❌ Error creando post: $e");
      debugPrintStack(stackTrace: st);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear post")),
      );
    }
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Post")),
      body: _isLoading
          ? Center(
        child: Platform.isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),
      )
          : _success
          ? Container(
        color: Colors.white,
        child: Center(
          child: AnimatedScale(
            scale: _success ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _success ? 1.0 : 0.0,
              duration: Duration(milliseconds: 600),
              child: Icon(Icons.check_circle,
                  size: 100, color: Colors.green),
            ),
          ),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: _fieldDecoration("Título *"),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "El título es obligatorio"
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 4,
                decoration: _fieldDecoration("Descripción *"),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "La descripción es obligatoria"
                    : null,
              ),
              SizedBox(height: 16),

              // 👇 Topics con autocomplete
              Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) return _topics;
                  return _topics.where((t) =>
                      t['titulo']
                          .toString()
                          .toLowerCase()
                          .contains(value.text.toLowerCase()));
                },
                displayStringForOption: (opt) =>
                opt['titulo'] as String,
                fieldViewBuilder: (context, ctrl, node, onEdit) {
                  return TextFormField(
                    controller: ctrl,
                    focusNode: node,
                    onEditingComplete: onEdit,
                    decoration: _fieldDecoration(
                        "Buscar y seleccionar topic *"),
                    validator: (_) => _selectedTopic == null
                        ? "Debes elegir un topic"
                        : null,
                  );
                },
                onSelected: (topic) {
                  setState(() {
                    _selectedTopic = topic['pk_topic'];
                    _topicCtrl.text = topic['titulo'];
                  });
                },
              ),

              SizedBox(height: 16),
              TextFormField(
                controller: _etiquetasCtrl,
                decoration: _fieldDecoration(
                    "Etiquetas (opcional, separadas por coma)"),
              ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text(
                    "Añadir imágenes (${_selectedImages.length}/4)"),
              ),
              SizedBox(height: 8),
              Wrap(
                children: _selectedImages
                    .map((img) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(img,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover),
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel,
                          color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedImages.remove(img);
                        });
                      },
                    )
                  ],
                ))
                    .toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearPost,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  textStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Publicar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}