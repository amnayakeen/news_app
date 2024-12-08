import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/web_view_screen.dart'; 

class ViewNewsDetailScreen extends StatefulWidget {
  final Map article;

  const ViewNewsDetailScreen({super.key, required this.article});

  @override
  _ViewNewsDetailScreenState createState() => _ViewNewsDetailScreenState();
}

class _ViewNewsDetailScreenState extends State<ViewNewsDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, String>> _comments = [];
  String _currentUser = '';
  late String articleId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    articleId = widget.article['title'] ?? '';
    _loadComments();
  }

  Future<void> _fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = prefs.getString('loggedInUser') ?? 'Anonymous';
    });
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedComments = prefs.getString(articleId);
    if (savedComments != null) {
      
      List<dynamic> decodedComments = json.decode(savedComments);
      setState(() {
        _comments = List<Map<String, String>>.from(decodedComments.map((comment) => {
          'user': comment['user'],
          'comment': comment['comment'],
        }));
      });
    }
  }

  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedComments = json.encode(_comments);
    prefs.setString(articleId, encodedComments);
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add({
          'user': _currentUser,
          'comment': _commentController.text,
        });
        _saveComments();
        _commentController.clear();
      });
    }
  }


  void _editComment(int index) {
    _commentController.text = _comments[index]['comment'] ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: _commentController,
          decoration: const InputDecoration(hintText: 'Edit your comment'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _comments[index]['comment'] = _commentController.text;
                _saveComments();
              });
              _commentController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  void _deleteComment(int index) {
    setState(() {
      _comments.removeAt(index);
      _saveComments();
    });
  }

  // navigate to WebViewScreen for full article
  void _navigateToWebView(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.article['urlToImage'];
    final title = widget.article['title'] ?? 'No Title';
    final content = widget.article['content'] ?? 'Full content is not available.';
    final description = widget.article['description'] ?? 'Description not available.';
    final publishedAt = widget.article['publishedAt'] ?? 'Unknown';
    final articleUrl = widget.article['url'] ?? '';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageUrl != null
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey,
                  child: const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Published At: $publishedAt',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                articleUrl.isNotEmpty
                    ? ElevatedButton(
                  onPressed: () {
                    _navigateToWebView(context, articleUrl, title);
                  },
                  child: const Text('Read Full Article'),
                )
                    : Container(),
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Add a comment...',
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('Post Comment'),
                  ),
                ),
                const Divider(),
                ListView.builder(
                  itemCount: _comments.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(comment['user'] ?? 'Anonymous'),
                        subtitle: Text(comment['comment'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editComment(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteComment(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
