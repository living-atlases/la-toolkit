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
