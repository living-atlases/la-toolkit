import 'package:flutter/foundation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/regexp.dart';

enum LAVariableType { String, int, double }

class LAVariableDesc {
  String name;
  LAServiceName service;
  LAVariableType type;
  String hint;
  String error;
  RegExp regExp;
  String help;
  List<String> ansibleEquiv;
  String confName;
  bool
      internal; // used by non ALA code to, for instance, generate inventories,...
  bool enabled;

  LAVariableDesc(
      {@required this.name,
      this.service = LAServiceName.all,
      this.type = LAVariableType.String,
      this.ansibleEquiv,
      this.hint,
      this.error,
      this.regExp,
      this.help,
      this.confName,
      this.internal = false,
      this.enabled = true});

  static final Map<String, List<LAVariableDesc>> map = {
    LAServiceName.all.toS(): [
      LAVariableDesc(
          name: "Support email",
          ansibleEquiv: [
            "technical_contact",
            "orgSupportEmail",
            "support_email"
                "download_support_email"
          ],
          regExp: LARegExp.email,
          error: "Invalid email",
          hint: "Something like support@l-a.site"),
      LAVariableDesc(
          name: "Contact email",
          ansibleEquiv: [],
          regExp: LARegExp.email,
          error: "Invalid email",
          hint: "Something like info@l-a.site"),
      LAVariableDesc(
          name: "Email sender",
          ansibleEquiv: ['email_sender'],
          regExp: LARegExp.email,
          error: "Invalid email",
          hint:
              "Used by some notifications. Should be something like noreply@l-a.site"),
      LAVariableDesc(
        name: "Headers and Footer Base URL",
        ansibleEquiv: ["header_and_footer_baseurl"],
        regExp: LARegExp.url,
        error: "Invalid url",
        hint: "Like: https://www.ala.org.au/commonui-bs3",
      ),
      LAVariableDesc(
        name: "Terms of Use URL",
        ansibleEquiv: ["downloads_terms_of_use"],
        regExp: LARegExp.url,
        error: "Invalid url",
        hint: "Like: https://www.ala.org.au/about-the-atlas/terms-of-use/",
      ),
      LAVariableDesc(
        name: "Favicon",
        ansibleEquiv: ["favicon_url"],
        regExp: LARegExp.url,
        error: "Invalid url",
        hint: "Like: https://www.gbif.org/favicon.ico",
      ),
    ],
    LAServiceName.ala_hub.toS(): [
      LAVariableDesc(
          name: "MaxMind Account ID",
          ansibleEquiv: ["maxmind_account_id"],
          help: "API-Keys#non-ala-keys",
          hint: "Something like: 978657"),
      LAVariableDesc(
          name: "MaxMind Account Key",
          ansibleEquiv: ["maxmind_account_key"],
          hint: "Something like: UKDDas3bGKJ9VuuL")
    ]
  };
}
