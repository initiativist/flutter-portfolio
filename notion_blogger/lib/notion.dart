import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
  await dotenv.load(fileName: '.env');
  var auth_token = dotenv.get('notion_token');
  var db_id = dotenv.get('notion_db_id');

  var url = Uri.https('api.notion.com', '/v1/databases/$db_id/query');

  var headers = {
    'Authorization': 'Bearer $auth_token',
    'Notion-Version': '2022-06-28',
    'Content-Type': 'application/json'
  };

  var data = {};

  var response =
      await http.post(url, headers: headers, body: json.encode(data));

  var page_list =
      json.decode(response.body)['results'].map((page) => page['id']).toList();

  print(page_list);
}

void getPageList() async {}

void templateRequest({required String url}) async {
  await dotenv.load(fileName: '.env');
  var auth_token = dotenv.get('notion_token');
  var db_id = dotenv.get('notion_db_id');

  var url = Uri.https('api.notion.com', '/v1/pages');

  var headers = {
    'Authorization': 'Bearer $auth_token',
    'Notion-Version': '2022-06-28',
    'Content-Type': 'application/json'
  };

  var data = {};

  var response = await http.post(url, headers: headers, body: jsonEncode(data));
}
