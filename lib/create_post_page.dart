import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'providers/post_creation_provider.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Provider.of<PostCreationProvider>(context, listen: false).reset();
  }

  // Метод вибору фото спеціально для Web
  void _pickImage() async {
    final provider = Provider.of<PostCreationProvider>(context, listen: false);

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Читаємо байти прямо з XFile (працює на всіх платформах, особливо на Web)
      final bytes = await image.readAsBytes();
      provider.setSelectedPhoto(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostCreationProvider>();
    final isLoading = provider.status == PostCreationStatus.loading;

    // Слідкуємо за успіхом публікації
    if (provider.status == PostCreationStatus.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пост опубліковано!')));
        Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Створити пост')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'Що нового?', border: OutlineInputBorder()),
                maxLength: 500, // Вимога ЛР
                validator: (v) => (v == null || v.isEmpty) ? 'Введіть текст' : null,
              ),
              const SizedBox(height: 20),

              // Попередній перегляд картинки через байти
              if (provider.selectedPhotoBytes != null)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        provider.selectedPhotoBytes!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    TextButton(onPressed: () => provider.setSelectedPhoto(null), child: const Text('Видалити фото')),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Додати фото'),
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    provider.createPost(text: _textController.text);
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: isLoading ? const CircularProgressIndicator() : const Text('Опублікувати'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}