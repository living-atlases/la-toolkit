class BasicService {
  String version;
  String name;
  BasicService({this.name, this.version});

  bool isCompatible(BasicService other) {
    if (this.name != other.name) return true;
    if (this.version != other.version) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicService &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          name == other.name;

  @override
  int get hashCode => version.hashCode ^ name.hashCode;
}

class Java extends BasicService {
  Java(version) : super(name: "java", version: version);
  static final v8 = Java("8");
}

class Nginx extends BasicService {
  Nginx(version) : super(name: "nginx", version: version);
  static final def = Nginx("");
}

class Solr extends BasicService {
  Solr(version) : super(name: "solr", version: version);
  static final v7 = Solr("7");
}

class Cassandra extends BasicService {
  Cassandra(version) : super(name: "cassandra", version: version);
  static final v2 = Cassandra("2");
  static final v3 = Cassandra("3");
}

class Tomcat extends BasicService {
  Tomcat(version) : super(name: "tomcat", version: version);
  static final v8 = Tomcat("8");
  static final v9 = Tomcat("9");
}

class MySql extends BasicService {
  MySql(version) : super(name: "mysql", version: version);

  static final v5_7 = MySql("5.7");
  static final v8 = MySql("8");
}

class PostgresSql extends BasicService {
  PostgresSql(version) : super(name: "postgresql", version: version);

  static final v8 = PostgresSql("8");
  static final v9_6 = PostgresSql("9.6");
  static final v10 = PostgresSql("10");
}

class PostGis extends BasicService {
  PostGis(version) : super(name: "postgis", version: version);

  static final v2_4 = PostGis("2_4");
  // FIXME MORE

}

class Mongo extends BasicService {
  Mongo(version) : super(name: "mongo", version: version);

  static final v4_0 = Mongo("4.0");
}

class ElasticSearch extends BasicService {
  ElasticSearch(version) : super(name: "elasticsearch", version: version);
  static final v5_6_6 = ElasticSearch("5.6.6");
  static final v7_7_1 = ElasticSearch("7.7.1");
  static final v7_3_0 = ElasticSearch("7.3.0");
}

// Playbooks
// ala-demo-basic.yml collectory-standalone.yml biocache-hub-standalone.yml biocache-service-clusterdb.yml bie-hub.yml bie-index.yml image-service.yml species-list-standalone.yml regions-standalone.yml logger-standalone.yml solr7-standalone.yml cas5-standalone.yml biocache-db.yml biocache-cli.yml spatial.yml webapi_standalone.yml dashboard.yml alerts-standalone.yml doi-service-standalone.yml nameindexer-standalone.yml
