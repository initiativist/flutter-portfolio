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
    Map blockStyle = {
      BlockType.headingOne: Theme.of(context).textTheme.headline4,
      BlockType.headingTwo: Theme.of(context).textTheme.headline5,
      BlockType.headingThree: Theme.of(context).textTheme.headline6,
      BlockType.paragraph: Theme.of(context).textTheme.bodyLarge,
    };
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: page.content.length,
        itemBuilder: (context, i) {
          var block = page.content[i];
          return Text(block.content, style: blockStyle[block.blockType]);
        },
      ),
    );
  }
}
