import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:collection/collection.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:redux/redux.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import 'components/app_snack_bar.dart';
import 'components/compare_data_timeline.dart';
import 'components/compare_gbif_charts.dart';
import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/LAServiceConstants.dart';
import 'models/appState.dart';
import 'models/laServer.dart';
import 'models/laServiceDeploy.dart';
import 'models/la_project.dart';
import 'redux/actions.dart';
import 'utils/StringUtils.dart';
import 'utils/query_utils.dart';

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
  static const int recordsNumber = 100;
  late LAProject _p;
  late bool _withPipeline;
  String? solrHost1;
  String? solrHost2;
  String? coreOrCollection1;
  String? coreOrCollection2;
  late String collectoryHost;
  static const String gbifDatasetId = 'gbifDatasetId';
  final Map<String, dynamic> recordsWithDifferences = <String, dynamic>{};
  Map<String, String>? errorMessages;
  Map<String, Map<String, int>>? statistics;
  late String _alaHubUrl;
  bool _launchEnabled = false;
  List<String> _coreOrCollections = <String>[];
  bool compareDrs = true;
  bool compareSpecies = true;
  bool truncateSpecies = true;
  bool compareLayers = true;
  bool compareHubs = true;

  CompareWithGbifDataPhase _currentPhaseTab0 =
      CompareWithGbifDataPhase.getSolrHosts;
  CompareSolrIndexesPhase _currentPhaseTab1 =
      CompareSolrIndexesPhase.getSolrHosts;
  bool _somethingFailed = false;

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

  String getQueryData(
      {required String solrBase,
      required String collection,
      required String q,
      bool debug = false}) {
    return urlFormat(
        solrBase, '/solr/$collection/select', <String, String>{'q': q}, debug);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CompareDataViewModel>(
        converter: (Store<AppState> store) {
      return _CompareDataViewModel(
        state: store.state,
        doSolrQuery: (String query, Function(Map<String, dynamic>) onResult,
            Function(String) onError) {
          store.dispatch(SolrQuery(
              project: _p.id,
              solrHost: solrHost1!,
              query: query,
              onError: onError,
              onResult: onResult));
        },
        doMySqlQuery: (String query, Function(Map<String, dynamic>) onResult,
            Function(String) onError) {
          store.dispatch(MySqlQuery(
              project: _p.id,
              mySqlHost: collectoryHost,
              db: 'collectory',
              query: query,
              onError: onError,
              onResult: onResult));
        },
      );
    }, builder: (BuildContext context, _CompareDataViewModel vm) {
      _p = vm.state.currentProject;
      _withPipeline = _p.isPipelinesInUse;
      collectoryHost = _p
          .getServerById(
              _p.getServiceDeploysForSomeService(collectory)[0].serverId!)!
          .name;
      final Map<String, dynamic> services =
          _p.getServiceDetailsForVersionCheck();
      _alaHubUrl = (services[alaHub] as Map<String, dynamic>)['url'] as String;

      final List<String> solrHosts = <String>[];
      for (final String service in <String>[solr, solrcloud]) {
        _p
            .getServiceDeploysForSomeService(service)
            .forEach((LAServiceDeploy sd) {
          if (sd.serverId == null) {
            // TODO docker cluster
          } else {
            final LAServer? server = _p.getServerById(sd.serverId!);
            solrHosts.add(server!.name);
          }
        });
      }

      final List<DropdownMenuItem<String>> solrHostsMenuItems =
          <DropdownMenuItem<String>>[];
      for (final String element in solrHosts) {
        // ignore: always_specify_types
        solrHostsMenuItems.add(
            DropdownMenuItem<String>(value: element, child: Text(element)));
      }
      void onCoreOrCollectionSelected(String? value) {
        setState(() {
          if (value != null) {
            coreOrCollection1 = value;
            if (_tab == 0) {
              _launchEnabled = true;
            }
            _somethingFailed = false;
          }
        });
      }

      void onSndCoreOrCollectionSelected(String? value) {
        setState(() {
          if (value != null) {
            coreOrCollection2 = value;
          }
          _somethingFailed = false;
        });
      }

      return Scaffold(
          key: _scaffoldKey,
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
                  //flex: 1,
                  child: Container(),
                ),
                Expanded(
                    flex: 10, // 80%,
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // mainAxisSize: MainAxisSize.min,

                        const SizedBox(height: 20),

                        Text(_tab == 0
                            ? 'This tool compares taxonomic data between records from your LA Portal and their equivalent records published in GBIF.org. The comparison focuses on several key fields such as scientificName, kingdom, phylum, class, order, family, genus and species. Additionally, it considers other fields like country, etc'
                            : 'This tool compare two solr cores or two solrcloud collections in your LA Portal'),
                        const SizedBox(height: 10),

                        if (_tab == 0)
                          CompareDataTimeline<CompareWithGbifDataPhase>(
                              currentPhase: _currentPhaseTab0,
                              failed: _somethingFailed,
                              phaseValues:
                                  CompareWithGbifDataPhase.values.toList()),
                        if (_tab == 1)
                          CompareDataTimeline<CompareSolrIndexesPhase>(
                              currentPhase: _currentPhaseTab1,
                              failed: _somethingFailed,
                              phaseValues:
                                  CompareSolrIndexesPhase.values.toList()),
                        ButtonTheme(
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            child: DropdownButton<String>(
                                underline: DropdownButtonHideUnderline(
                                  child: Container(),
                                ),
                                disabledHint:
                                    const Text('No solr host available'),
                                hint: const Text('Select Solr host'),
                                value: solrHost1,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      solrHost1 = newValue;
                                    }
                                  });
                                  setState(() {
                                    if (newValue != null) {
                                      _currentPhaseTab0 =
                                          CompareWithGbifDataPhase.getCores;
                                      _currentPhaseTab1 =
                                          CompareSolrIndexesPhase.getCores;
                                      fetchCoreOrCollections(vm)
                                          .then((List<String> result) {
                                        setState(() {
                                          _coreOrCollections = result;
                                        });
                                      });
                                    }
                                  });
                                },
                                // isExpanded: true,
                                elevation: 16,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                items: solrHostsMenuItems)),
                        _coreDropdownMenu(onCoreOrCollectionSelected),
                        if (_tab == 1)
                          _coreDropdownMenu(onSndCoreOrCollectionSelected),
                        if (_tab == 1)
                          Column(
                            children: <Widget>[
                              SwitchListTile(
                                title: const Text('Compare DRs'),
                                value: compareDrs,
                                onChanged: (bool value) {
                                  setState(() {
                                    compareDrs = value;
                                  });
                                },
                              ),
                              SwitchListTile(
                                title: const Text('Compare Species'),
                                value: compareSpecies,
                                onChanged: (bool value) {
                                  setState(() {
                                    compareSpecies = value;
                                  });
                                },
                              ),
                              SwitchListTile(
                                title: const Text('Truncate Species'),
                                value: truncateSpecies,
                                onChanged: (bool value) {
                                  setState(() {
                                    truncateSpecies = value;
                                  });
                                },
                              ),
                              SwitchListTile(
                                title: const Text('Compare Layers'),
                                value: compareLayers,
                                onChanged: (bool value) {
                                  setState(() {
                                    compareLayers = value;
                                  });
                                },
                              ),
                              SwitchListTile(
                                title: const Text('Compare Hubs'),
                                value: compareHubs,
                                onChanged: (bool value) {
                                  setState(() {
                                    compareHubs = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        if (_tab == 0)
                          LaunchBtn(
                              icon: Icons.settings,
                              execBtn: 'Run',
                              onTap: !_launchEnabled
                                  ? null
                                  : () async {
                                      if (_tab == 0) {
                                        setState(() {
                                          errorMessages = null;
                                          statistics = null;
                                          _launchEnabled = false;
                                        });
                                        final Map<String, dynamic> results =
                                            await _compareWithGBIF(vm);
                                        setState(() {
                                          statistics = results['statistics']
                                              as Map<String, Map<String, int>>;
                                          errorMessages =
                                              results['errorMessages']
                                                  as Map<String, String>;
                                          _launchEnabled = true;
                                        });
                                      } else {
                                        setState(() {
                                          _launchEnabled = false;
                                        });
                                        await _compareSolrIndexes(vm);
                                        setState(() {
                                          _launchEnabled = true;
                                        });
                                      }
                                    }),
                        if (_tab == 0) const SizedBox(height: 10),
                        if (_tab == 0 && errorMessages != null)
                          Container(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: errorMessages!.entries.mapIndexed(
                                    (int index,
                                        MapEntry<String, String> entry) {
                                  final Color backgroundColor = index.isOdd
                                      ? Colors.white
                                      : Colors.transparent;
                                  return ListTile(
                                      tileColor: backgroundColor,
                                      leading: entry.key == 'TOTAL' ||
                                              entry.key == 'SUMMARY'
                                          ? null
                                          : GestureDetector(
                                              onTap: () => FlutterClipboard
                                                      .copy(entry.key)
                                                  .then((dynamic value) =>
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                        'Copied to clipboard',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Courier',
                                                            fontSize: 14),
                                                      )))),
                                              child: Text(entry.key)),
                                      title: Row(children: <Widget>[
                                        Flexible(
                                            // height: 40,
                                            child: MarkdownBody(
                                          data: entry.value,
                                          onTapLink: (String text, String? url,
                                              String title) {
                                            launchUrl(Uri.parse(url!));
                                          },
                                        ))
                                      ]));
                                }).toList(),
                              )),
                        if (_tab == 0 &&
                            errorMessages != null &&
                            errorMessages!.length == 1)
                          const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('No differences found')),
                        if (_tab == 0 &&
                            errorMessages != null &&
                            errorMessages!.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              if (errorMessages != null) {
                                _generateAndDownloadHtml(errorMessages!);
                              }
                            },
                            child: const Text('Download issues'),
                          ),
                        if (_tab == 0 && statistics != null)
                          SizedBox(
                              width: double.infinity,
                              height: 600,
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CompareGbifCharts(
                                      statistics: statistics!)))
                      ],
                    ))),
                Expanded(
                  // flex: 1,
                  child: Container(),
                ),
              ]))));
    });
  }

  // static const String gbifBaseUrl = 'https://api.gbif-uat.org/v1';

  static const String gbifBaseUrl = 'https://api.gbif.org/v1';

  Future<Map<String, dynamic>> _compareWithGBIF(_CompareDataViewModel vm,
      [bool debug = false]) async {
    setState(() {
      _currentPhaseTab0 = CompareWithGbifDataPhase.getRandomLARecords;
    });
    final Map<String, dynamic> laRecords = await getRandomLARecords(vm);

    final Map<String, dynamic> recordsGBIFIds = <String, dynamic>{};
    final Map<String, String> initialMessages = <String, String>{};
    final Map<String, String> notFoundMessages = <String, String>{};

    setState(() {
      _currentPhaseTab0 = CompareWithGbifDataPhase.getGBIFRecords;
    });

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
      await Future<void>.delayed(const Duration(milliseconds: 200));
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
          notFoundMessages[id] =
              'Record not found with id: [$id](https://${_alaHubUrl}occurrences/$id) and datasetKey: ${record[gbifDatasetId]} and occurrenceId: $occId';
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    }
    initialMessages['TOTAL'] =
        'Number of LA records processed ${laRecords.length}, number of GBIF records found for these records: ${recordsGBIFIds.length}';
    initialMessages.addAll(notFoundMessages);
    final Map<String, dynamic> results =
        generateStatistics(laRecords, recordsGBIFIds, initialMessages);
    if (debug) {
      debugPrint('Results: $results');
    }

    return results;
  }

  Future<Map<String, dynamic>> getDrs(SolrQueryExecutor vm) async {
    final Map<String, dynamic>? result = await getFacetData(
        solrExec: vm,
        solrBase: 'http://localhost:8983',
        collection: coreOrCollection1!,
        q: 'dataResourceUid:*',
        facetField: _withPipeline ? 'dataResourceUid' : 'data_resource_uid',
        facetLimit: -1,
        sort: 'index');

    if (result == null) {
      _somethingFailed = true;
      return <String, dynamic>{};
    }
    // ignore: avoid_dynamic_calls
    final Map<String, dynamic> drs = result['facet_counts']['facet_fields']
        ['dataResourceUid'] as Map<String, dynamic>;
    setState(() {
      _currentPhaseTab0 = CompareWithGbifDataPhase.getDrs;
    });
    return drs;
  }

  Future<Map<String, dynamic>> getCollectoryDrs(_CompareDataViewModel vm) {
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    vm.doMySqlQuery(
        'SELECT JSON_OBJECTAGG(dr.uid, dr.gbif_registry_key) AS result_json FROM data_resource dr;',
        (Map<String, dynamic> result) {
      completer.complete(result);
    }, (String error) {
      debugPrint('Error: $error');
      _somethingFailed = true;
    });

    return completer.future;
  }

  Future<Map<String, dynamic>> getRandomLARecords(_CompareDataViewModel vm,
      [bool withRank = true]) async {
    setState(() {
      _currentPhaseTab0 = CompareWithGbifDataPhase.getDrs;
    });

    final Map<String, dynamic> dataResources = await getDrs(vm);
    final Map<String, dynamic> drs = await getCollectoryDrs(vm);

    final Map<String, dynamic> records = <String, dynamic>{};
    setState(() {
      _currentPhaseTab0 = CompareWithGbifDataPhase.getRandomLARecords;
    });

    for (int i = 0; i < recordsNumber; i++) {
      final int drOffset = Random().nextInt(dataResources.length);
      final MapEntry<String, dynamic> dataResource =
          dataResources.entries.toList()[drOffset];
      final int recordOffset =
          Random().nextInt(min(20000, dataResource.value as int));

      final Completer<void> completer = Completer<void>();

      vm.doSolrQuery(
          Uri.parse(withRank
                  ? 'http://localhost:8983/solr/${coreOrCollection1!}/select?q=dataResourceUid:${dataResource.key}&rank:[* TO *]&rows=1&wt=json&start=$recordOffset&facet=false'
                  : 'http://localhost:8983/solr/${coreOrCollection1!}/select?q=dataResourceUid:${dataResource.key}&rows=1&wt=json&start=$recordOffset&facet=false')
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
      }, (String error) {
        debugPrint('Error: $error');
        _somethingFailed = true;
      });

      await completer.future;
    }

    return records;
  }

  Map<String, dynamic> generateStatistics(Map<String, dynamic> recordsLA,
      Map<String, dynamic> recordsGBIF, Map<String, String> initialMessages) {
    final Map<String, Map<String, int>> stats = <String, Map<String, int>>{
      'matches': <String, int>{},
      'mismatches': <String, int>{},
      'nulls': <String, int>{}
    };

    final Map<String, String> errorMessages = initialMessages;

    for (final ComparisonField eField in ComparisonField.values) {
      final String field = eField.getName;
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

      for (final ComparisonField efield in ComparisonField.values) {
        final String field = efield.getName;
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
                "1. **Scientific name** differs: [$fullScientificNameLA](${_alaHubUrl}occurrences/$id) (raw: '$fullRawScientificNameLA') vs [$scientificNameGBIF](https://gbif.org/occurrence/${recordGBIF['key']})");
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
                '1. _${StringUtils.capitalize(field)}_ differs: [$value1](${_alaHubUrl}occurrences/$id) vs [$value2](https://gbif.org/occurrence/${recordGBIF['key']})');
          }
        }
      }

      if (errors.isNotEmpty) {
        errorMessages[id] = errors.join('  \n');
      }
    }

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyprint = encoder.convert(stats);
    errorMessages['SUMMARY'] = prettyprint;

    setState(() {
      _currentPhaseTab0 = CompareWithGbifDataPhase.finished;
    });

    return <String, dynamic>{
      'statistics': stats,
      'errorMessages': errorMessages
    };
  }

  void _generateAndDownloadHtml(Map<String, String> errors) {
    final StringBuffer markdownContent = StringBuffer();
    markdownContent.write('# Issues Report\n');
    errors.forEach((String key, String value) {
      markdownContent.write('### $key\n');
      markdownContent.write('$value\n');
    });

    final String htmlContent = md.markdownToHtml(markdownContent.toString());

    final String styledHtmlContent = '''
  <!DOCTYPE html>
  <html>
  <head>
    <style>
      body {
        font-family: 'sans', sans-serif;
      }
      h1 {
        color: green;
      }
      h3 {
        color: black;
      }
    </style>
  </head>
  <body>
    $htmlContent
  </body>
  </html>
  ''';

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddhhmm').format(now);
    final html.Blob blob = html.Blob(<String>[styledHtmlContent], 'text/html');
    final String url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute(
          'download', '${formattedDate}_la_gbif_comparative_issues_report.html')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<List<String>> getCoreOrCollections(_CompareDataViewModel vm) async {
    final Completer<List<String>> collCompleter = Completer<List<String>>();
    final Completer<List<String>> aliasCompleter = Completer<List<String>>();

    vm.doSolrQuery('http://localhost:8983/solr/admin/collections?action=LIST',
        (Map<String, dynamic> result) {
      final List<String> results = <String>[];
      final List<dynamic> docs = result['collections'] as List<dynamic>;

      for (final dynamic doc in docs) {
        results.add(doc.toString());
      }
      collCompleter.complete(results);
    }, (String error) {
      debugPrint('Error: $error');
      _somethingFailed = true;
    });

    vm.doSolrQuery(
        'http://localhost:8983/solr/admin/collections?action=LISTALIASES',
        (Map<String, dynamic> result) {
      final List<String> results = <String>[];
      final Map<String, dynamic> aliases =
          result['aliases'] as Map<String, dynamic>;

      // ignore: prefer_foreach
      for (final String alias in aliases.keys) {
        results.add(alias);
      }

      aliasCompleter.complete(results);
    }, (String error) {
      debugPrint('Error: $error');
      _somethingFailed = true;
    });

    final List<String> results = <String>[];
    results.addAll(await collCompleter.future);
    results.addAll(await aliasCompleter.future);
    return results;
  }

  Future<List<String>> fetchCoreOrCollections(_CompareDataViewModel vm) async {
    return getCoreOrCollections(vm);
  }

  Widget _coreDropdownMenu(Function(String?) onCoreSelected) {
    return _coreOrCollections.isEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ButtonTheme(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: DropdownButton<String>(
                    underline: DropdownButtonHideUnderline(
                      child: Container(),
                    ),
                    disabledHint: const Text('No collection available'),
                    hint: const Text('Select collection'),
                    value: coreOrCollection1,
                    onChanged: (String? newValue) {
                      setState(() {
                        onCoreSelected(newValue);
                      });
                    },
                    elevation: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    items: _coreOrCollections
                        .map((String element) => DropdownMenuItem<String>(
                            value: element, child: Text(element)))
                        .toList())));
  }

  Future<void> _compareSolrIndexes(_CompareDataViewModel vm) async {
    return;
  }
}

class SolrComparator {
  SolrComparator(
      {required this.solrHost1,
      required this.solrHost2,
      required this.coreOrCollection1,
      required this.coreOrCollection2,
      required this.collectoryUrl,
      required this.layers,
      required this.compareDrs,
      required this.compareSpecies,
      required this.truncateSpecies,
      required this.compareInst,
      required this.compareLayers,
      required this.compareHubs,
      required this.csvFormat,
      required this.debug,
      required this.vm}) {
    solrS.add(solrHost1);
    solrS.add(solrHost2);
    collectionS.add(coreOrCollection1);
    collectionS.add(coreOrCollection2);
    titleS.addAll(
        <String>['solrA $coreOrCollection1', 'solrB $coreOrCollection2']);
    SolrCompareResult.csvFormat = csvFormat;
  }

  final String solrHost1;
  final String solrHost2;
  final String coreOrCollection1;
  final String coreOrCollection2;
  final String collectoryUrl;
  final bool compareDrs;
  final bool compareSpecies;
  final bool truncateSpecies;
  final bool compareInst;
  final bool compareLayers;
  final bool compareHubs;
  final bool csvFormat;
  final String totals = 'totals';
  final List<String> titleS = <String>[];
  Map<String, SolrCompareResult> results = <String, SolrCompareResult>{};
  final List<String> solrS = <String>[];
  final List<String> collectionS = <String>[];
  final bool debug;
  final List<String> layers;
  final SolrQueryExecutor vm;

  Future<void> run() async {
    if (compareDrs) {
      await queryTotals(solrS, '/select', <String, String>{
        'q': '*:*',
        'rows': '0',
        'wt': 'json',
        'facet': 'false'
      });
      final List<Map<String, dynamic>> resources = await urlGet(
              collectoryUrl, '/ws/dataResource', <String, String>{}, debug)
          as List<Map<String, dynamic>>;
      for (final Map<String, dynamic> dr in resources) {
        results.putIfAbsent(dr['uid'] as String,
            () => SolrCompareResult.empty(dr['uid'] as String));
      }
      await getDrTotals();

      printHeader();
      printSorted();
      int a = 0;
      int b = 0;
      for (final SolrCompareResult r in results.values) {
        if (r.key != totals) {
          a = a + r.a;
          b = b + r.b;
        }
      }
      final SolrCompareResult mapped = SolrCompareResult('Mapped', a).setB(b);
      if (debug) {
        debugPrint(mapped.toString());
      }
      final SolrCompareResult unmapped =
          SolrCompareResult('Unmapped', results.entries.first.value.a - a)
              .setB(results.entries.first.value.b - b);
      if (debug) {
        debugPrint(unmapped.toString());
      }
      if (debug) {
        final Map<SolrCompareResult, SolrCompareResult> diff =
            Map<SolrCompareResult, SolrCompareResult>.from(results)
              ..removeWhere(
                  (SolrCompareResult e, SolrCompareResult v) => v.d != 0);
        debugPrint('results size: ${diff.length}');
      }
      reset();
    }
    if (compareSpecies) {
      await getFieldDiff('taxon_name', 'scientificName');
      if (truncateSpecies) {
        results.removeWhere(
            (String k, SolrCompareResult v) => v.d < 10000 && v.d > -10000);
      }
      printHeader();
      printSorted();
      reset();
    }

    if (compareInst) {
      await getFieldDiff('institution_name', 'institutionName');
      printHeader();
      printSorted();
      reset();
    }
    if (compareLayers) {
      for (final String l in layers) {
        await getFieldDiff(l, l);
      }
      printHeader();
      printSorted();
      reset();
    }
    if (compareHubs) {
      await getFieldDiff('data_hub_uid', 'dataHubUid');
      printHeader();
      printSorted();
      reset();
    }
  }

  void printHeader() {
    if (csvFormat) {
      debugPrint(';${titleS[0]};${titleS[1]};difference');
    } else {
      debugPrint('|  |  ${titleS[0]}  | ${titleS[1]} | difference |');
      debugPrint(
          '| ------------- | ------------- | ------------- | ------------- |');
    }
  }

  void reset() {
    results = <String, SolrCompareResult>{};
    debugPrint('');
    debugPrint('');
  }

  void printSorted() {
    final List<SolrCompareResult> sorted = results.values.toList();
    sorted
        .sort((SolrCompareResult a, SolrCompareResult b) => a.d.compareTo(b.d));
    for (final SolrCompareResult r in sorted) {
      if (r.d != 0) {
        debugPrint(r.toString());
      }
    }
  }

  Future<List> getDrTotals() async {
    return Future.wait(solrS.mapIndexed((int i, String solrBase) async {
      final String field = await isAPipelinesIndex(solrBase, collectionS[i])
          ? 'dataResourceUid'
          : 'data_resource_uid';
      final Map<String, dynamic>? response = await getFacetData(
          solrExec: vm,
          solrBase: solrBase,
          collection: collectionS[i],
          q: '$field:*',
          facetField: field,
          facetLimit: -1,
          sort: 'index');
      if (response == null) {
        // FIXME error handling
        return;
      }
      final Map<String, dynamic> drs =
          ((response['facet_counts'] as Map<String, dynamic>)['facet_fields']
              as Map<String, dynamic>)[field] as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> e in drs.entries) {
        String key;
        if (!results.containsKey(e.key)) {
          // debugPrint('${e.key} not found in collectory');
          key = '~~${e.key}~~';
          results.putIfAbsent(key, () => SolrCompareResult(key, 0));
        } else {
          key = e.key;
        }
        if (i == 0) {
          results.update(
              key, (SolrCompareResult el) => el.setA(e.value as int));
        } else {
          results.update(
              key, (SolrCompareResult el) => el.setB(e.value as int));
        }
      }
    }));
  }

  Future<List> getFieldDiff(String bStoreField, String pipelinesField) async {
    return Future.wait(solrS.mapIndexed((int i, String solrBase) async {
      final String field = await isAPipelinesIndex(solrBase, collectionS[i])
          ? pipelinesField
          : bStoreField;
      final Map<String, dynamic>? response = await getFacetData(
          solrExec: vm,
          solrBase: solrBase,
          collection: collectionS[i],
          q: '$field:*',
          facetField: field,
          facetLimit: -1,
          sort: 'index');
      if (response == null) {
        // FIXME error handling
        return;
      }
      final Map<String, dynamic> results =
          ((response['facet_counts'] as Map<String, dynamic>)['facet_fields']
              as Map<String, dynamic>)[field] as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in results.entries) {
        storeResults(entry.key, entry.value as int, i);
      }
    }));
  }

  Future<bool> isAPipelinesIndex(String solrBase, String collection) async {
    final Uri uri = asUri(
        solrBase,
        '/solr/$collection/select',
        <String, String>{
          'q': '*:*',
          'wt': 'csv',
          'rows': '0',
          'facet': '',
          'fl': 'data*'
        },
        debug);
    final Response response = await http.get(uri);
    return response.body.contains('dataResourceUid');
  }

  Future<List<void>> queryTotals(
      List<String> solrS, String query, Map<String, String> params) async {
    return Future.wait(solrS.mapIndexed((int i, String solrBase) async {
      final Map<String, dynamic> response =
          await urlGet(solrBase, '/solr/${collectionS[i]}$query', params)
              as Map<String, dynamic>;
      storeResults(totals,
          (response['response'] as Map<String, dynamic>)['numFound'] as int, i);
    }));
  }

  void storeResults(String key, int num, int index) {
    if (!results.containsKey(key)) {
      results.putIfAbsent(key, () => SolrCompareResult.empty(key));
    }
    if (index == 0) {
      results.update(key, (SolrCompareResult el) => el.setA(num));
    } else {
      results.update(key, (SolrCompareResult el) => el.setB(num));
    }
  }

  Future<dynamic> urlGet(String base, String path, Map<String, String> params,
      [bool debug = false]) async {
    final Uri uri = asUri(base, path, params, debug);
    try {
      final Response response = await http.get(uri);
      return jsonDecode(response.body);
    } catch (all) {
      _handleError('Error reading url: $uri$all');
      rethrow;
    }
  }

  void _handleError(String msg) {
    debugPrint(msg);
  }
}

class SolrCompareResult {
  SolrCompareResult(this.key, this.a) : b = 0;

  SolrCompareResult.empty(this.key)
      : a = 0,
        b = 0;
  static bool csvFormat = false;

  final String key;
  int a;
  int b;

  int get d => b - a;

  @override
  String toString() => csvFormat
      ? '$key;${_f(a)};${_f(b)};${d > 0 ? '+' : ''}${_f(d)}'
      : '|$key|${_f(a)}|${_f(b)}|${d > 0 ? '+' : ''}${_f(d)}|';

  SolrCompareResult setA(int a) {
    this.a = a;
    return this;
  }

  SolrCompareResult setB(int b) {
    this.b = b;
    return this;
  }

  // FIXME use a better locale
  // final NumberFormat formatter = NumberFormat.decimalPattern(locale);
  String _f(int n) => intl.NumberFormat.decimalPattern('en').format(n);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolrCompareResult &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode ^ a.hashCode ^ b.hashCode;
}

class _CompareDataViewModel implements SolrQueryExecutor {
  _CompareDataViewModel(
      {required this.state,
      required this.doSolrQuery,
      required this.doMySqlQuery});

  final AppState state;
  final void Function(String query, Function(Map<String, dynamic>) onResult,
      Function(String) onError) doSolrQuery;
  final void Function(String query, Function(Map<String, dynamic>) onResult,
      Function(String) onError) doMySqlQuery;

  @override
  void query(String query, Function(Map<String, dynamic> p1) onResult,
      Function(String message) onError) {
    doSolrQuery(query, onResult, onError);
  }
}
