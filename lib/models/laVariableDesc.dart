import 'package:flutter/foundation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/regexp.dart';

enum LAVariableType { String, int, double, bool }

class LAVariableDesc {
  String name;
  String nameInt;
  LAServiceName service;
  LAVariableType type;
  String hint;
  String error;
  RegExp regExp;
  String help;
  List<String> ansibleEquiv;
  Function defValue;
  String confName;
  bool
      internal; // used by non ALA code to, for instance, generate inventories,...
  bool enabled;

  LAVariableDesc(
      {@required this.name,
      @required this.nameInt,
      this.service = LAServiceName.all,
      this.type = LAVariableType.String,
      List<String> ansibleEquiv,
      this.hint,
      this.error,
      this.regExp,
      this.help,
      this.confName,
      this.defValue,
      this.internal = false,
      this.enabled = true})
      : ansibleEquiv = ansibleEquiv ?? [nameInt];

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
          ansibleEquiv == other.ansibleEquiv &&
          confName == other.confName &&
          internal == other.internal &&
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
      ansibleEquiv.hashCode ^
      confName.hashCode ^
      internal.hashCode ^
      enabled.hashCode;

  static final Map<String, LAVariableDesc> map = {
    "ansible_user": LAVariableDesc(
        name: "Default user in your servers",
        nameInt: "ansible_user",
        regExp: LARegExp.username,
        error: "Invalid username",
        help: "Before-Start-Your-LA-Installation#default-user-ubuntu",
        hint:
            "The user name that we'll use to access to your servers with sudo passwordless permission. By default 'ubuntu'"),
    "support_email": LAVariableDesc(
        name: "Support email",
        nameInt: "support_email",
        ansibleEquiv: [
          "technical_contact",
          "orgSupportEmail",
          "support_email"
              "download_support_email"
        ],
        regExp: LARegExp.email,
        error: "Invalid email",
        defValue: (project) => 'support@${project.domain}',
        hint: "Something like support@l-a.site"),
    "orgEmail": LAVariableDesc(
        name: "Contact email",
        nameInt: "orgEmail",
        regExp: LARegExp.email,
        error: "Invalid email",
        defValue: (project) => 'info@${project.domain}',
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
      hint: "Like: https://www.ala.org.au/commonui-bs3",
    ),
    "downloads_terms_of_use": LAVariableDesc(
      name: "Terms of Use URL",
      nameInt: "downloads_terms_of_use",
      regExp: LARegExp.url,
      error: "Invalid url",
      hint: "Like: https://www.ala.org.au/about-the-atlas/terms-of-use/",
    ),
    "favicon_url": LAVariableDesc(
      name: "Favicon",
      nameInt: "favicon_url",
      regExp: LARegExp.url,
      error: "Invalid url",
      hint: "Like: https://www.gbif.org/favicon.ico",
    ),
    "google_api_key": LAVariableDesc(
        name: "Google Maps API Key",
        nameInt: "google_api_key",
        ansibleEquiv: ["google_api_key", "google_apikey"],
        hint: "Like: AIzaBcDeFgHiJkLmNoPqRsTuVwXyZ"),
    "caches_auth_enabled": LAVariableDesc(
        name: "Enable Authentication Cache",
        nameInt: "caches_auth_enabled",
        defValue: (_) => false,
        type: LAVariableType.bool),
    "caches_logs_enabled": LAVariableDesc(
        name: "Enable Logs Cache",
        nameInt: "caches_logs_enabled",
        defValue: (_) => false,
        type: LAVariableType.bool),
    "caches_collections_enabled": LAVariableDesc(
        name: "Enable Collections Cache",
        nameInt: "caches_collections_enabled",
        defValue: (_) => false,
        hint:
            "By default caches are disabled (the collections cache is problematic when collectory + biocache on same server)",
        help: "FAQ#collectory-cache-issues",
        type: LAVariableType.bool),
    "caches_layers_enabled": LAVariableDesc(
        name: "Enable Layers Cache",
        defValue: (_) => false,
        nameInt: "caches_layers_enabled",
        type: LAVariableType.bool),
    "maxmind_account_id": LAVariableDesc(
        name: "MaxMind Account ID",
        nameInt: "maxmind_account_id",
        service: LAServiceName.ala_hub,
        help: "API-Keys#non-ala-keys",
        hint: "Something like: 978657"),
    "maxmind_account_key": LAVariableDesc(
        name: "MaxMind Account Key",
        nameInt: "maxmind_account_key",
        service: LAServiceName.ala_hub,
        hint: "Something like: UKDDas3bGKJ9VuuL")
  };
  static LAVariableDesc get(String nameInt) {
    return map[nameInt];
  }
}
