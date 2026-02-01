import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_desc.dart';

void checkServices(LAProject p, List<String> notUsedServices) {
  for (final LAServiceDesc service in LAServiceDesc.list(p.isHub)) {
    if (notUsedServices.contains(service.nameInt)) {
      expect(
        p.getService(service.nameInt).use,
        equals(false),
        reason: '${service.nameInt} should not be in Use',
      );
    } else {
      expect(
        p.getService(service.nameInt).use,
        equals(true),
        reason: '${service.nameInt} should be in Use',
      );
      if (!service.withoutUrl && service.nameInt != branding) {
        // print('${service.nameInt} ${p.getService(service.nameInt).usesSubdomain}');
        // TODO(vjrj): fix this
        /* expect(
          p.getService(service.nameInt).usesSubdomain,
          equals(!notUsedServices.contains(service.nameInt))
        ); */
      }
    }
  }
}
