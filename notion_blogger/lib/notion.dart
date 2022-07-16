import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Notion {
  static const notionApiVersion = '2022-06-28';
  static const headers = {};
  // this is the same all the time so...
  // it just needs to be loaded in the init function from the .env file
  Notion();

  void post() async {
    var response = await http.post(
        Uri.parse('https://ptsv2.com/t/41qj0-1657818975'),
        body: {'name': 'doodle', 'color': 'blue'});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

void main() async {
  var dio = Dio();
  await dotenv.load(fileName: '.env');
  var authToken = dotenv.get('NOTION_TOKEN');
  var dbId = dotenv.get('NOTION_DB_ID');

  var headers = {
    'Authorization': 'Bearer $authToken',
    'Notion-Version': '2022-06-28',
    'Content-Type': 'application/json'
  };

  var data = {};

  var dbPages = (await dio.post(
      'https://api.notion.com/v1/databases/$dbId/query',
      options: Options(headers: headers),
      data: data));
  var pageIds = dbPages.data['results'].map((page) => page['id']).toList();

  var page = (await dio.get('https://api.notion.com/v1/pages/${pageIds[0]}',
      options: Options(headers: headers)));

  var pageContent = (await dio.get(
      'https://api.notion.com/v1/blocks/${pageIds[0]}/children?page_size=100',
      options: Options(headers: headers)));
  print(pageContent);
}

void getPageList() async {}
