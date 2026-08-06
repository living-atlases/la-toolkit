import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_variable_desc.dart';

void main() {
  test('branding_as_home defaults to true so old projects do not change', () {
    final LAProject project = LAProject(domain: 'gbif.es');

    expect(project.getVariableValue('branding_as_home'), isTrue);
  });

  test('branding_as_home question and hint name the project domain', () {
    final LAProject project = LAProject(domain: 'gbif.es');
    final LAVariableDesc varDesc = LAVariableDesc.get('branding_as_home');

    expect(
      LAVariableDesc.resolve(varDesc.name, project),
      equals('Does this Atlas serve the home page of gbif.es?'),
    );
    expect(LAVariableDesc.resolve(varDesc.hint, project), contains('gbif.es'));
    expect(
      LAVariableDesc.resolve(varDesc.hint, project),
      isNot(contains('{domain}')),
    );
  });
}
