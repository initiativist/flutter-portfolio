import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShallowNotionPage {
  String title;
  String id;

  ShallowNotionPage(this.id, this.title);
}

class Notion {
  static const notionApiVersion = '2022-06-28';
  static const notionURL = 'https://api.notion.com/v1';

  bool initialized = false;

  var headers = {
    'Authorization': 'Bearer ',
    'Notion-Version': notionApiVersion,
    'Content-Type': 'application/json'
  };

  late Dio dio;
  late String authToken;
  late String dbId;

  late List<ShallowNotionPage> shallowPages;

  Future<bool> init() async {
    dio = Dio();
    try {
      await dotenv.load(fileName: '.env');
      authToken = dotenv.get('NOTION_TOKEN');
      dbId = dotenv.get('NOTION_DB_ID');
      headers['Authorization'] = headers['Authorization']! + authToken;
    } catch (error) {
      initialized = false;
    }
    initialized = true;
    return initialized;
  }

  Future<List<dynamic>> _getAllPageIds() async {
    if (!initialized) throw Error();

    var dbPages = (await dio.post('$notionURL/databases/$dbId/query',
            options: Options(headers: headers),
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
    if (!initialized) throw Error();

    return (await dio.get('$notionURL/pages/$id/properties/title',
            options: Options(headers: headers)))
        .data['results'][0]['title']['text']['content'];
  }

  loadShallowPages() async {
    if (!initialized) throw Error();

    var ids = await _getAllPageIds();
    List<ShallowNotionPage> shallowPages = [];
    for (var id in ids) {
      shallowPages.add(ShallowNotionPage(id, await _getPageTitle(id)));
    }
    this.shallowPages = shallowPages;
  }
}
