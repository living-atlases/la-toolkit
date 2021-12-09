class BasicService {
  String version;
  String name;
  List<num> tcp;
  List<num> udp;
  bool reachableFromOtherServers;
  BasicService(
      {required this.name,
      required this.version,
      List<num>? tcp,
      List<num>? udp,
      this.reachableFromOtherServers = false})
      : tcp = tcp ?? [],
        udp = udp ?? [];

  bool isCompatible(BasicService other) {
    if (name != other.name) return true;
    if (version != other.version) return false;
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
        .where(
            (dep) => dep.name != Java.v8.name && dep.name != PostGis.v2_4.name)
        .toList();
  }
}

class Java extends BasicService {
  Java(version)
      : super(name: "java", version: version, reachableFromOtherServers: false);
  static final v8 = Java("8");
  static final v11 = Java("11");
}

abstract class Tcp extends BasicService {
  Tcp(name, version, port, [reachableFromOtherServers = false])
      : super(
            name: name,
            version: version,
            tcp: [port],
            reachableFromOtherServers: reachableFromOtherServers);
}

class Cas extends Tcp {
  Cas(version) : super("cas", version, 9000, false);
  static final def = Cas("");
}

class UserDetails extends Tcp {
  UserDetails(version) : super("userdetails", version, 9001, false);
  static final def = UserDetails("");
}

class CasManagement extends Tcp {
  CasManagement(version) : super("cas-management", version, 8070, false);
  static final def = CasManagement("");
}

class ApiKey extends Tcp {
  ApiKey(version) : super("apikey", version, 9002);
  static final def = ApiKey("");
}

class Doi extends Tcp {
  Doi(version) : super("doi", version, 8081);
  static final def = Doi("");
}

class NameMatchingService extends BasicService {
  NameMatchingService(version)
      : super(
            name: "namematching-service", version: version, tcp: [8880, 8881]);
  static final def = NameMatchingService("");
}

class Nginx extends BasicService {
  Nginx(version)
      : super(
            name: "nginx",
            version: version,
            tcp: [80, 443],
            reachableFromOtherServers: true);
  static final def = Nginx("");
}

class Postfix extends BasicService {
  Postfix(version) : super(name: "postfix", version: version, tcp: [25]);
  static final def = Postfix("");
}

class Solr extends BasicService {
  Solr(version)
      : super(
            name: "solr",
            version: version,
            tcp: [8983],
            reachableFromOtherServers: true);
  static final v7 = Solr("7");
  static final v8 = Solr("8");
}

class SolrCloud extends BasicService {
  SolrCloud(version)
      : super(
            name: "solrcloud",
            version: version,
            tcp: [8983, 2181],
            reachableFromOtherServers: true);
  static final v8 = Solr("8");
}

class Cassandra extends BasicService {
  Cassandra(version)
      : super(
            name: "cassandra",
            version: version,
            tcp: [9042],
            reachableFromOtherServers: true);
  static final v2 = Cassandra("2");
  static final v3 = Cassandra("3");
}

class Tomcat extends BasicService {
  Tomcat(version) : super(name: "tomcat", version: version, tcp: [8080]);
  static final v8 = Tomcat("8");
  static final v9 = Tomcat("9");
}

class MySql extends BasicService {
  MySql(version) : super(name: "mysql", version: version, tcp: [3306]);

  static final v5_7 = MySql("5.7");
  static final v8 = MySql("8");
}

class PostgresSql extends BasicService {
  PostgresSql(version)
      : super(name: "postgresql", version: version, tcp: [5432]);

  static final v8 = PostgresSql("8");
  static final v9_6 = PostgresSql("9.6");
  static final v10 = PostgresSql("10");
  static final v13 = PostgresSql("13");
}

class PostGis extends BasicService {
  PostGis(version) : super(name: "postgis", version: version);

  static final v2_4 = PostGis("2_4");
  // FIXME MORE

}

class Mongo extends BasicService {
  Mongo(version) : super(name: "mongo", version: version, tcp: [27017]);

  static final v4_0 = Mongo("4.0");
}

class ElasticSearch extends BasicService {
  ElasticSearch(version)
      : super(name: "elasticsearch", version: version, tcp: [9200]);
  static final v5_6_6 = ElasticSearch("5.6.6");
  static final v7_7_1 = ElasticSearch("7.7.1");
  static final v7_3_0 = ElasticSearch("7.3.0");
}

class Spark extends BasicService {
  Spark(version)
      : super(name: "spark", version: version, tcp: [
          8081,
          7077,
          65000,
          8080,
          8085,
        ]);
  static final def = Spark("");
}

class Hadoop extends Tcp {
  Hadoop(version) : super("hadoop", version, 9000);
  static final def = Hadoop("");
}

// Playbooks
// ala-demo-basic.yml collectory-standalone.yml biocache-hub-standalone.yml biocache-service-clusterdb.yml bie-hub.yml bie-index.yml image-service.yml species-list-standalone.yml regions-standalone.yml logger-standalone.yml solr7-standalone.yml cas5-standalone.yml biocache-db.yml biocache-cli.yml spatial.yml webapi_standalone.yml dashboard.yml alerts-standalone.yml doi-service-standalone.yml nameindexer-standalone.yml
