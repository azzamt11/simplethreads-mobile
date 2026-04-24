import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_threads/pages/home/blocs/home_cubit.dart';
import 'package:simple_threads/models/post.dart';

class HomeScreen extends StatefulWidget {
  final int? parentPostId;
  const HomeScreen({super.key, this.parentPostId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _postController = TextEditingController();

  /// Opens a Bottom Sheet to create a new post
  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("New Thread", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
              maxLines: 4,
              autofocus: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_postController.text.isNotEmpty) {
                      context.read<HomeCubit>().createPost(_postController.text);
                      _postController.clear();
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: const Text("Post"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..fetch(parentPostId: widget.parentPostId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.parentPostId != null ? 'Replies' : 'Threads'),
          centerTitle: true,
          elevation: 0,
        ),
        // --- Added Create Post Button ---
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _showCreatePostSheet(context),
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.grey),
              ),
              loaded: (posts) => RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().fetch(),
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return _PostItem(post: posts[index]);
                  },
                ),
              ),
              error: (error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error.message ?? 'An error occurred'),
                    ElevatedButton(
                      onPressed: () => context.read<HomeCubit>().fetch(),
                      child: const Text("Retry"),
                    )
                  ],
                ),
              ),
              orElse: () => const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}

/// Extracted Post Item for better state management
class _PostItem extends StatelessWidget {
  final Post post;
  const _PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final bool isLiked = post.isLiked ?? false;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => HomeScreen(parentPostId: post.id),
      )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  post.userName ?? "Anonymous",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                // Changed to a "Menu" button
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.content ?? "", style: const TextStyle(fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.read<HomeCubit>().toggleLike(post),
                        child: Row(
                          children: [
                            Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 22, color: isLiked ? Colors.pink : Colors.grey),
                            const SizedBox(width: 6),
                            Text((post.likeCount ?? 0).toString()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => _showCommentSheet(context),
                        child: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1, 
              thickness: 0.5, 
              color: post.id != post.parentPostId || post.parentPostId == null ? Colors.grey : Colors.black
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW OPTIONS MENU ---
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (menuContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text("Edit Post"),
            onTap: () {
              Navigator.pop(menuContext);
              _showEditSheet(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Delete", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(menuContext);
              _showDeleteDialog(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- NEW EDIT SHEET ---
  void _showEditSheet(BuildContext context) {
    final TextEditingController editController = TextEditingController(text: post.content);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Thread", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: editController,
              maxLines: 4,
              autofocus: true,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(sheetContext), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeCubit>().editPost(post.id!, editController.text);
                    Navigator.pop(sheetContext);
                  },
                  child: const Text("Update"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCommentSheet(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reply to ${post.userName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: "Write a reply...",
                border: InputBorder.none,
              ),
              maxLines: 3,
              autofocus: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      // We use the same createPost logic, but pass this post's ID as the parent
                      context.read<HomeCubit>().createPost(
                        commentController.text,
                        parentPostId: post.id,
                      );
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: const Text("Reply"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Post?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeCubit>().deletePost(post.id ?? 0);
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}