import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:la_toolkit/models/isJsonSerializable.dart';

class EntityApi<T extends IsJsonSerializable> {
  final String model;

  EntityApi(this.model);

  Future<Map<String, dynamic>> create<T extends IsJsonSerializable>(
      T entity) async {
    Uri url = baseUri();
    try {
      Response response = await http.post(url,
          headers: {'Content-type': 'application/json'},
          body: utf8.encode(json.encode(entity.toJson())));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw "Failed to create entity (${response.reasonPhrase})";
      }
    } catch (e) {
      throw "Failed to create entity ($e)";
    }
  }

  Future<Map<String, dynamic>> update<T extends IsJsonSerializable>(
      T entity, String id) async {
    Uri url = baseUri(id);
    try {
      Response response = await http.patch(url,
          headers: {'Content-type': 'application/json'},
          body: utf8.encode(json.encode(entity.toJson())));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw "Failed to update entity (${response.reasonPhrase})";
      }
    } catch (e) {
      throw "Failed to update entity ($e)";
    }
  }

  Future<List<dynamic>> find(
      {String? filter,
      String? where,
      int? limit,
      int? skip,
      String? sort,
      String? select,
      String? omit,
      String populate = ""}) async {
    Map<String, dynamic> queryParam = {};
    if (filter != null) queryParam["filter"] = filter;
    if (where != null) queryParam["where"] = where;
    if (limit != null) queryParam["limit"] = limit;
    if (skip != null) queryParam["skip"] = skip;
    if (sort != null) queryParam["sort"] = sort;
    if (select != null) queryParam["select"] = select;
    if (omit != null) queryParam["omit"] = omit;
    if (populate != "") queryParam["populate"] = populate;
    Uri url = baseUri("", queryParam);
    try {
      Response response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> l = jsonDecode(response.body);
        return l;
      } else
        throw "Failed to find (${response.reasonPhrase})";
    } catch (e) {
      print(e);
      throw "Failed to find ($e)";
    }
  }

  Uri baseUri<T>([String id = "", Map<String, dynamic>? queryParameters]) =>
      Uri.http(env['BACKEND']!, "/$model${id != "" ? '/' + id : ''}",
          queryParameters);

/*
-- create
-- find
addTo
destroy
findOne
populateWhere
removeFrom
replace
-- update
*/
}
