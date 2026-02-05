import 'package:collection/collection.dart';
import '../utils/regexp.dart';
import './la_cluster.dart';
import './la_server.dart';
import './la_service_deploy.dart';
import './la_service_name.dart';
import 'la_project.dart';

// Other option is to get variables from ala-install parsing the templates with
// some regexp like {{([a-z A-Z0-9][^{}]+)}}

// ignore: constant_identifier_names
enum LAVariableType { String, int, double, bool, select }

enum LAVariableSubcategory {
  org,
  dataQuality,
  downloads,
  cache,
  apikeys,
  otherKeys,
  ssl,
  pipelines,
  events,
  dockerCompose,
}

extension LAVariableSucategoryTitleExtension on LAVariableSubcategory {
  String get title {
    switch (this) {
      case LAVariableSubcategory.org:
        return 'Organization details';
      case LAVariableSubcategory.dataQuality:
        return 'Data Quality';
      case LAVariableSubcategory.cache:
        return 'Cache';
      case LAVariableSubcategory.events:
        return 'Events';
      case LAVariableSubcategory.downloads:
        return 'Downloads';
      case LAVariableSubcategory.ssl:
        return 'SSL';
      case LAVariableSubcategory.apikeys:
        return 'API Keys';
      case LAVariableSubcategory.otherKeys:
        return 'Other keys';
      case LAVariableSubcategory.pipelines:
        return 'Pipelines configuration';
      case LAVariableSubcategory.dockerCompose:
        return 'Docker Compose variables';
    }
  }
}

class LAVariableDesc {
  LAVariableDesc({
    required this.name,
    required this.nameInt,
    this.service = LAServiceName.all,
    this.subcategory,
    this.type = LAVariableType.String,
    this.hint,
    this.error,
    this.regExp,
    this.help,
    this.defValue,
    this.depends,
    this.inTunePage = true,
    this.advanced = false,
    this.enabled = true,
    this.protected = false,
    this.onlyHub = false,
    this.allowEmpty = true,
    this.isVisible,
  });

  String name;
  String nameInt;
  LAServiceName service;
  LAVariableSubcategory? subcategory;
  LAVariableType type;
  String? hint;
  String? error;
  RegExp? regExp;
  String? help;
  LAServiceName? depends;
  Function? defValue;
  bool Function(LAProject)? isVisible;
  bool advanced;
  bool enabled;
  bool inTunePage;
  bool protected;
  bool onlyHub;
  bool allowEmpty;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAVariableDesc &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          service == other.service &&
          type == other.type &&
          hint == other.hint &&
          error == other.error &&
          regExp == other.regExp &&
          help == other.help &&
          advanced == other.advanced &&
          inTunePage == other.inTunePage &&
          protected == other.protected &&
          enabled == other.enabled &&
          isVisible == other.isVisible &&
          onlyHub == other.onlyHub &&
          allowEmpty == other.allowEmpty;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode =>
      name.hashCode ^
      service.hashCode ^
      type.hashCode ^
      hint.hashCode ^
      error.hashCode ^
      regExp.hashCode ^
      help.hashCode ^
      advanced.hashCode ^
      inTunePage.hashCode ^
      protected.hashCode ^
      enabled.hashCode ^
      isVisible.hashCode ^
      onlyHub.hashCode ^
      allowEmpty.hashCode;

  static final Map<String, LAVariableDesc> map = <String, LAVariableDesc>{
    'ansible_user': LAVariableDesc(
      name: 'Default user in your servers',
      nameInt: 'ansible_user',
      regExp: LARegExp.username,
      error: 'Invalid username',
      help: 'Before-Start-Your-LA-Installation#default-user-ubuntu',
      // We moved "ansible_user" to the servers definition
      defValue: (LAProject project) => 'ubuntu',
      inTunePage: false,
      hint:
          "The user name that we'll use to access to your servers with sudo passwordless permission. By default 'ubuntu'",
    ),
    'map_zone_name': LAVariableDesc(
      name: 'Short name of that map area',
      nameInt: 'map_zone_name',
      regExp: LARegExp.projectNameRegexp,
      help: 'Glossary#map-area-name',
      error: 'Name of the map area invalid.',
      hint: "For e.g.: 'Australia', 'Brazil', 'United Kingdom', ...",
      inTunePage: false,
    ),
    'biocache_query_context': LAVariableDesc(
      name: 'Biocache Query Context',
      nameInt: 'biocache_query_context',
      defValue: (LAProject project) => 'data_hub_uid:dh1',
      regExp: LARegExp.something,
      help: 'Data-Hub#configure-the-web-app-to-show-the-records-of-the-new-hub',
      error: 'Invalid Hub Biocache Query Context',
      onlyHub: true,
      allowEmpty: false,
      hint:
          'Something like data_hub_uid:dh1 or cl1:"Some Region Name" does limits the query of your Portal to that Hub or Region,...',
    ),
    'support_email': LAVariableDesc(
      name: 'Support email',
      nameInt: 'support_email',
      regExp: LARegExp.email,
      error: 'Invalid email',
      defValue: (LAProject project) => 'support@${project.domain}',
      hint: 'Something like support@l-a.site',
    ),
    'orgEmail': LAVariableDesc(
      name: 'Contact email',
      nameInt: 'orgEmail',
      regExp: LARegExp.email,
      error: 'Invalid email',
      defValue: (LAProject project) => 'info@${project.domain}',
      hint: 'Something like info@l-a.site',
    ),
    'email_sender': LAVariableDesc(
      name: 'Email sender',
      nameInt: 'email_sender',
      regExp: LARegExp.email,
      error: 'Invalid email',
      defValue: (LAProject project) => 'noreply@${project.domain}',
      hint:
          'Used by some notifications. Should be something like noreply@l-a.site',
    ),
    'email_sender_password': LAVariableDesc(
      name: 'Email password',
      nameInt: 'email_sender_password',
      regExp: LARegExp.anything,
      error: 'Invalid password',
      inTunePage: false,
      protected: true,
      hint:
          'The email password of the previous email sender. This user/password should exist in that email server',
    ),
    'email_sender_server': LAVariableDesc(
      name: 'Email server',
      nameInt: 'email_sender_server',
      regExp: LARegExp.domainRegexp,
      error: 'Invalid email server',
      inTunePage: false,
      // defValue: (project) => 'mailserver.${project.domain}',
      hint:
          'Used to send LA portal notifications. The previous account should exists in this server.',
    ),
    'email_sender_server_port': LAVariableDesc(
      name: 'Email server port',
      nameInt: 'email_sender_server_port',
      regExp: LARegExp.int,
      error: 'Invalid email server port',
      inTunePage: false,
      defValue: (LAProject project) => '587',
      hint: 'usually 25 or 587',
    ),
    'email_sender_server_tls': LAVariableDesc(
      name: 'The server use TLS?',
      nameInt: 'email_sender_server_tls',
      // regExp: LARegExp.int,
      // error: "Invalid email server port",
      inTunePage: false,
      defValue: (LAProject project) => true,
      type: LAVariableType.bool,
      hint: 'usually 25 or 587',
    ),
    /* "header_and_footer_baseurl": LAVariableDesc(
      name: "Headers and Footer Base URL",
      nameInt: "header_and_footer_baseurl",
      regExp: LARegExp.url,
      error: "Invalid url",
      help: "Styling-the-web-app",
      defValue: (LAProject project) => (project
          .getServiceE(LAServiceName.branding)
          .fullUrl(project.useSSL, project.domain)),
      hint: "Like: https://www.ala.org.au/commonui-bs3",
    ), */
    'downloads_terms_of_use': LAVariableDesc(
      name: 'Terms of Use URL',
      nameInt: 'downloads_terms_of_use',
      regExp: LARegExp.url,
      error: 'Invalid url',
      hint: 'Like: https://www.ala.org.au/about-the-atlas/terms-of-use/',
    ),
    'privacy_policy_url': LAVariableDesc(
      name: 'Privacy Policy URL',
      nameInt: 'privacy_policy_url',
      regExp: LARegExp.url,
      error: 'Invalid url',
      hint: 'Like: https://www.ala.org.au/about/terms-of-use/privacy-policy/',
    ),
    'favicon_url': LAVariableDesc(
      name: 'Favicon',
      nameInt: 'favicon_url',
      regExp: LARegExp.url,
      error: 'Invalid url',
      defValue: (_) =>
          'https://raw.githubusercontent.com/living-atlases/artwork/master/favicon.ico',
      hint: 'Like: https://www.gbif.org/favicon.ico',
    ),
    'orgAddress': LAVariableDesc(
      name: 'Organization address',
      regExp: LARegExp.anything,
      nameInt: 'orgAddress',
      hint: 'like: Clunies Ross Street, ...',
      help: 'Glossary#organization-address',
      subcategory: LAVariableSubcategory.org,
    ),
    'orgCity': LAVariableDesc(
      name: 'City',
      nameInt: 'orgCity',
      hint: 'like: Camberra, Madrid, Lisboa, ...',
      regExp: LARegExp.anything,
      subcategory: LAVariableSubcategory.org,
    ),
    'orgStateProvince': LAVariableDesc(
      name: 'State/Province',
      nameInt: 'orgStateProvince',
      regExp: LARegExp.anything,
      subcategory: LAVariableSubcategory.org,
    ),
    'orgPostcode': LAVariableDesc(
      name: 'Postcode',
      nameInt: 'orgPostcode',
      regExp: LARegExp.anything,
      subcategory: LAVariableSubcategory.org,
    ),
    'orgCountry': LAVariableDesc(
      name: 'Country',
      nameInt: 'orgCountry',
      regExp: LARegExp.anything,
      defValue: (LAProject project) =>
          project.getVariableValue('map_zone_name'),
      subcategory: LAVariableSubcategory.org,
    ),
    'google_api_key': LAVariableDesc(
      name: 'Google Maps API Key',
      nameInt: 'google_api_key',
      subcategory: LAVariableSubcategory.apikeys,
      hint: 'Like: AIzaBcDeFgHiJkLmNoPqRsTuVwXyZ',
    ),
    'caches_collections_enabled': LAVariableDesc(
      name: 'Enable Collections Cache',
      nameInt: 'caches_collections_enabled',
      subcategory: LAVariableSubcategory.cache,
      defValue: (_) => true,
      advanced: true,
      hint:
          'By default caches are disabled: the collections cache is problematic when collectory + occurrences-front-end (biocache-hub) are on same server)',
      help: 'FAQ#collectory-cache-issues',
      type: LAVariableType.bool,
    ),
    'caches_auth_enabled': LAVariableDesc(
      name: 'Enable Authentication Cache',
      nameInt: 'caches_auth_enabled',
      subcategory: LAVariableSubcategory.cache,
      defValue: (_) => true,
      depends: LAServiceName.cas,
      advanced: true,
      type: LAVariableType.bool,
    ),
    'caches_logs_enabled': LAVariableDesc(
      name: 'Enable Logs Cache',
      nameInt: 'caches_logs_enabled',
      subcategory: LAVariableSubcategory.cache,
      defValue: (_) => true,
      advanced: true,
      type: LAVariableType.bool,
    ),
    'caches_layers_enabled': LAVariableDesc(
      name: 'Enable Layers Cache',
      defValue: (_) => true,
      advanced: true,
      depends: LAServiceName.spatial,
      nameInt: 'caches_layers_enabled',
      subcategory: LAVariableSubcategory.cache,
      type: LAVariableType.bool,
    ),
    'enable_data_quality': LAVariableDesc(
      name: 'Enable Data Profiles Quality filter of occurrences?',
      nameInt: 'enable_data_quality',
      subcategory: LAVariableSubcategory.dataQuality,
      depends: LAServiceName.data_quality,
      service: LAServiceName.ala_hub,
      defValue: (_) => false,
      help:
          'https://support.ala.org.au/support/solutions/articles/6000240256-getting-started-with-the-data-quality-filters',
      type: LAVariableType.bool,
    ),
    'enable_events': LAVariableDesc(
      name: 'Enable Events ~ Extended Data Model (in development)?',
      nameInt: 'enable_events',
      subcategory: LAVariableSubcategory.events,
      depends: LAServiceName.events,
      service: LAServiceName.ala_hub,
      defValue: (_) => false,
      help: 'https://ala.org.au/current-projects/extended-data-model-project/',
      type: LAVariableType.bool,
    ),
    'maxmind_account_id': LAVariableDesc(
      name: 'MaxMind Account ID',
      nameInt: 'maxmind_account_id',
      subcategory: LAVariableSubcategory.apikeys,
      service: LAServiceName.ala_hub,
      help: 'API-Keys#non-ala-keys',
      hint: 'Something like: 978657',
    ),
    'maxmind_license_key': LAVariableDesc(
      name: 'MaxMind License Key',
      nameInt: 'maxmind_license_key',
      subcategory: LAVariableSubcategory.apikeys,
      service: LAServiceName.ala_hub,
      hint: 'Something like: UKDDas3bGKJ9VuuL',
    ),
    'mapbox_access_token': LAVariableDesc(
      name: 'Mapbox Access Token',
      nameInt: 'mapbox_access_token',
      subcategory: LAVariableSubcategory.apikeys,
      service: LAServiceName.collectory,
      hint: 'Something like: pk.XXXXXXXXXX',
    ),
    'oidc_use': LAVariableDesc(
      name: 'Use OIDC instead of CAS Auth?',
      nameInt: 'oidc_use',
      //  subcategory: LAVariableSubcategory.otherKeys,
      help: 'OIDC',
      depends: LAServiceName.cas,
      service: LAServiceName.cas,
      defValue: (_) => true,
      type: LAVariableType.bool,
    ),
    'jwt_in_use': LAVariableDesc(
      name: 'Use JWT for incoming requests?',
      nameInt: 'jwt_in_use',
      depends: LAServiceName.cas,
      service: LAServiceName.cas,
      defValue: (_) => true,
      help:
          'https://github.com/AtlasOfLivingAustralia/ala-security-project/tree/develop/ala-ws-security-plugin',
      type: LAVariableType.bool,
    ),
    'jwt_out_use': LAVariableDesc(
      name: 'Use JWT for outgoing requests? (experimental)',
      nameInt: 'jwt_out_use',
      depends: LAServiceName.cas,
      service: LAServiceName.cas,
      defValue: (_) => false,
      help:
          'https://github.com/AtlasOfLivingAustralia/ala-security-project/tree/develop/ala-ws-plugin#external-configuration-properties',
      type: LAVariableType.bool,
    ),
    'pac4j_cookie_signing_key': LAVariableDesc(
      name: 'CAS PAC4J Signing key',
      nameInt: 'pac4j_cookie_signing_key',
      subcategory: LAVariableSubcategory.otherKeys,
      help: 'CAS-postinstall-steps#cas-keys',
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'pac4j_cookie_encryption_key': LAVariableDesc(
      name: 'CAS PAC4J Encryption key',
      nameInt: 'pac4j_cookie_encryption_key',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'cas_webflow_signing_key': LAVariableDesc(
      name: 'CAS Webflow Signing key',
      nameInt: 'cas_webflow_signing_key',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'cas_webflow_encryption_key': LAVariableDesc(
      name: 'CAS Webflow Encryption key',
      nameInt: 'cas_webflow_encryption_key',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'cas_oauth_signing_key': LAVariableDesc(
      name: 'CAS OAuth Signing key',
      nameInt: 'cas_oauth_signing_key',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'cas_oauth_encryption_key': LAVariableDesc(
      name: 'CAS OAuth Encryption key',
      nameInt: 'cas_oauth_encryption_key',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'cas_oauth_access_token_signing_key': LAVariableDesc(
      name: 'CAS OAuth Access Token Signing key',
      nameInt: 'cas_oauth_access_token_signing_key',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'cas_oauth_access_token_encryption_key': LAVariableDesc(
      name: 'CAS OAUth Access Token Encryption key',
      nameInt: 'cas_oauth_access_token_encryption_key',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.cas,
      advanced: true,
      service: LAServiceName.cas,
    ),
    'sds_faq_url': LAVariableDesc(
      name: 'SDS FAQ web page',
      nameInt: 'sds_faq_url',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.sds,
      service: LAServiceName.sds,
      hint:
          'Typically a link to a web page describing the SDS service and how it works',
      defValue: (_) => 'https://www.ala.org.au/faq/data-sensitivity/',
    ),
    'sds_spatial_layers': LAVariableDesc(
      name: 'SDS Spatial Layers',
      nameInt: 'sds_spatial_layers',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.sds,
      service: LAServiceName.sds,
      defValue: (_) =>
          'cl932,cl927,cl23,cl937,cl941,cl938,cl939,cl936,cl940,cl963,cl962,cl961,cl960,cl964,cl965,cl22,cl10925',
    ),
    'sds_flag_rules': LAVariableDesc(
      name: 'SDS Flag Rules',
      nameInt: 'sds_flag_rules',
      subcategory: LAVariableSubcategory.otherKeys,
      depends: LAServiceName.sds,
      service: LAServiceName.sds,
      defValue: (_) => 'PBC7,PBC8,PBC9',
    ),
    'pipelines_master': LAVariableDesc(
      name: 'Pipelines master server',
      nameInt: 'pipelines_master',
      subcategory: LAVariableSubcategory.pipelines,
      depends: LAServiceName.pipelines,
      service: LAServiceName.pipelines,
      defValue: (LAProject p) {
        final List<String> options = <String>[];
        for (final LAServiceDeploy sd in p.getServiceDeploysForSomeService(
          LAServiceName.pipelines.toS(),
        )) {
          String? sId = sd.serverId;
          if (sId == null && sd.clusterId != null) {
            final LACluster? cluster = p.clusters.firstWhereOrNull(
              (LACluster c) => c.id == sd.clusterId,
            );
            sId = cluster?.serverId;
          }

          if (sId != null) {
            final LAServer? server = p.servers.firstWhereOrNull(
              (LAServer s) => s.id == sId,
            );
            if (server != null && !options.contains(server.name)) {
              options.add(server.name);
            }
          }
        }
        return options;
      },
      type: LAVariableType.select,
    ),
    'pipelines_jenkins_use': LAVariableDesc(
      name: 'Use Jenkins with pipelines?',
      nameInt: 'pipelines_jenkins_use',
      subcategory: LAVariableSubcategory.pipelines,
      depends: LAServiceName.pipelines,
      service: LAServiceName.pipelines,
      defValue: (_) => false,
      type: LAVariableType.bool,
    ),
    'branding_source': LAVariableDesc(
      name: 'Source for the branding',
      nameInt: 'branding_source',
      subcategory: LAVariableSubcategory.dockerCompose,
      service: LAServiceName.docker_compose,
      depends: LAServiceName.docker_compose,
      regExp: LARegExp.anything,
      defValue: (LAProject project) =>
          '../${project.shortName.toLowerCase().replaceFirst('la ', '').replaceAll(' ', '-')}-branding',
      hint:
          'Can be a directory or a git address. By default ../<project-short-name>-branding/. If a git address is used, it will be cloned and built.',
    ),
    'use_la_site_certs': LAVariableDesc(
      name: 'Use l-a.site certificates?',
      nameInt: 'use_la_site_certs',
      subcategory: LAVariableSubcategory.dockerCompose,
      service: LAServiceName.docker_compose,
      depends: LAServiceName.docker_compose,
      defValue: (_) => false,
      type: LAVariableType.bool,
      help:
          'https://github.com/AtlasOfLivingAustralia/documentation/wiki/Before-Start-Your-LA-Installation',
      hint:
          'Only useful for demos using a subdomain of l-a.site. Docker-compose will download and use SSL certificates automatically and auto-configure the portal with SSL.',
    ),
    'docker_mail_development_mode': LAVariableDesc(
      name: 'Enable mail development mode?',
      nameInt: 'docker_mail_development_mode',
      subcategory: LAVariableSubcategory.dockerCompose,
      service: LAServiceName.docker_compose,
      depends: LAServiceName.docker_compose,
      defValue: (_) => false,
      type: LAVariableType.bool,
      hint:
          'Useful for test portals to monitor if emails are being sent correctly without using a real email server.',
    ),
    'docker_mail_development_url': LAVariableDesc(
      name: 'Mail development URL',
      nameInt: 'docker_mail_development_url',
      subcategory: LAVariableSubcategory.dockerCompose,
      service: LAServiceName.docker_compose,
      depends: LAServiceName.docker_compose,
      defValue: (LAProject project) => 'mail.${project.domain}',
      regExp: LARegExp.domainRegexp,
      isVisible: (LAProject project) =>
          project.getVariableValue('docker_mail_development_mode') as bool? ??
          false,
      hint:
          'URL for the test mail server (e.g., mailhog.l-a.site) where you can monitor sent emails.',
    ),
  };

  static LAVariableDesc get(String nameInt) {
    return map[nameInt]!;
  }
}
