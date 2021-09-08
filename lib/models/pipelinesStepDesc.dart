import 'package:la_toolkit/models/laServiceDesc.dart';

class PipelinesStepDesc {
  String name;
  String desc;
  List<LAServiceName> depends;

  PipelinesStepDesc(
      {required this.name, required this.desc, List<LAServiceName>? depends})
      : depends = depends ?? [];

  static final Map<String, PipelinesStepDesc> _map = {
    'dwca-avro': PipelinesStepDesc(
        name: 'dwca-avro',
        desc: 'reads a Dwc-A and converts it to an verbatim.avro file'),
    'interpret': PipelinesStepDesc(
        name: 'interpret',
        desc:
            'reads verbatim.avro, interprets it and writes the interpreted data and the issues to Avro files'),
    'validate': PipelinesStepDesc(
        name: 'validate',
        desc:
            'validates the identifiers for a dataset, checking for duplicate and empty keys'),
    'uuid': PipelinesStepDesc(
        name: 'uuid',
        desc:
            'mints UUID on new records and rematches to existing UUIDs for records loaded before'),
    'sds': PipelinesStepDesc(
        name: 'sds',
        depends: [LAServiceName.sds],
        desc: 'runs the sensitive data checks'),
    'image-sync': PipelinesStepDesc(
        name: 'image-sync',
        depends: [LAServiceName.images],
        desc:
            'retrieves details of images stored in image service for indexing purposes'),
    'image-load': PipelinesStepDesc(
        name: 'image-load',
        depends: [LAServiceName.images],
        desc: 'pushes an export of multimedia AVRO files to the image service'),
    'index': PipelinesStepDesc(
        name: 'index',
        desc: 'generates a AVRO records ready to be index to SOLR'),
    'sample': PipelinesStepDesc(
        name: 'sample',
        depends: [LAServiceName.spatial],
        desc:
            'use the sampling service to retrieve values for points for the layers in the spatial service'),
    'clustering': PipelinesStepDesc(
        name: 'clustering',
        depends: [LAServiceName.spatial],
        desc: 'Duplication detection (clustering) of occurrences'),
    'jackknife': PipelinesStepDesc(
        name: 'jackknife',
        depends: [LAServiceName.spatial],
        desc:
            "adds an aggregated jackknife AVRO for all datasets. Requires samping-avro. After running a full 'index' is required."),
    'solr': PipelinesStepDesc(
        name: 'solr',
        desc: 'reads index records in AVRO and submits them to SOLR'),
    'archive-list': PipelinesStepDesc(
        name: 'archive-list',
        desc:
            "dumps out a list of archives that can be ingested to '/tmp/dataset-archive-list.csv'"),
    'dataset-list': PipelinesStepDesc(
        name: 'dataset-list',
        desc:
            "dumps out a list of datasets that have been ingested to '/tmp/dataset-counts.csv'"),
    'validation-report': PipelinesStepDesc(
        name: 'validation-report',
        desc:
            "dumps out a CSV list of datasets ready to be indexed to '/tmp/validation-report.csv'"),
    'prune-datasets': PipelinesStepDesc(
        name: 'prune-datasets',
        desc: 'remove any datasets no longer registered in the collectory'),
    'solr-schema':
        PipelinesStepDesc(name: 'solr-schema', desc: 'sync solr schema'),
    'dwca-export':
        PipelinesStepDesc(name: 'dwca-export', desc: 'export a dwca archive'),
    'migrate': PipelinesStepDesc(
        name: 'migrate', desc: 'used for migration from an old cassandra'),
  };

  static PipelinesStepDesc get(String name) {
    return _map[name]!;
  }

  static List<PipelinesStepDesc> get list => _map.values.toList();

  static List<PipelinesStepDesc> get allList =>
      _map.values.toList().sublist(0, 14);

  static List<String> get allStringList => allList.map((v) => v.name).toList();
}
