import 'dart:async';


import 'package:flutter/foundation.dart';

abstract class SolrQueryExecutor {
  void query(String solrHost, String query,
      Function(Map<String, dynamic>) onResult, Function(String) onError);

  void rawQuery(String solrHost, String query, Function(dynamic) onResult,
      Function(String) onError);
}

enum ComparisonField {
  scientificName,
  kingdom,
  phylum,
  classField,
  order,
  family,
  genus,
  species,
  country,
  stateProvince,
  locality,
  eventDate,
  recordedBy,
  catalogNumber,
  basisOfRecord,
  collectionCode,
  occurrenceStatus,
  habitat
}

extension ComparisonFieldsExtension on ComparisonField {
  String get getName {
    switch (this) {
      case ComparisonField.classField:
        return 'class';
      // ignore: no_default_cases
      default:
        return toString().split('.').last;
    }
  }
}

String buildFacetDataQuery(
    {required String solrBase,
    required String collection,
    required String q,
    required String facetField,
    required int facetLimit,
    required String sort,
    bool debug = false}) {
  return urlFormat(
      solrBase,
      '/solr/$collection/select',
      <String, String>{
        'q': q,
        'rows': '0',
        'wt': 'json',
        'facet.field': facetField,
        'facet': 'on',
        'facet.limit': facetLimit.toString(),
        'json.nl': 'map',
        'facet.sort': sort
      },
      debug);
}

String urlFormat(String base, String path, Map<String, String> params,
    [bool debug = false]) {
  final Uri uri = asUri(base, path, params, debug);
  return uri.toString();
}

Uri asUri(String base, String path, Map<String, String> params,
    [bool debug = false]) {
  Uri uri = Uri.parse(base + path);
  if (params.isNotEmpty) {
    uri = uri.replace(queryParameters: params);
  }
  uri = uri.replace(scheme: base.startsWith('https') ? 'https' : 'http');
  if (debug) {
    debugPrint('INFO: Reading url: $uri');
  }
  return uri;
}

Future<Map<String, dynamic>?> getFacetData(
    {required SolrQueryExecutor solrExec,
    required String solrHost,
    required String collection,
    required String q,
    required String facetField,
    required int facetLimit,
    required String sort}) {
  final Completer<Map<String, dynamic>?> completer =
      Completer<Map<String, dynamic>?>();
  try {
    solrExec.query(
        solrHost,
        buildFacetDataQuery(
            solrBase: 'http://localhost:8983',
            collection: collection,
            q: q,
            facetField: facetField,
            facetLimit: facetLimit,
            sort: sort), (Map<String, dynamic> result) {
      completer.complete(result);
    }, (String error) {
      debugPrint('Error: $error');
      completer.complete(null);
    });
  } catch (e) {
    debugPrint('Error: $e');
  }
  return completer.future;
}
