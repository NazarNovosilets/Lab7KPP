import 'package:flutter/material.dart';
import 'models/post_model.dart';
import 'package:provider/provider.dart';
import 'providers/post_provider.dart';

class PostDetailsPage extends StatelessWidget {
  final Post post;

  const PostDetailsPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final updatedPost = provider.posts.firstWhere((p) => p == post);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Деталі поста"),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Автор
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage("img/user_avatar.png"),
              ),
              title: Text(updatedPost.username),
            ),

            // Текст
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                updatedPost.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            // Фото
            if (updatedPost.images.isNotEmpty)
              Column(
                children: updatedPost.images.map((img) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Image.asset(img),
                  );
                }).toList(),
              ),

            // Лайки та коментарі
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => provider.togglePostLike(updatedPost),
                    child: Row(
                      children: [
                        Icon(
                          updatedPost.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                          updatedPost.isLiked ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text("${updatedPost.likes}"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  Icon(Icons.comment_outlined, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("${updatedPost.comments}"),
                ],
              ),
            ),

            const Divider(),

            // Імітація блоку коментарів
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Коментарі",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade200,
              ),
              title: Text("Іван Петренко"),
              subtitle: Text("Гарні фото!"),
              trailing: Text("2 год тому"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
