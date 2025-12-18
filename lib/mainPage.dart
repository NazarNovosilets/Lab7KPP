import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/post_provider.dart';
import 'models/post_model.dart';
import 'post_details_page.dart';
import 'create_post_page.dart';

class mainPage extends StatelessWidget {
  const mainPage({super.key});

  // Функція виходу (Завдання 3 ЛР №6)
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4C8CFF);
    const Color iconColor = Color(0xFF666666);
    const Color dividerColor = Color(0xFFE0E0E0);

    // Отримуємо поточного користувача для відображення в AppBar
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: const Text(
          'MiniBlog',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              debugPrint('Перехід на сторінку профілю');
            },
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('img/user_avatar.png'),
                  backgroundColor: Color(0xFFD3D3D3),
                  child: Icon(Icons.person, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Користувач',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      currentUser?.email ?? 'nazar@gmail.com',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: iconColor, size: 24),
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 20),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: dividerColor, height: 1.0),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Consumer<PostProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => provider.loadPostsWithError(),
                        child: const Text("Спробувати ще раз"),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                itemCount: provider.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCreatePostButton(context);
                  }

                  final post = provider.posts[index - 1];
                  // Логіка для відображення коментаря тільки у першого поста (як у вашому дизайні)
                  bool isFirstPost = index == 1;

                  return Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: PostCard(
                      post: post,
                      hasCommentBox: isFirstPost,
                      firstCommenter: isFirstPost ? 'Іван Петренко' : null,
                      firstCommentText: isFirstPost ? 'Чудові фото! Де це?' : null,
                      firstCommentTime: isFirstPost ? '2 год тому' : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CreatePostPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF666666), size: 20),
            SizedBox(width: 10),
            Text(
              'Створити новий пост',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final bool hasCommentBox;
  final String? firstCommenter;
  final String? firstCommentText;
  final String? firstCommentTime;

  const PostCard({
    super.key,
    required this.post,
    this.hasCommentBox = false,
    this.firstCommenter,
    this.firstCommentText,
    this.firstCommentTime,
  });

  // Діалог редагування (Завдання 5 ЛР №6)
  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: post.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Редагувати пост"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Відміна")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<PostProvider>().editPost(post, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Зберегти"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color lightIconColor = Color(0xFF999999);
    const Color likedColor = Colors.red;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isAuthor = post.authorId == currentUserId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1, blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('img/user_avatar.png'),
                ),
                const SizedBox(width: 10),
                Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                // Кнопка редагування тільки для автора
                if (isAuthor)
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
                    onPressed: () => _showEditDialog(context),
                  ),
                const Icon(Icons.more_horiz, color: lightIconColor),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(post.text),
          ),
          const SizedBox(height: 10),

          // Метод відображення картинок (Web/Storage сумісний)
          if (post.images.isNotEmpty) _buildPostImages(post.images),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.read<PostProvider>().togglePostLike(post),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? likedColor : lightIconColor,
                      ),
                      const SizedBox(width: 5),
                      Text('${post.likes}', style: TextStyle(color: post.isLiked ? likedColor : lightIconColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 25),
                const Icon(Icons.comment_outlined, color: lightIconColor),
                const SizedBox(width: 5),
                Text('${post.comments}', style: const TextStyle(color: lightIconColor)),
                const Spacer(),
                const Icon(Icons.bookmark_border, color: lightIconColor),
              ],
            ),
          ),
          if (hasCommentBox && firstCommenter != null) ...[
            _buildFirstComment(firstCommenter!, firstCommentText!, firstCommentTime!),
            _buildCommentBox(),
          ]
        ],
      ),
    );
  }

  Widget _buildPostImages(List<String> imageUrls) {
    final String url = imageUrls.first;
    final bool isNetwork = url.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: isNetwork
            ? Image.network(
          url, height: 300, width: double.infinity, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200, color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        )
            : Image.asset(url, height: 300, width: double.infinity, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildFirstComment(String commenter, String text, String time) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(6.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Color(0xFFD3D3D3)),
              const SizedBox(width: 8),
              Text(commenter, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 5),
          Padding(padding: const EdgeInsets.only(left: 32.0), child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildCommentBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundImage: AssetImage('img/user_avatar.png'), backgroundColor: Color(0xFFD3D3D3)),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(20)),
              child: const Text('Напишіть коментар...', style: TextStyle(color: Color(0xFF999999))),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.send, color: Color(0xFF4C8CFF)),
        ],
      ),
    );
  }
}