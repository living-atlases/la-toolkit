import 'dart:convert' as convert;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/app_snack_bar.dart';
import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/LAServiceConstants.dart';
import 'models/appState.dart';
import 'models/la_project.dart';
import 'redux/actions.dart';

class CompareDataPage extends StatefulWidget {
  const CompareDataPage({super.key});

  static const String routeName = 'compare-data';

  @override
  State<CompareDataPage> createState() => _CompareDataPageState();
}

class _CompareDataPageState extends State<CompareDataPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool firstPoint = true;
  int _tab = 0;
  static const int recordsNumber = 5;
  late LAProject _p;
  late bool _withPipeline;
  late String _solrHost;
  late String _collectoryHost;
  static const String gbifDatasetId = 'gbifDatasetId';
  final Map<String, dynamic> recordsWithDifferences = <String, dynamic>{};
  Map<String, String>? errorMessages;
  Map<String, Map<String, int>> statistics = <String, Map<String, int>>{};
  late String _alaHubUrl;

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

  String getFacetData(
      {required String solrBase,
      required String collection,
      required String q,
      required String facetField,
      required int faceLimit,
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
          'facet.limit': faceLimit.toString(),
          'json.nl': 'map',
          'facet.sort': sort
        },
        debug);
  }

  String getQueryData(
      {required String solrBase,
      required String collection,
      required String q,
      bool debug = false}) {
    return urlFormat(
        solrBase, '/solr/$collection/select', <String, String>{'q': q}, debug);
  }

  String urlFormat(String base, String path, Map<String, String> params,
      [bool debug = false]) {
    final Uri uri = asUri(base, path, params, debug);
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CompareDataViewModel>(
        converter: (Store<AppState> store) {
      return _CompareDataViewModel(
        state: store.state,
        doSolrQuery: (String query, Function(Map<String, dynamic>) onResult) {
          store.dispatch(SolrQuery(
              project: _p.id,
              solrHost: _solrHost,
              query: query,
              onResult: onResult));
        },
        doMySqlQuery: (String query, Function(Map<String, dynamic>) onResult) {
          store.dispatch(MySqlQuery(
              project: _p.id,
              mySqlHost: _collectoryHost,
              db: 'collectory',
              query: query,
              onResult: onResult));
        },
      );
    }, builder: (BuildContext context, _CompareDataViewModel vm) {
      _p = vm.state.currentProject;
      _withPipeline = _p.isPipelinesInUse;
      _solrHost = _p
          .getServerById(_p
              .getServiceDeploysForSomeService(
                  _withPipeline ? solrcloud : solr)[0]
              .serverId!)!
          .name;
      _collectoryHost = _p
          .getServerById(
              _p.getServiceDeploysForSomeService(collectory)[0].serverId!)!
          .name;
      final Map<String, dynamic> services =
          _p.getServiceDetailsForVersionCheck();
      _alaHubUrl = (services[alaHub] as Map<String, dynamic>)['url'] as String;
      final List<DropdownMenuItem<String>> releases =
          <DropdownMenuItem<String>>[];
      for (final String element in vm.state.alaInstallReleases) {
        // ignore: always_specify_types
        releases.add(DropdownMenuItem(value: element, child: Text(element)));
      }

      return Scaffold(
          key: _scaffoldKey,
          // backgroundColor: Colors.white,

          appBar: LAAppBar(
            context: context,
            title: 'Compare Data',
            titleIcon: Icons.compare,
            showBack: true,
            actions: const <Widget>[],
          ),
          bottomNavigationBar: ConvexAppBar(
            backgroundColor: LAColorTheme.laPalette.shade300,
            color: Colors.black,
            activeColor: Colors.black,

            style: TabStyle.react,
            items: const <TabItem<dynamic>>[
              TabItem<dynamic>(
                  icon: Icons.image_search_outlined,
                  title: 'Compare with GBIF'),
              TabItem<dynamic>(
                  icon: Icons.compare_arrows,
                  title: 'Solr indexes comparative'),
            ],
            initialActiveIndex: 0,
            //optional, default as 0
            onTap: (int i) => setState(() => _tab = i),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: AppSnackBar(ScrollPanel(
              withPadding: true,
              padding: 40,
              child: Row(children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                    flex: 10, // 80%,
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (_tab == 0) const SizedBox(height: 20),
                        if (_tab == 0)
                          const Text(
                              'This tool compares taxonomic data between records from your LA Portal and their equivalent records published in GBIF. The comparison focuses on several key fields such as kingdom, phylum, class, order, family, genus, species, and scientific name. Additionally, it considers other fields like country, etc'),
                        const SizedBox(height: 10),
                        if (_tab == 0)
                          LaunchBtn(
                            icon: Icons.settings,
                            execBtn: 'Run',
                            onTap: () async {
                              final Map<String, dynamic> results =
                                  await _compareWithGBIF(vm);
                              setState(() {
                                statistics = results['statistics']
                                    as Map<String, Map<String, int>>;
                                errorMessages = results['errorMessages']
                                    as Map<String, String>;
                              });
                            },
                          ),
                        if (_tab == 0 && errorMessages != null)
                          Container(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: errorMessages!.entries
                                    .map((MapEntry<String, String> entry) {
                                  return ListTile(
                                      leading: GestureDetector(
                                          onTap: () => FlutterClipboard.copy(
                                                  entry.key)
                                              .then((dynamic value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                    'Copied to clipboard',
                                                    style: TextStyle(
                                                        fontFamily: 'Courier',
                                                        fontSize: 14),
                                                  )))),
                                          child: Text(entry.key)),
                                      title: Flexible(
                                          // height: 40,
                                          child: MarkdownBody(
                                        data: entry.value,
                                        onTapLink: (String text, String? url,
                                            String title) {
                                          launchUrl(Uri.parse(url!));
                                        },
                                      )));
                                }).toList(),
                              )),
                        if (_tab == 0 &&
                            errorMessages != null &&
                            errorMessages!.isEmpty)
                          const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('No differences found')),
                        if (_tab == 0 &&
                            errorMessages != null &&
                            errorMessages!.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              if (errorMessages != null) {
                                _generatePdf(errorMessages!);
                              }
                            },
                            child: const Text('Generate PDF'),
                          ),
                      ],
                    ))),
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
              ]))));
    });
  }

  // static const String gbifBaseUrl = 'https://api.gbif-uat.org/v1';

  static const String gbifBaseUrl = 'https://api.gbif.org/v1';

  Future<Map<String, dynamic>> _compareWithGBIF(_CompareDataViewModel vm,
      [bool debug = false]) async {
    final Map<String, dynamic> laRecords = await getRandomLARecords(vm);

    final Map<String, dynamic> recordsGBIFIds = <String, dynamic>{};

    for (final Map<String, dynamic> record
        in laRecords.values.cast<Map<String, dynamic>>()) {
      final String? occId = record['occurrenceID'] as String?;
      final String id = record['id'] as String;
      if (occId == null) {
        debugPrint('Error: no occurrenceID found for record $id');
        continue;
      }
      final String occIDEnc = Uri.encodeComponent(occId);

      final String queryParams =
          'occurrenceId=$occIDEnc&datasetKey=${record[gbifDatasetId]}';
      final Uri gbifRecordUri =
          Uri.parse('$gbifBaseUrl/occurrence/search?$queryParams');
      if (debug) {
        debugPrint(gbifRecordUri.toString());
      }
      final Response response = await http.get(gbifRecordUri);
      if (response.statusCode == 200) {
        if (debug) {
          debugPrint(response.body);
        }
        final String body = convert.utf8.decode(response.bodyBytes);
        final Map<String, dynamic> result =
            jsonDecode(body) as Map<String, dynamic>;
        if (result['count'] == 1) {
          recordsGBIFIds[id] = (result['results'] as List<dynamic>)[0];
          // debugPrint('ALA record via its API: ');
          if (debug) {
            debugPrint(record.toString());
          }
          // debugPrint('GBIF record via its API: ');
          if (debug) {
            debugPrint((result['results'] as List<dynamic>)[0].toString());
          }
        } else {
          debugPrint(
              'Record not found with occurrenceId: $occId and datasetKey: ${record[gbifDatasetId]} and occurrenceId: $occIDEnc');
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    }
    final Map<String, dynamic> results =
        generateStatistics(laRecords, recordsGBIFIds);
    debugPrint('Results: $results');
    debugPrint(
        'Number of LA records: ${laRecords.length}, number of GBIF records found fot these records: ${recordsGBIFIds.length}');
    return results;
  }

  Future<Map<String, dynamic>> getDrs(_CompareDataViewModel vm) {
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();
    try {
      vm.doSolrQuery(
          getFacetData(
              solrBase: 'http://localhost:8983',
              collection: 'biocache',
              q: 'dataResourceUid:*',
              facetField:
                  _withPipeline ? 'dataResourceUid' : 'data_resource_uid',
              faceLimit: -1,
              sort: 'index'), (Map<String, dynamic> result) {
        // ignore: avoid_dynamic_calls
        completer.complete(
            // ignore: avoid_dynamic_calls
            result['facet_counts']['facet_fields']['dataResourceUid']
                as Map<String, dynamic>);
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
    return completer.future;
  }

  Future<Map<String, dynamic>> getCollectoryDrs(_CompareDataViewModel vm) {
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();
    try {
      vm.doMySqlQuery(
          'SELECT JSON_OBJECTAGG(dr.uid, dr.gbif_registry_key) AS result_json FROM data_resource dr;',
          (Map<String, dynamic> result) {
        completer.complete(result);
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
    return completer.future;
  }

  Future<Map<String, dynamic>> getRandomLARecords(
      _CompareDataViewModel vm) async {
    final Map<String, dynamic> dataResources = await getDrs(vm);
    final Map<String, dynamic> drs = await getCollectoryDrs(vm);

    final Map<String, dynamic> records = <String, dynamic>{};

    for (int i = 0; i < recordsNumber; i++) {
      final int drOffset = Random().nextInt(dataResources.length);
      final MapEntry<String, dynamic> dataResource =
          dataResources.entries.toList()[drOffset];
      final int recordOffset =
          Random().nextInt(min(20000, dataResource.value as int));

      final Completer<void> completer = Completer<void>();

      vm.doSolrQuery(
          Uri.parse(
                  'http://localhost:8983/solr/biocache/select?q=dataResourceUid:${dataResource.key}&rows=1&wt=json&start=$recordOffset&facet=false')
              .toString(), (Map<String, dynamic> result) {
        final Map<String, dynamic> occ =
            ((result['response'] as Map<String, dynamic>)['docs']
                as List<dynamic>)[0] as Map<String, dynamic>;

        final String? id = occ['id'] as String?;
        final String? gbifDrId = drs[dataResource.key] as String?;

        // SKIP DRS with null gbif_registry_key
        if (id != null && gbifDrId != null) {
          occ[gbifDatasetId] = gbifDrId;
          records[id] = occ;
        }
        completer.complete();
      });

      await completer.future;
    }

    return records;
  }

  Map<String, dynamic> generateStatistics(
      Map<String, dynamic> recordsLA, Map<String, dynamic> recordsGBIF) {
    final List<String> comparisonFields = <String>[
      'kingdom',
      'phylum',
      'class',
      'order',
      'family',
      'genus',
      'species',
      'scientificName',
      'country',
      'stateProvince',
      'locality',
      'eventDate',
      'recordedBy',
      'catalogNumber',
      'basisOfRecord',
      'collectionCode',
      'occurrenceStatus',
      'habitat'
    ];

    final Map<String, Map<String, int>> stats = <String, Map<String, int>>{
      'matches': <String, int>{},
      'mismatches': <String, int>{},
      'nulls': <String, int>{}
    };

    final Map<String, String> errorMessages = <String, String>{};

    for (final String field in comparisonFields) {
      stats['matches']![field] = 0;
      stats['mismatches']![field] = 0;
      stats['nulls']![field] = 0;
    }

    for (final String id in recordsLA.keys) {
      final Map<String, dynamic>? recordLA =
          recordsLA[id] as Map<String, dynamic>?;
      final Map<String, dynamic>? recordGBIF =
          recordsGBIF[id] as Map<String, dynamic>?;

      if (recordLA == null || recordGBIF == null) {
        continue;
      }

      final List<String> errors = <String>[];

      for (final String field in comparisonFields) {
        if (field == 'scientificName') {
          final String? scientificNameLA =
              recordLA['scientificName'] as String?;
          final String? authorshipLA =
              recordLA['scientificNameAuthorship'] as String?;
          final String? rawScientificNameLA =
              recordLA['raw_scientificName'] as String?;
          final String? rawAuthorshipLA =
              recordLA['raw_scientificNameAuthorship'] as String?;

          String? fullScientificNameLA;
          if (scientificNameLA != null) {
            fullScientificNameLA = authorshipLA != null
                ? '$scientificNameLA $authorshipLA'
                : scientificNameLA;
          }
          String? fullRawScientificNameLA;
          if (rawScientificNameLA != null) {
            fullRawScientificNameLA = rawAuthorshipLA != null
                ? '$rawScientificNameLA $rawAuthorshipLA'
                : rawScientificNameLA;
          }
          final String? scientificNameGBIF =
              recordGBIF['scientificName'] as String?;

          if (fullScientificNameLA == null || scientificNameGBIF == null) {
            stats['nulls']!['scientificName'] =
                stats['nulls']!['scientificName']! + 1;
          } else if (fullScientificNameLA == scientificNameGBIF) {
            stats['matches']!['scientificName'] =
                stats['matches']!['scientificName']! + 1;
          } else {
            stats['mismatches']!['scientificName'] =
                stats['mismatches']!['scientificName']! + 1;
            errors.add(
                "1. **Scientific name** differs: [$fullScientificNameLA]($_alaHubUrl/occurrences/$id) (raw: '$fullRawScientificNameLA') vs [$scientificNameGBIF](https://gbif.org/occurrence/${recordGBIF['key']})");
          }
        } else {
          final String? value1 = recordLA[field] as String?;
          final String? value2 = recordGBIF[field] as String?;

          if (value1 == null || value2 == null) {
            stats['nulls']![field] = stats['nulls']![field]! + 1;
          } else if (value1 == value2) {
            stats['matches']![field] = stats['matches']![field]! + 1;
          } else {
            stats['mismatches']![field] = stats['mismatches']![field]! + 1;
            errors.add(
                '1. _${StringUtils.capitalize(field)}_ differs: [$value1]($_alaHubUrl/occurrences/$id) vs [$value2](https://gbif.org/occurrence/${recordGBIF['key']})');
          }
        }
      }

      if (errors.isNotEmpty) {
        errorMessages[id] = errors.join('  \n');
      }
    }

    return <String, dynamic>{
      'statistics': stats,
      'errorMessages': errorMessages
    };
  }

  Future<void> _generatePdf(Map<String, String> errorMessages) async {
    final pw.Document pdf = pw.Document();

//    final String markdownContent = generateMarkdown(errorMessages);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          const String htmlContent =
              '<h1>Test</h1>'; // md.markdownToHtml(markdownContent);
          final HtmlWidget htmlWidget = const HtmlWidget(htmlContent);

          return pw.Center(
            // child: pw.Text(htmlWidget.toString()),
            child: pw.Text(htmlContent),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

class _CompareDataViewModel {
  _CompareDataViewModel(
      {required this.state,
      required this.doSolrQuery,
      required this.doMySqlQuery});

  final AppState state;
  final void Function(String query, Function(Map<String, dynamic>) onResult)
      doSolrQuery;
  final void Function(String query, Function(Map<String, dynamic>) onResult)
      doMySqlQuery;
}
