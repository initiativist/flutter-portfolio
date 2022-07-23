import 'package:flutter/material.dart';
import 'notion.dart';

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
  late Notion myNotion;
  late List<NotionShallowPage> pages = [];

  @override
  void initState() {
    _initNotion();
    super.initState();
  }

  void _initNotion() async {
    myNotion = Notion();
    await myNotion.init();
    await myNotion.loadShallowPages();
    setState(() {
      pages = myNotion.shallowPages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (pages.isNotEmpty) {
          return ListView.separated(
            itemCount: pages.length,
            itemBuilder: (context, i) => ListTile(title: Text(pages[i].title)),
            separatorBuilder: (context, i) => const Divider(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
