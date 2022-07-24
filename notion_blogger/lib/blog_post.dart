import 'package:flutter/material.dart';
import 'package:notion_blogger/notion.dart';

class BlogPost extends StatelessWidget {
  static const routeName = '/post';

  const BlogPost({Key? key, required this.shallowPage}) : super(key: key);
  final ShallowPage shallowPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shallowPage.title),
      ),
      body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return PostBuilder(page: snapshot.data as DeepPage);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          future: Notion().getPage(shallowPage)),
    );
  }
}

class PostBuilder extends StatelessWidget {
  final DeepPage page;
  const PostBuilder({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: page.content.length,
        itemBuilder: (context, i) {
          var block = page.content[i];
          switch (page.content[i].blockType) {
            case BlockType.headingOne:
              return Text(block.content,
                  style: Theme.of(context).textTheme.headline4);
            case BlockType.headingTwo:
              return Text(block.content,
                  style: Theme.of(context).textTheme.headline5);
            case BlockType.headingThree:
              return Text(block.content,
                  style: Theme.of(context).textTheme.headline6);
            case BlockType.paragraph:
              return Text(block.content);
          }
        },
      ),
    );
  }
}
