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
  int tab = 0;
  late LAProject p;
  bool isPipelineIndex1 = false;
  bool isPipelineIndex2 = false;
  String? solrHost1;
  String? solrHost2;
  String? coreOrCollection1;
  String? coreOrCollection2;
  late String collectoryHost;
  static const String gbifDatasetId = 'gbifDatasetId';
  final Map<String, dynamic> recordsWithDifferences = <String, dynamic>{};
  Map<String, String>? errorMessages;
  Map<String, Map<String, int>>? statistics;
  late String alaHubUrl;
  late String collectoryUrl;
  bool launchEnabled = false;
  List<String> coreOrCollections1 = <String>[];
  List<String> coreOrCollections2 = <String>[];
  bool compareDrs = true;
  bool compareSpecies = true;
  bool compareInst = true;
  bool truncateSpecies = true;
  bool compareLayers = true;
  bool compareHubs = true;
  String? recordToCompare;
  Map<String, SolrCompareResult> compareResults = <String, SolrCompareResult>{};
  static const String totals = 'totals';
  final List<String> compareTitles = <String>[];
  final List<String> solrCompareHosts = <String>[];
  final List<String> coreOrCollectionList = <String>[];
  List<String> layers = <String>[];
  CompareWithGbifDataPhase currentPhaseTab0 =
      CompareWithGbifDataPhase.getSolrHosts;
  CompareSolrIndexesPhase currentPhaseTab1 =
      CompareSolrIndexesPhase.getSolrHosts;
  CompareOneWithGbifDataPhase currentPhaseTab2 =
      CompareOneWithGbifDataPhase.getSolrHosts;
  bool somethingFailed = false;
  bool csvFormat = false;
  String indexDiffReport = '';
  final List<int> recordsNumberOptions = <int>[2, 5, 10, 20, 50, 100, 200, 500];
  int numberOfRecords = 5;
  int populationSize = 1000000;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CompareDataViewModel>(
        converter: (Store<AppState> store) {
      return _CompareDataViewModel(
        state: store.state,
        doSolrQuery: (String solrHost, String query,
            Function(Map<String, dynamic>) onResult, Function(String) onError) {
          store.dispatch(SolrQuery(
              project: p.id,
              solrHost: solrHost,
              query: query,
              onError: onError,
              onResult: onResult));
        },
        doSolrRawQuery: (String solrHost, String query,
            Function(dynamic) onResult, Function(String) onError) {
          store.dispatch(SolrRawQuery(
              project: p.id,
              solrHost: solrHost,
              query: query,
              onError: onError,
              onResult: onResult));
        },
        doMySqlQuery: (String query, Function(Map<String, dynamic>) onResult,
            Function(String) onError) {
          store.dispatch(MySqlQuery(
              project: p.id,
              mySqlHost: collectoryHost,
              db: 'collectory',
              query: query,
              onError: onError,
              onResult: onResult));
        },
      );
    }, builder: (BuildContext context, _CompareDataViewModel vm) {
      p = vm.state.currentProject;
      collectoryHost = p
          .getServerById(
              p.getServiceDeploysForSomeService(collectory)[0].serverId!)!
          .name;
      final Map<String, dynamic> services =
          p.getServiceDetailsForVersionCheck();
      alaHubUrl = (services[alaHub] as Map<String, dynamic>)['url'] as String;
      collectoryUrl =
          (services[collectory] as Map<String, dynamic>)['url'] as String;
      final List<String> solrHosts = <String>[];
      for (final String service in <String>[solr, solrcloud]) {
        p
            .getServiceDeploysForSomeService(service)
            .forEach((LAServiceDeploy sd) {
          if (sd.serverId == null) {
            final String dockerHost = p
                .getServerById(p
                    .getServiceDeploysForSomeService(dockerSwarm)[0]
                    .serverId!)!
                .name;
            if (!solrHosts.contains(dockerHost)) {
              solrHosts.add(dockerHost);
            }
          } else {
            final LAServer? server = p.getServerById(sd.serverId!);
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
      Future<void> onCoreOrCollectionSelected(String? value) async {
        setState(() {
          if (value != null) {
            _setCheckIndexPhase();
            coreOrCollection1 = value;

            if (tab == 0) {
              launchEnabled = true;
            } else if (tab == 2 && recordToCompare != null) {
              launchEnabled = true;
            } else {
              if (coreOrCollection2 != null) {
                launchEnabled = true;
              }
            }
            somethingFailed = false;
          }
        });
        if (value != null) {
          isPipelineIndex1 =
              await isAPipelinesIndex(vm, solrHost1!, coreOrCollection1!);
          setState(() {});
        }
      }

      Future<void> onSndCoreOrCollectionSelected(String? value) async {
        setState(() {
          if (value != null) {
            _setCheckIndexPhase();
            coreOrCollection2 = value;
            if (coreOrCollection1 != null) {
              launchEnabled = true;
            }
          }
          somethingFailed = false;
        });
        if (value != null) {
          isPipelineIndex2 =
              await isAPipelinesIndex(vm, solrHost2!, coreOrCollection2!);
          setState(() {});
        }
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
              TabItem<dynamic>(
                  icon: Icons.repeat_one, title: 'Compare one record'),
            ],
            initialActiveIndex: 0,
            //optional, default as 0
            onTap: (int i) => setState(() => tab = i),
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

                        Text(tab == 0
                            ? 'This tool compares taxonomic data between records from your LA Portal and their equivalent records published in GBIF.org. The comparison focuses on several key fields such as scientificName, kingdom, phylum, class, order, family, genus and species. Additionally, it considers other fields like country, etc'
                            : tab == 1
                                ? 'This tool compare two solr cores or two solrcloud collections in your LA Portal'
                                : 'This tool compare one LA record with the equivalent in GBIF'),
                        const SizedBox(height: 10),

                        if (tab == 0)
                          CompareDataTimeline<CompareWithGbifDataPhase>(
                              currentPhase: currentPhaseTab0,
                              failed: somethingFailed,
                              phaseValues:
                                  CompareWithGbifDataPhase.values.toList()),
                        if (tab == 1)
                          CompareDataTimeline<CompareSolrIndexesPhase>(
                              currentPhase: currentPhaseTab1,
                              failed: somethingFailed,
                              phaseValues:
                                  CompareSolrIndexesPhase.values.toList()),
                        if (tab == 2)
                          CompareDataTimeline<CompareOneWithGbifDataPhase>(
                              currentPhase: currentPhaseTab2,
                              failed: somethingFailed,
                              phaseValues:
                                  CompareOneWithGbifDataPhase.values.toList()),
                        ButtonTheme(
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            child: DropdownButton<String>(
                                underline: DropdownButtonHideUnderline(
                                  child: Container(),
                                ),
                                disabledHint:
                                    const Text('No solr host available'),
                                hint: Text(
                                    'Select Solr host${tab == 1 ? ' A' : ''}'),
                                value: solrHost1,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      solrHost1 = newValue;
                                    }
                                  });
                                  setState(() {
                                    if (newValue != null) {
                                      currentPhaseTab0 =
                                          CompareWithGbifDataPhase.getCores;
                                      currentPhaseTab1 =
                                          CompareSolrIndexesPhase.getCores;
                                      fetchCoreOrCollections(vm, solrHost1!)
                                          .then((List<String> result) {
                                        setState(() {
                                          coreOrCollections1 = result;
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
                        if (tab == 1)
                          ButtonTheme(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              child: DropdownButton<String>(
                                  underline: DropdownButtonHideUnderline(
                                    child: Container(),
                                  ),
                                  disabledHint:
                                      const Text('No solr host available'),
                                  hint: Text(
                                      'Select Solr host${tab == 1 ? ' B' : ''}'),
                                  value: solrHost2,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      if (newValue != null) {
                                        solrHost2 = newValue;
                                      }
                                    });
                                    setState(() {
                                      if (solrHost2 != null &&
                                          solrHost1 != null) {
                                        currentPhaseTab1 =
                                            CompareSolrIndexesPhase.getCores;
                                        fetchCoreOrCollections(vm, solrHost2!)
                                            .then((List<String> result) {
                                          setState(() {
                                            coreOrCollections2 = result;
                                          });
                                        });
                                      }
                                    });
                                  },
                                  // isExpanded: true,
                                  elevation: 16,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  items: solrHostsMenuItems)),
                        _coreDropdownMenu(coreOrCollections1, coreOrCollection1,
                            onCoreOrCollectionSelected, tab == 1 ? ' A' : ''),
                        if (tab == 0)
                          SizedBox(
                              width: 200,
                              child: ButtonTheme(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Num. of records to compare',
                                      ),
                                      child: DropdownButton<int>(
                                        underline: DropdownButtonHideUnderline(
                                            child: Container()),
                                        value: numberOfRecords,
                                        items: recordsNumberOptions
                                            .map((int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            numberOfRecords = newValue!;
                                          });
                                        },
                                      )))),
                        if (tab == 1)
                          _coreDropdownMenu(
                              coreOrCollections2,
                              coreOrCollection2,
                              onSndCoreOrCollectionSelected,
                              tab == 1 ? ' B' : ''),
                        const SizedBox(height: 10),
                        if (coreOrCollection1 != null)
                          Text(
                              isPipelineIndex1
                                  ? "'$coreOrCollection1' is a pipelines index"
                                  : "'$coreOrCollection1' is a normal index",
                              style: const TextStyle(color: Colors.grey)),
                        if (tab == 1 && coreOrCollection2 != null)
                          Text(
                              isPipelineIndex2
                                  ? "'$coreOrCollection2' is a pipelines index"
                                  : "'$coreOrCollection2' is a normal index",
                              style: const TextStyle(color: Colors.grey)),
                        if (tab == 1)
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
                                title: const Text('Compare Institutions'),
                                value: compareInst,
                                onChanged: (bool value) {
                                  setState(() {
                                    compareInst = value;
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
                                title: const Text('Compare Hubs'),
                                value: compareHubs,
                                onChanged: (bool value) {
                                  setState(() {
                                    compareHubs = value;
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
                            ],
                          ),
                        if (tab == 1 && compareLayers)
                          SizedBox(
                              width: 400,
                              child: TextField(
                                onChanged: (String value) {
                                  setState(() {
                                    layers =
                                        // value.replaceAll(' ', '').split(',');
                                        value
                                            .split(RegExp(r'[,\s]+'))
                                            .where((String layer) =>
                                                layer.isNotEmpty)
                                            .toList();
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Layer fields to compare',
                                ),
                              )),
                        if (tab == 2)
                          SizedBox(
                              width: 400,
                              child: TextField(
                                onChanged: (String value) {
                                  setState(() {
                                    recordToCompare = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'LA Record id to compare',
                                ),
                              )),
                        LaunchBtn(
                            icon: Icons.settings,
                            execBtn: 'Run',
                            onTap: !launchEnabled
                                ? null
                                : () async {
                                    if (tab == 0 || tab == 2) {
                                      setState(() {
                                        errorMessages = null;
                                        statistics = null;
                                        launchEnabled = false;
                                        somethingFailed = false;
                                      });
                                      final Map<String, dynamic> results =
                                          await _compareWithGBIF(vm, tab == 2);
                                      setState(() {
                                        statistics = results['statistics']
                                            as Map<String, Map<String, int>>;
                                        errorMessages = results['errorMessages']
                                            as Map<String, String>;
                                        launchEnabled = true;
                                      });
                                    } else {
                                      setState(() {
                                        launchEnabled = false;
                                        indexDiffReport = '';
                                        somethingFailed = false;
                                      });
                                      await _compareSolrIndexes(vm);
                                      setState(() {
                                        launchEnabled = true;
                                      });
                                    }
                                  }),
                        if (tab == 0 || tab == 2) const SizedBox(height: 10),
                        if ((tab == 0 || tab == 2) && errorMessages != null)
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
                        if ((tab == 0 || tab == 2) &&
                            errorMessages != null &&
                            errorMessages!.length == 1)
                          const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('No differences found')),
                        if ((tab == 0 || tab == 2) &&
                            errorMessages != null &&
                            errorMessages!.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              if (errorMessages != null) {
                                _generateAndDownloadHtmlForErrors(
                                    errorMessages!);
                              }
                            },
                            child: const Text('Download issues'),
                          ),
                        if ((tab == 0 || tab == 2) && statistics != null)
                          SizedBox(
                              width: double.infinity,
                              height: 600,
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CompareGbifCharts(
                                      statistics: statistics!))),
                        if (tab == 1) const SizedBox(height: 10),
                        if (tab == 1 && indexDiffReport.isNotEmpty)
                          MarkdownBody(data: indexDiffReport),
                        if (tab == 1) const SizedBox(height: 10),
                        if (tab == 1 && indexDiffReport.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              if (indexDiffReport.isNotEmpty) {
                                _generateAndDownloadHtmlForContent(
                                    indexDiffReport, true);
                              }
                            },
                            child: const Text('Download report'),
                          ),
                        if (tab == 1) const SizedBox(height: 10),
                        if (tab == 1 && indexDiffReport.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              if (indexDiffReport.isNotEmpty) {
                                _generateAndDownloadHtmlForContent(
                                    indexDiffReport, false);
                              }
                            },
                            child: const Text('Download markdown report'),
                          ),
                      ],
                    ))),
                Expanded(
                  // flex: 1,
                  child: Container(),
                ),
              ]))));
    });
  }

  void _setCheckIndexPhase() {
    if (tab == 1) {
      currentPhaseTab1 = CompareSolrIndexesPhase.detectSolrIndexType;
    } else {
      currentPhaseTab0 = CompareWithGbifDataPhase.detectSolrIndexType;
    }
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

  // static const String gbifBaseUrl = 'https://api.gbif-uat.org/v1';

  static const String gbifBaseUrl = 'https://api.gbif.org/v1';

  Future<Map<String, dynamic>> _compareWithGBIF(
      _CompareDataViewModel vm, bool onlyOneRecord,
      [bool debug = true]) async {
    setState(() {
      if (onlyOneRecord) {
        currentPhaseTab2 = CompareOneWithGbifDataPhase.detectSolrIndexType;
      } else {
        currentPhaseTab0 = CompareWithGbifDataPhase.detectSolrIndexType;
      }
    });

    try {
      isPipelineIndex1 =
          await isAPipelinesIndex(vm, solrHost1!, coreOrCollection1!);
    } catch (e) {
      setState(() {
        if (onlyOneRecord) {
          currentPhaseTab2 = CompareOneWithGbifDataPhase.detectSolrIndexType;
        } else {
          currentPhaseTab0 = CompareWithGbifDataPhase.detectSolrIndexType;
        }
      });
    }

    final Map<String, dynamic> laRecords =
        !onlyOneRecord ? await getRandomLARecords(vm) : await getLARecord(vm);

    final Map<String, dynamic> recordsGBIFIds = <String, dynamic>{};
    final Map<String, String> initialMessages = <String, String>{};
    final Map<String, String> notFoundMessages = <String, String>{};

    setState(() {
      if (onlyOneRecord) {
        currentPhaseTab2 = CompareOneWithGbifDataPhase.getGBIFRecord;
      } else {
        currentPhaseTab0 = CompareWithGbifDataPhase.getGBIFRecords;
      }
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
              'Record not found with id: [$id](https://${alaHubUrl}occurrences/$id) and datasetKey: ${record[gbifDatasetId]} and occurrenceId: $occId';
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    }
    initialMessages['TOTAL'] =
        'Number of LA records processed ${laRecords.length}, number of GBIF records found for these records: ${recordsGBIFIds.length}';
    initialMessages.addAll(notFoundMessages);
    final Map<String, dynamic> results = generateStatistics(
        laRecords, recordsGBIFIds, initialMessages, onlyOneRecord);
    if (debug) {
      debugPrint('Results: $results');
    }

    return results;
  }

  Future<Map<String, dynamic>> getDrs(
      SolrQueryExecutor vm, String solrHost) async {
    final Map<String, dynamic>? result = await getFacetData(
        solrHost: solrHost,
        solrExec: vm,
        collection: coreOrCollection1!,
        q: 'dataResourceUid:*',
        facetField: isPipelineIndex1 ? 'dataResourceUid' : 'data_resource_uid',
        facetLimit: -1,
        sort: 'index');

    if (result == null) {
      somethingFailed = true;
      return <String, dynamic>{};
    }
    // ignore: avoid_dynamic_calls
    final Map<String, dynamic> drs = result['facet_counts']['facet_fields']
        ['dataResourceUid'] as Map<String, dynamic>;
    setState(() {
      currentPhaseTab0 = CompareWithGbifDataPhase.getDrs;
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
      somethingFailed = true;
    });

    return completer.future;
  }

  Future<Map<String, dynamic>> getRandomLARecords(
      _CompareDataViewModel vm) async {
    setState(() {
      currentPhaseTab0 = CompareWithGbifDataPhase.getDrs;
    });

    final Map<String, dynamic> dataResources = await getDrs(vm, solrHost1!);
    final Map<String, dynamic> drs = await getCollectoryDrs(vm);

    final Map<String, dynamic> records = <String, dynamic>{};
    setState(() {
      currentPhaseTab0 = CompareWithGbifDataPhase.getRandomLARecords;
    });

    for (int i = 0; i < numberOfRecords; i++) {
      final int drOffset = Random().nextInt(dataResources.length);
      final MapEntry<String, dynamic> dataResource =
          dataResources.entries.toList()[drOffset];
      final int recordOffset =
          Random().nextInt(min(20000, dataResource.value as int));

      final Completer<void> completer = Completer<void>();

      final String field =
          isPipelineIndex1 ? 'dataResourceUid' : 'data_resource_uid';

      vm.doSolrQuery(
          solrHost1!,
          Uri.parse(
                  'http://localhost:8983/solr/${coreOrCollection1!}/select?q=$field:${dataResource.key}&rows=1&wt=json&start=$recordOffset&facet=false')
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
        somethingFailed = true;
      });

      await completer.future;
    }

    return records;
  }

  Future<Map<String, dynamic>> getLARecord(_CompareDataViewModel vm) async {
    setState(() {
      currentPhaseTab2 = CompareOneWithGbifDataPhase.getLARecord;
    });

    Map<String, dynamic>? record;

    setState(() {
      currentPhaseTab2 = CompareOneWithGbifDataPhase.getDrs;
    });

    final Map<String, dynamic> drs = await getCollectoryDrs(vm);
    final Completer<void> completer = Completer<void>();

    vm.doSolrQuery(
        solrHost1!,
        Uri.parse(
                'http://localhost:8983/solr/${coreOrCollection1!}/select?q=id:$recordToCompare&rows=1&wt=json&facet=false')
            .toString(), (Map<String, dynamic> result) {
      final Map<String, dynamic> occ =
          ((result['response'] as Map<String, dynamic>)['docs']
              as List<dynamic>)[0] as Map<String, dynamic>;

      final String? id = occ['id'] as String?;
      final String? gbifDrId = drs[occ['dataResourceUid']] as String?;

      // SKIP DRS with null gbif_registry_key
      if (id != null && gbifDrId != null) {
        occ[gbifDatasetId] = gbifDrId;
        record = occ;
      }
      completer.complete();
    }, (String error) {
      debugPrint('Error: $error');
      somethingFailed = true;
    });

    await completer.future;
    final Map<String, dynamic> result = <String, dynamic>{
      '$recordToCompare': record ?? <String, dynamic>{}
    };
    return result;
  }

  Map<String, dynamic> generateStatistics(
      Map<String, dynamic> recordsLA,
      Map<String, dynamic> recordsGBIF,
      Map<String, String> initialMessages,
      bool onlyOneRecord) {
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
                "1. **Scientific name** differs: [$fullScientificNameLA](${alaHubUrl}occurrences/$id) (raw: '$fullRawScientificNameLA') vs [$scientificNameGBIF](https://gbif.org/occurrence/${recordGBIF['key']})");
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
                '1. _${StringUtils.capitalize(field)}_ differs: [$value1](${alaHubUrl}occurrences/$id) vs [$value2](https://gbif.org/occurrence/${recordGBIF['key']})');
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
      if (onlyOneRecord) {
        currentPhaseTab2 = CompareOneWithGbifDataPhase.finished;
      } else {
        currentPhaseTab0 = CompareWithGbifDataPhase.finished;
      }
    });

    return <String, dynamic>{
      'statistics': stats,
      'errorMessages': errorMessages
    };
  }

  void _generateAndDownloadHtmlForErrors(Map<String, String> errors) {
    final StringBuffer markdownContent = errorsToMarkDown(errors);
    const String fileName = 'la_gbif_comparative_issues_report';
    _generateAndDownloadHtml(markdownContent.toString(), fileName);
  }

  void _generateAndDownloadHtmlForContent(String content, bool asHtml) {
    final StringBuffer markdownContent = toMarkDown(content);
    const String fileName = 'la_indexes_comparative_report';
    if (asHtml) {
      _generateAndDownloadHtml(markdownContent.toString(), fileName);
    } else {
      _generateAndDownloadMd(markdownContent, fileName);
    }
  }

  void _generateAndDownloadMd(StringBuffer markdownContent, String fileName) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddhhmm').format(now);
    final html.Blob blob =
        html.Blob(<String>[markdownContent.toString()], 'text/markdown');
    final String url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', '${formattedDate}_$fileName.md')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _generateAndDownloadHtml(String content, String fileName) {
    final String htmlContent =
        md.markdownToHtml(content, extensionSet: md.ExtensionSet.gitHubWeb);

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
      ..setAttribute('download', '${formattedDate}_$fileName.html')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  StringBuffer errorsToMarkDown(Map<String, String> errors) {
    final StringBuffer markdownContent = StringBuffer();
    markdownContent.write('# Issues Report\n');
    errors.forEach((String key, String value) {
      markdownContent.write('### $key\n');
      markdownContent.write('$value\n');
    });
    return markdownContent;
  }

  StringBuffer toMarkDown(String content) {
    final StringBuffer markdownContent = StringBuffer();
    markdownContent.write(content);
    return markdownContent;
  }

  Future<List<String>> getCoreOrCollections(
      _CompareDataViewModel vm, String solrHost) async {
    final Completer<List<String>> collCompleter = Completer<List<String>>();
    final Completer<List<String>> aliasCompleter = Completer<List<String>>();

    vm.doSolrQuery(
        solrHost, 'http://localhost:8983/solr/admin/collections?action=LIST',
        (Map<String, dynamic> result) {
      final List<String> results = <String>[];
      final List<dynamic> docs = result['collections'] as List<dynamic>;

      for (final dynamic doc in docs) {
        results.add(doc.toString());
      }
      collCompleter.complete(results);
    }, (String error) {
      debugPrint('Error: $error');
      somethingFailed = true;
    });

    vm.doSolrQuery(solrHost,
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
      somethingFailed = true;
    });

    final List<String> results = <String>[];
    results.addAll(await collCompleter.future);
    results.addAll(await aliasCompleter.future);
    return results;
  }

  Future<List<String>> fetchCoreOrCollections(
      _CompareDataViewModel vm, String solrHost) async {
    return getCoreOrCollections(vm, solrHost);
  }

  Widget _coreDropdownMenu(
      List<String> coreOrCollections,
      String? initialSelection,
      Function(String?) onCoreSelected,
      String colSuffix) {
    return coreOrCollections1.isEmpty
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
                    hint: Text('Select collection$colSuffix'),
                    value: initialSelection,
                    onChanged: (String? newValue) {
                      setState(() {
                        onCoreSelected(newValue);
                      });
                    },
                    elevation: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    items: coreOrCollections
                        .map((String element) => DropdownMenuItem<String>(
                            value: element, child: Text(element)))
                        .toList())));
  }

  Future<void> _compareSolrIndexes(SolrQueryExecutor solrExec,
      [bool debug = false]) async {
    solrCompareHosts.clear();
    solrCompareHosts.add(solrHost1!);
    solrCompareHosts.add(solrHost2!);
    coreOrCollectionList.clear();
    coreOrCollectionList.add(coreOrCollection1!);
    coreOrCollectionList.add(coreOrCollection2!);
    compareTitles.clear();
    compareTitles.addAll(
        <String>['solrA $coreOrCollection1', 'solrB $coreOrCollection2']);
    SolrCompareResult.csvFormat = false;

    setState(() {
      currentPhaseTab1 = CompareSolrIndexesPhase.compareIndexes;
    });

    if (compareDrs) {
      await queryTotals(solrExec, solrCompareHosts, '/select', <String, String>{
        'q': '*:*',
        'rows': '0',
        'wt': 'json',
        'facet': 'false'
      });
      final List<dynamic> resources = await httpGet(
              collectoryUrl, '/ws/dataResource', <String, String>{}, debug)
          as List<dynamic>;

      for (final dynamic ddr in resources) {
        final Map<String, dynamic> dr = ddr as Map<String, dynamic>;
        compareResults.putIfAbsent(dr['uid'] as String,
            () => SolrCompareResult.empty(dr['uid'] as String));
      }
      await getDrTotals(solrExec);

      printHeader('Datasets');
      printSorted();
      int a = 0;
      int b = 0;
      for (final SolrCompareResult r in compareResults.values) {
        if (r.key != totals) {
          a = a + r.a;
          b = b + r.b;
        }
      }
      final SolrCompareResult mapped = SolrCompareResult('Mapped', a).setB(b);
      if (debug) {
        debugPrint(mapped.toString());
      }
      final SolrCompareResult unmapped = SolrCompareResult(
              'Unmapped', compareResults.entries.first.value.a - a)
          .setB(compareResults.entries.first.value.b - b);
      if (debug) {
        debugPrint(unmapped.toString());
      }
      if (debug) {
        final Map<SolrCompareResult, SolrCompareResult> diff =
            Map<SolrCompareResult, SolrCompareResult>.from(compareResults)
              ..removeWhere(
                  (SolrCompareResult e, SolrCompareResult v) => v.d != 0);
        debugPrint('results size: ${diff.length}');
      }
      reset();
    }
    if (compareSpecies) {
      await getFieldDiff('taxon_name', 'scientificName', solrExec);
      if (truncateSpecies) {
        debugPrint(compareResults.length.toString());
        final List<MapEntry<String, SolrCompareResult>> speciesList =
            compareResults.entries.toList()
              ..sort((MapEntry<String, SolrCompareResult> a,
                      MapEntry<String, SolrCompareResult> b) =>
                  b.value.d.compareTo(a.value.d));

        final Map<String, SolrCompareResult> truncatedResults =
            Map<String, SolrCompareResult>.fromEntries(speciesList.take(20));
        compareResults
          ..clear()
          ..addAll(truncatedResults);
        debugPrint(compareResults.length.toString());
        /* Only bigger differences
        compareResults.removeWhere(
            (String k, SolrCompareResult v) => v.d < 10000 && v.d > -10000); */
      }
      printHeader('Species');
      printSorted();
      reset();
    }

    if (compareInst) {
      await getFieldDiff('institution_name', 'institutionName', solrExec);
      printHeader('Institutions');
      printSorted();
      reset();
    }
    if (compareLayers) {
      for (final String l in layers) {
        await getFieldDiff(l, l, solrExec);
      }
      printHeader('Layers');
      printSorted();
      reset();
    }
    if (compareHubs) {
      await getFieldDiff('data_hub_uid', 'dataHubUid', solrExec);
      printHeader('Hubs');
      printSorted();
      reset();
    }
    setState(() {
      currentPhaseTab1 = CompareSolrIndexesPhase.finished;
    });
  }

  void printHeader(String title) {
    if (csvFormat) {
      reportPrint(';${compareTitles[0]};${compareTitles[1]};difference');
    } else {
      reportPrint(
          '| $title |  ${compareTitles[0]}  | ${compareTitles[1]} | difference |');
      reportPrint(
          '| ------------- | ------------- | ------------- | ------------- |');
    }
  }

  Future<dynamic> httpGet(String base, String path, Map<String, String> params,
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

  void reset() {
    compareResults = <String, SolrCompareResult>{};
    reportPrint('');
    reportPrint('');
  }

  void printSorted() {
    final List<SolrCompareResult> sorted = compareResults.values.toList();
    bool empty = true;
    //   debugPrint(sorted.toString());
    sorted
        .sort((SolrCompareResult a, SolrCompareResult b) => a.d.compareTo(b.d));
    for (final SolrCompareResult r in sorted) {
      if (r.d != 0) {
        empty = false;
        reportPrint(r.toString());
      }
    }
    if (empty) {
      reportPrint('No differences found');
    }
  }

  Future<void> getDrTotals(SolrQueryExecutor queryExec) async {
    try {
      await Future.wait(
          solrCompareHosts.mapIndexed((int i, String solrHost) async {
        final String field =
            (i == 0 && isPipelineIndex1) || (i == 1 && isPipelineIndex2)
                ? 'dataResourceUid'
                : 'data_resource_uid';
        final Map<String, dynamic>? response = await getFacetData(
            solrHost: solrHost,
            solrExec: queryExec,
            collection: coreOrCollectionList[i],
            q: '$field:*',
            facetField: field,
            facetLimit: -1,
            sort: 'index');
        if (response == null) {
          somethingFailed = true;
        } else {
          if (!response.containsKey('facet_counts') ||
              response['facet_counts'] is! Map<String, dynamic> ||
              !(response['facet_counts'] as Map<String, dynamic>)
                  .containsKey('facet_fields') ||
              (response['facet_counts'] as Map<String, dynamic>)['facet_fields']
                  is! Map<String, dynamic> ||
              !((response['facet_counts']
                          as Map<String, dynamic>)['facet_fields']
                      as Map<String, dynamic>)
                  .containsKey(field)) {
            debugPrint('$isPipelineIndex1 $isPipelineIndex2 $field');
            debugPrint(
                'Error: The response $response does not have facet_counts/facet_fields/$field');
          }
          // ignore: avoid_dynamic_calls
          final Map<String, dynamic> drs = response['facet_counts']
              ['facet_fields'][field] as Map<String, dynamic>;
          /* final Map<String, dynamic> drs = ((response['facet_counts']
                  as Map<String, dynamic>)['facet_fields']
              as Map<String, dynamic>)[field] as Map<String, dynamic>; */
          for (final MapEntry<String, dynamic> e in drs.entries) {
            String key;
            if (!compareResults.containsKey(e.key)) {
              // debugPrint('${e.key} not found in collectory');
              key = '~~${e.key}~~';
              compareResults.putIfAbsent(key, () => SolrCompareResult(key, 0));
            } else {
              key = e.key;
            }
            if (i == 0) {
              compareResults.update(
                  key, (SolrCompareResult el) => el.setA(e.value as int));
            } else {
              compareResults.update(
                  key, (SolrCompareResult el) => el.setB(e.value as int));
            }
          }
        }
      }));
    } catch (all) {
      debugPrint('Error: $all');
      somethingFailed = true;
      rethrow;
    }
  }

  Future<void> getFieldDiff(String bStoreField, String pipelinesField,
      SolrQueryExecutor queryExec) async {
    try {
      await Future.wait(
          solrCompareHosts.mapIndexed((int i, String solrHost) async {
        final String field =
            (i == 0 && isPipelineIndex1) || (i == 1 && isPipelineIndex2)
                ? pipelinesField
                : bStoreField;
        final Map<String, dynamic>? response = await getFacetData(
            solrHost: solrHost,
            solrExec: queryExec,
            collection: coreOrCollectionList[i],
            q: '$field:*',
            facetField: field,
            facetLimit: -1,
            sort: 'index');
        if (response == null) {
          somethingFailed = true;
        } else {
          if (!response.containsKey('facet_counts') ||
              response['facet_counts'] is! Map<String, dynamic> ||
              !(response['facet_counts'] as Map<String, dynamic>)
                  .containsKey('facet_fields') ||
              (response['facet_counts'] as Map<String, dynamic>)['facet_fields']
                  is! Map<String, dynamic> ||
              !((response['facet_counts']
                          as Map<String, dynamic>)['facet_fields']
                      as Map<String, dynamic>)
                  .containsKey(field)) {
            debugPrint(
                'Error: The response $response does not have facet_counts/facet_fields/$field');
          }
          // ignore: avoid_dynamic_calls
          final Map<String, dynamic> results = response['facet_counts']
              ['facet_fields'][field] as Map<String, dynamic>;
          /* final Map<String, dynamic> results =
            ((response!['facet_counts'] as Map<String, dynamic>)['facet_fields']
                as Map<String, dynamic>)[field] as Map<String, dynamic>; */
          for (final MapEntry<String, dynamic> entry in results.entries) {
            storeResults(entry.key, entry.value as int, i);
          }
        }
      }));
    } catch (all) {
      somethingFailed = true;
      rethrow;
    }
  }

  Future<bool> isAPipelinesIndex(
      SolrQueryExecutor solrExec, String solrHost, String collection,
      [bool debug = true]) async {
    try {
      final String response = await doSolrRawQuery(
          solrExec,
          solrHost,
          '/solr/$collection/select',
          <String, String>{
            'q': '*:*',
            'wt': 'csv',
            'rows': '0',
            'facet': '',
            'fl': 'data*'
          },
          debug) as String;
      debugPrint('Response: $response');
      return response.contains('dataResourceUid');
    } catch (all) {
      somethingFailed = true;
      _handleError('Error checking if is a pipelines index: $all');
      rethrow;
    }
  }

  Future<List<void>> queryTotals(SolrQueryExecutor solrExec, List<String> solrS,
      String query, Map<String, String> params) async {
    return Future.wait(solrS.mapIndexed((int i, String solrHost) async {
      final Map<String, dynamic> response = await doSolrQuery(
          solrExec, solrHost, '/solr/${coreOrCollectionList[i]}$query', params);
      storeResults(totals,
          (response['response'] as Map<String, dynamic>)['numFound'] as int, i);
    }));
  }

  void storeResults(String key, int num, int index) {
    if (!compareResults.containsKey(key)) {
      compareResults.putIfAbsent(key, () => SolrCompareResult.empty(key));
    }
    if (index == 0) {
      compareResults.update(key, (SolrCompareResult el) => el.setA(num));
    } else {
      compareResults.update(key, (SolrCompareResult el) => el.setB(num));
    }
  }

  Future<Map<String, dynamic>> doSolrQuery(SolrQueryExecutor solrExec,
      String solrHost, String path, Map<String, String> params,
      [bool debug = false]) async {
    final Uri uri = asUri('http://localhost:8983', path, params, debug);
    try {
      final Completer<Map<String, dynamic>> completer =
          Completer<Map<String, dynamic>>();
      solrExec.query(solrHost, uri.toString(), (Map<String, dynamic> response) {
        completer.complete(response);
      }, (String message) {
        _handleError('Error reading url: $uri $message');
      });
      return completer.future;
    } catch (all) {
      somethingFailed = true;
      _handleError('Error reading url: $uri $all');
      rethrow;
    }
  }

  Future<dynamic> doSolrRawQuery(SolrQueryExecutor solrExec, String solrHost,
      String path, Map<String, String> params,
      [bool debug = false]) async {
    final Uri uri = asUri('http://localhost:8983', path, params, debug);
    try {
      final Completer<dynamic> completer = Completer<dynamic>();
      solrExec.rawQuery(solrHost, uri.toString(), (dynamic response) {
        completer.complete(response);
      }, (String message) {
        _handleError('Error reading url: $uri $message');
      });
      return completer.future;
    } catch (all) {
      somethingFailed = true;
      _handleError('Error reading url: $uri $all');
      rethrow;
    }
  }

  void _handleError(String msg) {
    debugPrint(msg);
  }

  void reportPrint(String msg) {
    indexDiffReport += '$msg\n';
  }

  double getZValue(double confidenceLevel) {
    if (confidenceLevel == 0.90) {
      return 1.645;
    }
    if (confidenceLevel == 0.95) {
      return 1.96;
    }
    if (confidenceLevel == 0.99) {
      return 2.576;
    }
    // Add more if needed
    return 0;
  }

  int calculateSampleSize(
      double confidenceLevel, double marginOfError, int populationSize) {
    final double Z = getZValue(confidenceLevel);
    const double p = 0.5;
    final double e = marginOfError;

    final double numerator = pow(Z, 2) * p * (1 - p);
    final num denominator = pow(e, 2);

    int sampleSize = (numerator / denominator).ceil();

    if (populationSize != null && populationSize > 0) {
      sampleSize =
          (sampleSize / (1 + ((sampleSize - 1) / populationSize))).ceil();
    }

    return sampleSize;
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
      required this.doSolrRawQuery,
      required this.doMySqlQuery});

  final AppState state;
  final void Function(
      String solrHost,
      String query,
      Function(Map<String, dynamic>) onResult,
      Function(String) onError) doSolrQuery;
  final void Function(String solrHost, String query, Function(dynamic) onResult,
      Function(String) onError) doSolrRawQuery;
  final void Function(String query, Function(Map<String, dynamic>) onResult,
      Function(String) onError) doMySqlQuery;

  @override
  void query(
      String solrHost,
      String query,
      Function(Map<String, dynamic> result) onResult,
      Function(String message) onError) {
    doSolrQuery(solrHost, query, onResult, onError);
  }

  @override
  void rawQuery(String solrHost, String query,
      Function(dynamic result) onResult, Function(String message) onError) {
    doSolrRawQuery(solrHost, query, onResult, onError);
  }
}
