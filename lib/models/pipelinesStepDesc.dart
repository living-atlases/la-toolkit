class PipelinesStepDesc {
  String name;
  String desc;

  PipelinesStepDesc({required this.name, required this.desc});

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
    'dwca-export':
        PipelinesStepDesc(name: 'dwca-export', desc: 'export a dwca archive'),
    'uuid': PipelinesStepDesc(
        name: 'uuid',
        desc:
            'mints UUID on new records and rematches to existing UUIDs for records loaded before'),
    'image-sync': PipelinesStepDesc(
        name: 'image-sync',
        desc:
            'retrieves details of images stored in image service for indexing purposes'),
    'image-load': PipelinesStepDesc(
        name: 'image-load',
        desc: 'pushes an export of multimedia AVRO files to the image service'),
    'sds':
        PipelinesStepDesc(name: 'sds', desc: 'runs the sensitive data checks'),
    'sample': PipelinesStepDesc(
        name: 'sample',
        desc:
            'use the sampling service to retrieve values for points for the layers in the spatial service'),
    'index': PipelinesStepDesc(
        name: 'index',
        desc: 'generates a AVRO records ready to be index to SOLR'),
    'clustering': PipelinesStepDesc(
        name: 'clustering', desc: 'clustering of occurrences'),
    'jackknife': PipelinesStepDesc(
        name: 'jackknife',
        desc:
            "adds an aggregated jackknife AVRO for all datasets. Requires samping-avro. After running a full 'index' is required."),
    'solr': PipelinesStepDesc(
        name: 'solr',
        desc: 'reads index records in AVRO and submits them to SOLR'),
    'solr-sync': PipelinesStepDesc(name: 'solr-sync', desc: 'sync schema'),
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
    'migrate': PipelinesStepDesc(name: 'migrate', desc: 'used for migration'),
  };

  static PipelinesStepDesc get(String name) {
    return _map[name]!;
  }

  static List<PipelinesStepDesc> get list => _map.values.toList();
}
