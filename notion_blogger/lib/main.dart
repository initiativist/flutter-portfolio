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

  @override
  void initState() {
    _initNotion();
    super.initState();
  }

  void _initNotion() async {
    myNotion = Notion();
    await myNotion.init();
    await myNotion.loadShallowPages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (myNotion.shallowPages.isNotEmpty) {
          return ListView.builder(
              itemCount: myNotion.shallowPages.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(myNotion.shallowPages[index].title));
              });
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
