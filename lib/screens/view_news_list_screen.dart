import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'view_news_detail_screen.dart';

class ViewNewsListScreen extends StatefulWidget {
  final String category;

  const ViewNewsListScreen({super.key, required this.category});

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<ViewNewsListScreen> {
  final String apiKey = 'e3aab4b972ca46b3b68c3d6f191d1ea1'; 
  bool isLoading = true;
  List articles = [];
  List filteredArticles = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?category=${widget.category}&apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['articles'];
        setState(() {
          articles = data.where((article) {
            return article['title'] != null &&
                article['description'] != null &&
                article['urlToImage'] != null;
          }).toList();
          filteredArticles = articles; 
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load news. Please try again.';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  
  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredArticles = articles.where((article) {
          return article['title']
              .toLowerCase()
              .contains(query.toLowerCase()) ||
              article['description']
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        filteredArticles = articles; 
      });
    }
  }

  
  void initiateSearch() {
    showSearch(
      context: context,
      delegate: NewsSearchDelegate(filteredArticles: filteredArticles, onSearch: filterSearchResults),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.category.toUpperCase()} News'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: initiateSearch, 
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : filteredArticles.isEmpty
            ? const Center(child: Text('No news available'))
            : ListView.builder(
          itemCount: filteredArticles.length,
          itemBuilder: (context, index) {
            final article = filteredArticles[index];
            final imageUrl = article['urlToImage']; 
            final title = article['title'] ?? 'No Title';
            final description = article['description'] ?? 'No Description';

            return ListTile(
              leading: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              title: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewNewsDetailScreen(article: article),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final List filteredArticles;
  final Function(String) onSearch;

  NewsSearchDelegate({required this.filteredArticles, required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; 
          onSearch(query); 
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = filteredArticles.where((article) {
      return article['title']
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          article['description']
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final article = results[index];
        final imageUrl = article['urlToImage']; 
        final title = article['title'] ?? 'No Title';
        final description = article['description'] ?? 'No Description';

        return ListTile(
          leading: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewNewsDetailScreen(article: article),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = filteredArticles.where((article) {
      return article['title']
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          article['description']
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final article = suggestions[index];
        final imageUrl = article['urlToImage']; 
        final title = article['title'] ?? 'No Title';
        final description = article['description'] ?? 'No Description';

        return ListTile(
          leading: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewNewsDetailScreen(article: article),
              ),
            );
          },
        );
      },
    );
  }
}
