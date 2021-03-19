// @dart=2.9
import 'package:flutter/foundation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/regexp.dart';

import 'laProject.dart';

enum LAVariableType { String, int, double, bool }

enum LAVariableSubcategory { org, cache, downloads, apikeys, otherkeys, ssl }

extension LAVariableSucategoryTitleExtension on LAVariableSubcategory {
  String get title {
    switch (this) {
      case LAVariableSubcategory.org:
        return 'Organization details';
      case LAVariableSubcategory.cache:
        return 'Cache';
      case LAVariableSubcategory.downloads:
        return 'Downloads';
      case LAVariableSubcategory.ssl:
        return 'SSL';
      case LAVariableSubcategory.apikeys:
        return 'API Keys';
      case LAVariableSubcategory.otherkeys:
        return 'Other keys';
      default:
        return null;
    }
  }
}

class LAVariableDesc {
  String name;
  String nameInt;
  LAServiceName service;
  LAVariableSubcategory subcategory;
  LAVariableType type;
  String hint;
  String error;
  RegExp regExp;
  String help;
  LAServiceName depends;
  Function defValue;
  String confName;
  bool advanced;
  bool enabled;
  bool inTunePage;

  LAVariableDesc(
      {@required this.name,
      @required this.nameInt,
      this.service = LAServiceName.all,
      this.subcategory,
      this.type = LAVariableType.String,
      this.hint,
      this.error,
      this.regExp,
      this.help,
      this.confName,
      this.defValue,
      this.depends,
      this.inTunePage = true,
      this.advanced = false,
      this.enabled = true});

  @override
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
          confName == other.confName &&
          advanced == other.advanced &&
          inTunePage == other.inTunePage &&
          enabled == other.enabled;

  @override
  int get hashCode =>
      name.hashCode ^
      service.hashCode ^
      type.hashCode ^
      hint.hashCode ^
      error.hashCode ^
      regExp.hashCode ^
      help.hashCode ^
      confName.hashCode ^
      advanced.hashCode ^
      inTunePage.hashCode ^
      enabled.hashCode;

  static final Map<String, LAVariableDesc> map = {
    "ansible_user": LAVariableDesc(
        name: "Default user in your servers",
        nameInt: "ansible_user",
        regExp: LARegExp.username,
        error: "Invalid username",
        help: "Before-Start-Your-LA-Installation#default-user-ubuntu",
        // We moved "ansible_user" to the servers definition
        inTunePage: false,
        hint:
            "The user name that we'll use to access to your servers with sudo passwordless permission. By default 'ubuntu'"),
    "map_zone_name": LAVariableDesc(
        name: 'Short name of that map area',
        nameInt: "map_zone_name",
        regExp: LARegExp.projectNameRegexp,
        help: "Glossary#map-area-name",
        error: 'Name of the map area invalid.',
        hint: "For e.g.: 'Australia', 'Vermont', 'United Kingdom', ...",
        inTunePage: false),
    "support_email": LAVariableDesc(
        name: "Support email",
        nameInt: "support_email",
        regExp: LARegExp.email,
        error: "Invalid email",
        defValue: (project) => 'support@${project.domain}',
        hint: "Something like support@l-a.site"),
    "orgEmail": LAVariableDesc(
        name: "Contact email",
        nameInt: "orgEmail",
        regExp: LARegExp.email,
        error: "Invalid email",
        defValue: (LAProject project) => 'info@${project.domain}',
        hint: "Something like info@l-a.site"),
    "email_sender": LAVariableDesc(
        name: "Email sender",
        nameInt: "email_sender",
        regExp: LARegExp.email,
        error: "Invalid email",
        defValue: (project) => 'noreply@${project.domain}',
        hint:
            "Used by some notifications. Should be something like noreply@l-a.site"),
    "header_and_footer_baseurl": LAVariableDesc(
      name: "Headers and Footer Base URL",
      nameInt: "header_and_footer_baseurl",
      regExp: LARegExp.url,
      error: "Invalid url",
      help: "Styling-the-web-app",
      defValue: (LAProject project) => (project
          .getServiceE(LAServiceName.branding)
          .fullUrl(project.useSSL, project.domain)),
      hint: "Like: https://www.ala.org.au/commonui-bs3",
    ),
    "downloads_terms_of_use": LAVariableDesc(
      name: "Terms of Use URL",
      nameInt: "downloads_terms_of_use",
      regExp: LARegExp.url,
      error: "Invalid url",
      hint: "Like: https://www.ala.org.au/about-the-atlas/terms-of-use/",
    ),
    "privacy_policy_url": LAVariableDesc(
      name: "Privacy Policy URL",
      nameInt: "privacy_policy_url",
      regExp: LARegExp.url,
      error: "Invalid url",
      hint: "Like: https://www.ala.org.au/about/terms-of-use/privacy-policy/",
    ),
    "favicon_url": LAVariableDesc(
      name: "Favicon",
      nameInt: "favicon_url",
      regExp: LARegExp.url,
      error: "Invalid url",
      defValue: (_) => 'https://www.gbif.org/favicon.ico',
      hint: "Like: https://www.gbif.org/favicon.ico",
    ),
    "orgAddress": LAVariableDesc(
        name: "Organization address",
        regExp: LARegExp.anyThing,
        nameInt: "orgAddress",
        hint: "like: Clunies Ross Street, ...",
        help: "Glossary#organization-address",
        subcategory: LAVariableSubcategory.org),
    "orgCity": LAVariableDesc(
        name: "City",
        nameInt: "orgCity",
        hint: 'like: Camberra, Madrid, Lisboa, ...',
        regExp: LARegExp.anyThing,
        subcategory: LAVariableSubcategory.org),
    "orgStateProvince": LAVariableDesc(
        name: "State/Province",
        nameInt: "orgStateProvince",
        regExp: LARegExp.anyThing,
        subcategory: LAVariableSubcategory.org),
    "orgPostcode": LAVariableDesc(
        name: "Postcode",
        nameInt: "orgPostcode",
        regExp: LARegExp.anyThing,
        subcategory: LAVariableSubcategory.org),
    "orgCountry": LAVariableDesc(
        name: "Country",
        nameInt: "orgCountry",
        regExp: LARegExp.anyThing,
        defValue: (LAProject project) =>
            project.getVariable('map_zone_name').value,
        subcategory: LAVariableSubcategory.org),
    "google_api_key": LAVariableDesc(
        name: "Google Maps API Key",
        nameInt: "google_api_key",
        subcategory: LAVariableSubcategory.apikeys,
        hint: "Like: AIzaBcDeFgHiJkLmNoPqRsTuVwXyZ"),
    "caches_collections_enabled": LAVariableDesc(
        name: "Enable Collections Cache",
        nameInt: "caches_collections_enabled",
        subcategory: LAVariableSubcategory.cache,
        defValue: (_) => true,
        advanced: true,
        hint:
            "By default caches are disabled: the collections cache is problematic when collectory + occurrences-front-end (biocache-hub) are on same server)",
        help: "FAQ#collectory-cache-issues",
        type: LAVariableType.bool),
    "caches_auth_enabled": LAVariableDesc(
        name: "Enable Authentication Cache",
        nameInt: "caches_auth_enabled",
        subcategory: LAVariableSubcategory.cache,
        defValue: (_) => true,
        depends: LAServiceName.cas,
        advanced: true,
        type: LAVariableType.bool),
    "caches_logs_enabled": LAVariableDesc(
        name: "Enable Logs Cache",
        nameInt: "caches_logs_enabled",
        subcategory: LAVariableSubcategory.cache,
        defValue: (_) => true,
        advanced: true,
        type: LAVariableType.bool),
    "caches_layers_enabled": LAVariableDesc(
        name: "Enable Layers Cache",
        defValue: (_) => true,
        advanced: true,
        depends: LAServiceName.spatial,
        nameInt: "caches_layers_enabled",
        subcategory: LAVariableSubcategory.cache,
        type: LAVariableType.bool),
    "maxmind_account_id": LAVariableDesc(
        name: "MaxMind Account ID",
        nameInt: "maxmind_account_id",
        subcategory: LAVariableSubcategory.apikeys,
        service: LAServiceName.ala_hub,
        help: "API-Keys#non-ala-keys",
        hint: "Something like: 978657"),
    "maxmind_license_key": LAVariableDesc(
        name: "MaxMind License Key",
        nameInt: "maxmind_license_key",
        subcategory: LAVariableSubcategory.apikeys,
        service: LAServiceName.ala_hub,
        hint: "Something like: UKDDas3bGKJ9VuuL"),
    "pac4j_cookie_signing_key": LAVariableDesc(
        name: "CAS PAC4J Signing key",
        nameInt: "pac4j_cookie_signing_key",
        subcategory: LAVariableSubcategory.otherkeys,
        help: "CAS-postinstall-steps#cas-keys",
        depends: LAServiceName.cas,
        advanced: true,
        service: LAServiceName.cas),
    "pac4j_cookie_encryption_key": LAVariableDesc(
        name: "CAS PAC4J Encryption key",
        nameInt: "pac4j_cookie_encryption_key",
        subcategory: LAVariableSubcategory.otherkeys,
        depends: LAServiceName.cas,
        advanced: true,
        service: LAServiceName.cas),
    "cas_webflow_signing_key": LAVariableDesc(
        name: "CAS Webflow Signing key",
        nameInt: "cas_webflow_signing_key",
        subcategory: LAVariableSubcategory.otherkeys,
        depends: LAServiceName.cas,
        advanced: true,
        service: LAServiceName.cas),
    "cas_webflow_encryption_key": LAVariableDesc(
        name: "CAS Webflow Encryption key",
        nameInt: "cas_webflow_encryption_key",
        subcategory: LAVariableSubcategory.otherkeys,
        depends: LAServiceName.cas,
        advanced: true,
        service: LAServiceName.cas)
  };
  static LAVariableDesc get(String nameInt) {
    return map[nameInt];
  }
}
