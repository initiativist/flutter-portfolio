import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Page List"),
          ),
          body: const BlogList()),
    );
  }
}

class BlogList extends StatefulWidget {
  const BlogList({Key? key}) : super(key: key);

  @override
  State<BlogList> createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  final List<WordPair> _postList = generateWordPairs().take(40).toList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _postList.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(_postList[index].asCamelCase));
      },
    );
  }
}
