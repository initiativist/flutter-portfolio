import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShallowNotionPage {
  String title;
  String id;

  ShallowNotionPage(this.id, this.title);
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

  List<ShallowNotionPage> shallowPages = [];

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
    List<ShallowNotionPage> shallowPages = [];
    for (var id in ids) {
      shallowPages.add(ShallowNotionPage(id, await _getPageTitle(id)));
    }
    this.shallowPages = shallowPages;
  }
}
