library notion;

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotionShallowPage {
  String title;
  String id;

  NotionShallowPage(this.id, this.title);
}

enum BlockType { headingOne, headingTwo, headingThree, paragraph }

Map blockTypeMap = {
  'heading_1': BlockType.headingOne,
  'heading_2': BlockType.headingTwo,
  'heading_3': BlockType.headingThree,
  'paragraph': BlockType.paragraph,
};

class NotionBlock {
  late String id;
  late BlockType blockType;
  late String content;

  NotionBlock(Map blockMap) {
    var apiType = blockMap['type'];
    if (!blockTypeMap.containsKey(apiType)) throw Error();

    blockType = blockTypeMap[blockMap['type']];
    var richText = blockMap[apiType]['rich_text'] as List<dynamic>;

    content = richText.isEmpty ? "" : richText[0]['plain_text'];
    id = blockMap['id'];
  }
}

class NotionDeepPage {
  String id;
  String title;
  List<NotionBlock> content;

  NotionDeepPage(this.id, this.title, this.content);
}

class Notion {
  static const _notionApiVersion = '2022-06-28';
  static const _notionURL = 'https://api.notion.com/v1';

  bool _initialized = false;

  final _headers = {
    'Authorization': 'Bearer ',
    'Notion-Version': _notionApiVersion,
    'Content-Type': 'application/json'
  };

  late Dio _dio;
  late String _authToken;
  late String _dbId;

  List<NotionShallowPage> shallowPages = [];

  Future<bool> init() async {
    _dio = Dio();
    try {
      await dotenv.load(fileName: '.env');
      _authToken = dotenv.get('NOTION_TOKEN');
      _dbId = dotenv.get('NOTION_DB_ID');
      _headers['Authorization'] = _headers['Authorization']! + _authToken;
    } catch (error) {
      _initialized = false;
    }
    _initialized = true;
    return _initialized;
  }

  Future<List<dynamic>> _getAllPageIds() async {
    if (!_initialized) throw Error();

    var dbPages = (await _dio.post('$_notionURL/databases/$_dbId/query',
            options: Options(headers: _headers),
            data: {
          'sorts': [
            {'timestamp': 'created_time', 'direction': 'descending'}
          ]
        }))
        .data['results'];

    var pageIds = dbPages.map((page) => page['id']).toList();
    return pageIds;
  }

  Future<String> _getPageTitle(id) async {
    if (!_initialized) throw Error();

    return (await _dio.get('$_notionURL/pages/$id/properties/title',
            options: Options(headers: _headers)))
        .data['results'][0]['title']['text']['content'];
  }

  loadShallowPages() async {
    if (!_initialized) throw Error();

    var ids = await _getAllPageIds();
    List<NotionShallowPage> shallowPages = [];
    for (var id in ids) {
      shallowPages.add(NotionShallowPage(id, await _getPageTitle(id)));
    }
    this.shallowPages = shallowPages;
  }

  Future<NotionDeepPage> getPage(NotionShallowPage shallowPage) async {
    if (!_initialized) throw Error();
    var cursor = '';
    var results = [];
    List<NotionBlock> content = [];
    Response<dynamic> pageContent;

    do {
      pageContent = (await _dio.get(
          '$_notionURL/blocks/${shallowPage.id}/children?page_size=100$cursor',
          options: Options(headers: _headers)));

      cursor = '&start_cursor=${pageContent.data['next_cursor']}';
      results.addAll(pageContent.data['results']);
    } while (pageContent.data['has_more']);
    for (var element in results) {
      content.add(NotionBlock(element));
    }
    return NotionDeepPage(shallowPage.id, shallowPage.title, content);
  }
}
