import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_variable_desc.dart';

void main() {
  test('Test mail development URL default value based on domain', () {
    final LAProject project = LAProject(domain: 'example.org');

    // Check default value for mail URL
    final Object? mailUrl = project.getVariableValue(
      'docker_mail_development_url',
    );
    expect(mailUrl, equals('mail.example.org'));

    // Note: getVariableValue persists the value in project.variables once calculated.
    // If we want to check a different domain, we need a new project or clear the variable.
    final LAProject project2 = LAProject(domain: 'myatlas.com');
    expect(
      project2.getVariableValue('docker_mail_development_url'),
      equals('mail.myatlas.com'),
    );
  });

  test('Test mail development URL visibility', () {
    final LAProject project = LAProject(domain: 'example.org');
    final LAVariableDesc varDesc = LAVariableDesc.get(
      'docker_mail_development_url',
    );

    // Default should be invisible (mode is false)
    expect(project.getVariableValue('docker_mail_development_mode'), isFalse);
    expect(varDesc.isVisible!(project), isFalse);

    // Enable mail development mode
    project.setVariable(
      LAVariableDesc.get('docker_mail_development_mode'),
      true,
    );

    // Should be visible now
    expect(project.getVariableValue('docker_mail_development_mode'), isTrue);
    expect(varDesc.isVisible!(project), isTrue);
  });
}
