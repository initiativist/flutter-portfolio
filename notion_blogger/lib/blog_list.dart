library homepage;

import 'package:flutter/material.dart';
import 'package:notion_blogger/blog_post.dart';
import 'notion.dart';

class BlogList extends StatelessWidget {
  const BlogList({Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page List"),
      ),
      body: FutureBuilder(
          future: Notion().loadShallowPages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var pages = snapshot.data as List<ShallowPage>;
              return ListView.separated(
                itemCount: pages.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(pages[i].title),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return BlogPost(shallowPage: pages[i]);
                    },
                  )),
                ),
                separatorBuilder: (context, i) => const Divider(),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
