import 'package:flutter/foundation.dart';

@immutable
class BasicService {
  BasicService(
      {required this.name,
      required this.version,
      List<num>? tcp,
      List<num>? udp,
      this.reachableFromOtherServers = false})
      : tcp = tcp ?? <num>[],
        udp = udp ?? <num>[];
  final String version;
  final String name;
  final List<num> tcp;
  final List<num> udp;
  final bool reachableFromOtherServers;

  bool isCompatible(BasicService other) {
    if (name != other.name) {
      return true;
    }
    if (version != other.version) {
      return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicService &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          tcp == other.tcp &&
          udp == other.udp &&
          name == other.name;

  @override
  int get hashCode =>
      version.hashCode ^ name.hashCode ^ tcp.hashCode ^ udp.hashCode;

  static List<BasicService> toCheck(List<BasicService> deps) {
    return deps
        .where((BasicService dep) => dep.name != PostGis.def.name)
        .toList();
  }
}

abstract class Tcp extends BasicService {
  Tcp(String name, String version, int port,
      [bool reachableFromOtherServers = false])
      : super(
            name: name,
            version: version,
            tcp: <int>[port],
            reachableFromOtherServers: reachableFromOtherServers);
}

class Cas extends Tcp {
  Cas(String version) : super('cas', version, 9000, false);
  static final Cas def = Cas('');
}

class UserDetails extends Tcp {
  UserDetails(String version) : super('userdetails', version, 9001, false);
  static final UserDetails def = UserDetails('');
}

class CasManagement extends Tcp {
  CasManagement(String version) : super('cas-management', version, 8070, false);
  static final CasManagement def = CasManagement('');
}

class ApiKey extends Tcp {
  ApiKey(String version) : super('apikey', version, 9002);
  static final ApiKey def = ApiKey('');
}

class Doi extends Tcp {
  Doi(String version) : super('doi', version, 8081);
  static final Doi def = Doi('');
}

class NameMatchingService extends BasicService {
  NameMatchingService(String version)
      : super(
            name: 'namematching-service',
            version: version,
            tcp: <num>[9179, 9180]);
  static final NameMatchingService def = NameMatchingService('');
}

class SensitiveDataService extends BasicService {
  SensitiveDataService(String version)
      : super(
            name: 'sensitive-data-service',
            version: version,
            tcp: <num>[9189, 9190]);
  static final SensitiveDataService def = SensitiveDataService('');
}

class Nginx extends BasicService {
  Nginx(String version)
      : super(
            name: 'nginx',
            version: version,
            tcp: <num>[80, 443],
            reachableFromOtherServers: true);
  static final Nginx def = Nginx('');
}

class Postfix extends BasicService {
  Postfix(String version)
      : super(name: 'postfix', version: version, tcp: <num>[25]);
  static final Postfix def = Postfix('');
}

class Solr extends BasicService {
  Solr(String version)
      : super(
            name: 'solr',
            version: version,
            tcp: <num>[8983],
            reachableFromOtherServers: true);
  static final Solr v7 = Solr('7');
  static final Solr v8 = Solr('8');
}

class SolrCloud extends BasicService {
  SolrCloud(String version)
      : super(
            name: 'solrcloud',
            version: version,
            tcp: <num>[8983, 2181],
            reachableFromOtherServers: true);
  static final Solr v8 = Solr('8');
}

class Cassandra extends BasicService {
  Cassandra(String version)
      : super(
            name: 'cassandra',
            version: version,
            tcp: <num>[9042],
            reachableFromOtherServers: true);
  static final Cassandra v2 = Cassandra('2');
  static final Cassandra v3 = Cassandra('3');
}

class Tomcat extends BasicService {
  Tomcat(String version)
      : super(name: 'tomcat', version: version, tcp: <num>[8080]);
  static final Tomcat def = Tomcat('');
}

class MySql extends BasicService {
  MySql(String version)
      : super(name: 'mysql', version: version, tcp: <num>[3306]);

  static final MySql def = MySql('');
}

class PostgresSql extends BasicService {
  PostgresSql(String version)
      : super(name: 'postgresql', version: version, tcp: <num>[5432]);

  static final PostgresSql def = PostgresSql('');
}

class PostGis extends BasicService {
  PostGis(String version) : super(name: 'postgis', version: version);

  static final PostGis def = PostGis('');
}

class Mongo extends BasicService {
  Mongo(String version)
      : super(name: 'mongo', version: version, tcp: <num>[27017]);

  static final Mongo v4_0 = Mongo('4.0');
}

// FIXME Move this to dependencies
class ElasticSearch extends BasicService {
  ElasticSearch(String version)
      : super(name: 'elasticsearch', version: version, tcp: <num>[9200]);
  static final ElasticSearch v5_6_6 = ElasticSearch('5.6.6');
  static final ElasticSearch v7_7_1 = ElasticSearch('7.7.1');
  static final ElasticSearch v7_3_0 = ElasticSearch('7.3.0');
  static final ElasticSearch v7_14_1 = ElasticSearch('7.14.1');
  static final ElasticSearch v7_17_7 = ElasticSearch('7.17.7');
}

class Spark extends BasicService {
  Spark(String version)
      : super(name: 'spark', version: version, tcp: <num>[
          8081,
          7077,
          65000,
          8080,
          8085,
        ]);
  static final Spark def = Spark('');
}

class Hadoop extends Tcp {
  Hadoop(String version) : super('hadoop', version, 9000);
  static final Hadoop def = Hadoop('');
}

class Biocollect extends Tcp {
  Biocollect(String version) : super('biocollect', version, 9003, false);
  static final Biocollect def = Biocollect('');
}

class Ecodata extends Tcp {
  Ecodata(String version) : super('ecodata', version, 9004, false);
  static final Ecodata def = Ecodata('');
}

class EcodataReporting extends Tcp {
  EcodataReporting(String version)
      : super('ecodata-reporting', version, 9005, false);
  static final EcodataReporting def = EcodataReporting('');
}

// Playbooks
// ala-demo-basic.yml collectory-standalone.yml biocache-hub-standalone.yml biocache-service-clusterdb.yml bie-hub.yml bie-index.yml image-service.yml species-list-standalone.yml regions-standalone.yml logger-standalone.yml solr7-standalone.yml cas5-standalone.yml biocache-db.yml biocache-cli.yml spatial.yml webapi_standalone.yml dashboard.yml alerts-standalone.yml doi-service-standalone.yml nameindexer-standalone.yml
