// Vendored from living-atlas-kb (https://github.com/living-atlases/kb),
// dart/lib/src/kb_models.dart. Keep in sync with upstream.

/// Data models for Living Atlas KB API responses.

class QueryResult {
  final String content;
  final Map<String, dynamic> metadata;
  final double relevance;

  const QueryResult({
    required this.content,
    required this.metadata,
    required this.relevance,
  });

  factory QueryResult.fromJson(Map<String, dynamic> json) => QueryResult(
        content: json['content'] as String,
        metadata: Map<String, dynamic>.from(json['metadata'] as Map),
        relevance: (json['relevance'] as num).toDouble(),
      );
}

class QueryResponse {
  final List<QueryResult> results;

  const QueryResponse({required this.results});

  factory QueryResponse.fromJson(Map<String, dynamic> json) => QueryResponse(
        results: (json['results'] as List)
            .map((e) => QueryResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CollectionInfo {
  final String name;
  final int count;

  const CollectionInfo({required this.name, required this.count});

  factory CollectionInfo.fromJson(Map<String, dynamic> json) => CollectionInfo(
        name: json['name'] as String,
        count: json['count'] as int,
      );
}

class RepoEntry {
  final String org;
  final String name;
  final String url;
  final String? description;

  const RepoEntry({
    required this.org,
    required this.name,
    required this.url,
    this.description,
  });

  String get key => '$org/$name';
}

class ReposManifest {
  final List<RepoEntry> repos;
  final Set<String> tier1Keys;

  const ReposManifest({required this.repos, required this.tier1Keys});

  factory ReposManifest.fromJson(Map<String, dynamic> json) {
    final repos = <RepoEntry>[];
    final orgs = (json['orgs'] as Map?) ?? const {};
    orgs.forEach((org, cfg) {
      final m = cfg as Map<String, dynamic>;
      final baseUrl = (m['base_url'] as String).replaceAll(RegExp(r'/+$'), '');
      for (final r in (m['repos'] as List)) {
        final entry = r as Map<String, dynamic>;
        final name = entry['name'] as String;
        repos.add(RepoEntry(
          org: org as String,
          name: name,
          url: '$baseUrl/$name',
          description: entry['description'] as String?,
        ));
      }
    });
    final tier1 = ((json['tier1'] as List?) ?? const [])
        .map((e) => e as String)
        .toSet();
    return ReposManifest(repos: repos, tier1Keys: tier1);
  }

  List<RepoEntry> get tier1 =>
      repos.where((r) => tier1Keys.contains(r.key)).toList();

  List<RepoEntry> get others =>
      repos.where((r) => !tier1Keys.contains(r.key)).toList();
}
