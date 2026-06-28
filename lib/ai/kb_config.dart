// Vendored from living-atlas-kb (https://github.com/living-atlases/kb),
// dart/lib/src/kb_config.dart. Keep in sync with upstream.

/// Configuration for the Living Atlas KB client.
class KbConfig {
  /// Base URL of the KB API, e.g. 'https://kb.l-a.site'
  final String baseUrl;

  /// Default ChromaDB collection to query.
  final String collection;

  /// Number of context chunks to retrieve per query (1–10).
  final int nResults;

  const KbConfig({
    required this.baseUrl,
    this.collection = 'la_toolkit_kb',
    this.nResults = 5,
  }) : assert(nResults >= 1 && nResults <= 10);
}
