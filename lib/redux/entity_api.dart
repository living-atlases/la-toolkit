import 'dart:convert';
import 'dart:developer';


import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/http.dart'
import 'package:tuple/tuple.dart';


import '../models/isJsonSerializable.dart';
import '../utils/utils.dart';

class EntityApi<T extends IsJsonSerializable<T>> {
  EntityApi(this.model);

  final String model;

  Future<Map<String, dynamic>> create(T entity) async {
    final Uri url = baseUri();
    try {
      final Response response = await http.post(url,
          headers: <String, String>{'Content-type': 'application/json'},
          body: utf8.encode(json.encode(entity.toJson())));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create entity (${response.reasonPhrase})');
      }
    } catch (e) {
      throw Exception('Failed to create entity ($e)');
    }
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> toUpdate) async {
    final Uri url = baseUri(id);
    try {
      final Response response = await http.patch(url,
          headers: <String, String>{'Content-type': 'application/json'},
          body: utf8.encode(json.encode(toUpdate)));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update entity (${response.reasonPhrase})');
      }
    } catch (e) {
      throw Exception('Failed to update entity ($e)');
    }
  }

  Future<List<dynamic>> find(
      {Tuple2<String, String>? filter,
      String? where,
      int? limit,
      int? skip,
      String? sort,
      String? select,
      String? omit,
      String populate = ''}) async {
    final Map<String, String> queryParam = <String, String>{};
    if (filter != null) {
      queryParam[filter.item1] = filter.item2;
    }
    if (where != null) {
      queryParam['where'] = where;
    }
    if (limit != null) {
      queryParam['limit'] = limit.toString();
    }
    if (skip != null) {
      queryParam['skip'] = skip.toString();
    }
    if (sort != null) {
      queryParam['sort'] = sort;
    }
    if (select != null) {
      queryParam['select'] = select;
    }
    if (omit != null) {
      queryParam['omit'] = omit;
    }
    if (populate != '') {
      queryParam['populate'] = populate;
    }
    final Uri url = baseUri('', queryParam);
    try {
      final Response response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> l = jsonDecode(response.body) as List<dynamic>;
        return l;
      } else {
        throw Exception('Failed to find (${response.reasonPhrase})');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to find ($e)');
    }
  }

  Future<Map<String, dynamic>> addTo(
      {required String id,
      required String association,
      required String fk}) async {
    // employee/7/involvedInPurchases/47
    final String path = '$id/$association/$fk';
    final Uri url = baseUri(path);
    try {
      final Response response = await http.put(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to associate entity (${response.reasonPhrase})');
      }
    } catch (e) {
      throw Exception('Failed to associate entity ($e)');
    }
  }

  Future<Map<String, dynamic>> delete({required String id}) async {
    // DELETE /:model/:id
    final String path = id;
    final Uri url = baseUri(path);
    try {
      final Response response = await http.delete(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to delete entity (${response.reasonPhrase})');
      }
    } catch (e) {
      throw Exception('Failed to delete entity ($e)');
    }
  }

  Uri baseUri([String path = '', Map<String, String>? queryParameters]) =>
      AppUtils.uri(dotenv.env['BACKEND']!,
          "/$model${path != "" ? '/$path' : ''}", queryParameters);

/*
-- create
-- find
-- addTo
-- destroy
-- update
findOne
populateWhere
removeFrom
replace
*/
}
