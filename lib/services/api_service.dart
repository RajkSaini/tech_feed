import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constant/constants.dart';


class ApiService {

  Future<List<Map<String, dynamic>>?> getFeeds(selectedCategory, int currentPage) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + "/" + ApiConstants.feedEndpoint + "/by-tag");
      final headers = {'Content-Type': 'application/json'};
      final jsonParams = json.encode({'tags': selectedCategory,'page': currentPage});
      var response = await http.post(url,headers: headers,
          body: jsonParams);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> content = jsonData['content'];
        return content.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      log(e.toString());
    }
  }
  Future<List<Map<String, String>>?> getCategories(emailId) async {
    if(emailId==""){
      emailId = 'all';
    }
    try {
      var url = Uri.parse(ApiConstants.baseUrl +"/"+ ApiConstants.categoriesEndpoint + '/?emailId='+emailId);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print(jsonData);
        final List<Map<String, String>> content = (jsonData as List)
            .map((item) => Map<String, String>.from(item))
            .toList();
        return content;
      }
    } catch (e) {
      log(e.toString());
    }
  }
  Future<void> updateUserCategories(emailId,categories) async {
    var url = Uri.parse(ApiConstants.baseUrl +"/"+ ApiConstants.usersEndpoint + '/categories');
    final headers = {'Content-Type': 'application/json'};
    final jsonParams = json.encode({'emailId': emailId,'categories': categories});
    http.post(url,headers: headers,
      body: jsonParams);
  }

  Future<Map<String, dynamic>> isUserExist(emailId) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + "/" + ApiConstants.usersEndpoint + '/exist?emailId='+emailId);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {};
      }
    } catch (e) {
      log(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>?> findByFeedId(id) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl +"/"+ ApiConstants.feedEndpoint + '/'+id);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data;
      }
    } catch (e) {
      log(e.toString());
    }
  }

}