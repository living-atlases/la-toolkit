import './la_service_name.dart';
import './pipelines_step_name.dart';

class PipelinesStepDesc {
  PipelinesStepDesc({
    required this.name,
    required this.desc,
    List<LAServiceName>? depends,
  }) : depends = depends ?? <LAServiceName>[];
  String name;
  String desc;
  List<LAServiceName> depends;

  static final Map<String, PipelinesStepDesc>
  _map = <String, PipelinesStepDesc>{
    dwcaAvro: PipelinesStepDesc(
      name: dwcaAvro,
      desc: 'reads a Dwc-A and converts it to an verbatim.avro file',
    ),
    interpret: PipelinesStepDesc(
      name: interpret,
      desc:
          'reads verbatim.avro, interprets it and writes the interpreted data and the issues to Avro files',
    ),
    validate: PipelinesStepDesc(
      name: validate,
      desc:
          'validates the identifiers for a dataset, checking for duplicate and empty keys',
    ),
    uuid: PipelinesStepDesc(
      name: uuid,
      desc:
          'mints UUID on new records and rematches to existing UUIDs for records loaded before',
    ),
    sds: PipelinesStepDesc(
      name: sds,
      depends: <LAServiceName>[LAServiceName.sds],
      desc: 'runs the sensitive data checks',
    ),
    imageLoad: PipelinesStepDesc(
      name: imageLoad,
      depends: <LAServiceName>[LAServiceName.images],
      desc: 'pushes an export of multimedia AVRO files to the image service',
    ),
    imageSync: PipelinesStepDesc(
      name: imageSync,
      depends: <LAServiceName>[LAServiceName.images],
      desc:
          'retrieves details of images stored in image service for indexing purposes',
    ),
    index: PipelinesStepDesc(
      name: index,
      desc: 'generates a AVRO records ready to be index to SOLR',
    ),
    sample: PipelinesStepDesc(
      name: sample,
      depends: <LAServiceName>[LAServiceName.spatial],
      desc:
          'use the sampling service to retrieve values for points for the layers in the spatial service',
    ),
    clustering: PipelinesStepDesc(
      name: clustering,
      depends: <LAServiceName>[LAServiceName.spatial],
      desc: 'Duplication detection (clustering) of occurrences',
    ),
    jackknife: PipelinesStepDesc(
      name: jackknife,
      depends: <LAServiceName>[LAServiceName.spatial],
      desc:
          "adds an aggregated jackknife AVRO for all datasets. Requires samping-avro. After running a full 'index' is required.",
    ),
    solr: PipelinesStepDesc(
      name: solr,
      desc: 'reads index records in AVRO and submits them to SOLR',
    ),
    archiveList: PipelinesStepDesc(
      name: archiveList,
      desc:
          "dumps out a list of archives that can be ingested to '/tmp/dataset-archive-list.csv'",
    ),
    datasetList: PipelinesStepDesc(
      name: datasetList,
      desc:
          "dumps out a list of datasets that have been ingested to '/tmp/dataset-counts.csv'",
    ),
    validationReport: PipelinesStepDesc(
      name: validationReport,
      desc:
          "dumps out a CSV list of datasets ready to be indexed to '/tmp/validation-report.csv'",
    ),
    pruneDatasets: PipelinesStepDesc(
      name: pruneDatasets,
      desc: 'remove any datasets no longer registered in the collectory',
    ),
    solrSchema: PipelinesStepDesc(name: solrSchema, desc: 'sync solr schema'),
    dwcaExport: PipelinesStepDesc(
      name: dwcaExport,
      desc: 'export a dwca archive',
    ),
    migrate: PipelinesStepDesc(
      name: 'migrate',
      desc: 'used for migration from an old cassandra',
    ),
  };

  static PipelinesStepDesc get(String name) {
    return _map[name]!;
  }

  static List<PipelinesStepDesc> get list => _map.values.toList();
  static const int lastStep = 12;
  static List<PipelinesStepDesc> get allList =>
      _map.values.toList().sublist(0, lastStep);
  static List<PipelinesStepDesc> get restList =>
      _map.values.toList().sublist(lastStep, _map.length);

  static List<String> get allStringList =>
      allList.map((PipelinesStepDesc v) => v.name).toList();
  static List<String> get restStringList =>
      restList.map((PipelinesStepDesc v) => v.name).toList();
}
