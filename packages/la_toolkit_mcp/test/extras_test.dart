import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

void main() {
  // What the Tune page writes for a hub: rules, titles, and a section per
  // service, commented out while the service is not in use.
  const String tuned = '''
#####  Other variables common to all services  ###############
[hub-marinas:vars]

# End of common variables
################################################################

#####  Regions (regions) extra variables  #####################
[regions-marinas:vars]
menu_config_json = {{ inventory_dir }}/files/regions-menu-config.json

# End of Regions variables
################################################################

#####  Species (ala_bie) extra variables  #####################
# [ala-bie-marinas:vars] #uncomment this line if you enable this service
################################################################
''';

  test('sections keep their order, commented ones included', () {
    expect(extrasSections(tuned), <String>[
      '[hub-marinas:vars]',
      '[regions-marinas:vars]',
      '# [ala-bie-marinas:vars]',
    ]);
    expect(extrasSections(''), isEmpty);
  });

  test('the diff names the lines that come and go, not the decoration', () {
    final Json d = extrasDiff(
      tuned,
      tuned.replaceAll(
        'files/regions-menu-config.json',
        '../gbif-es/files/regions-menu-config.json',
      ),
    );
    expect(d['removed'], <String>[
      'menu_config_json = {{ inventory_dir }}/files/regions-menu-config.json',
    ]);
    expect(d['added'], <String>[
      'menu_config_json = '
          '{{ inventory_dir }}/../gbif-es/files/regions-menu-config.json',
    ]);
    // The rules and titles moved with the text and say nothing: left out.
    expect((d['sections'] as Json)['before'], (d['sections'] as Json)['after']);
  });

  test('reflowing the text alone shows no change', () {
    final Json d = extrasDiff(tuned, '$tuned\n\n####\n');
    expect(d['removed'], isEmpty);
    expect(d['added'], isEmpty);
  });

  test('a line dropped twice is reported twice', () {
    const String twice = 'a = 1\na = 1\nb = 2\n';
    final Json d = extrasDiff(twice, 'b = 2\n');
    expect(d['removed'], <String>['a = 1', 'a = 1']);
    expect(d['added'], isEmpty);
  });

  test('clearing the text removes every line and section', () {
    final Json d = extrasDiff(tuned, '');
    expect((d['sections'] as Json)['after'], isEmpty);
    expect(d['removed'], contains('[regions-marinas:vars]'));
    expect(d['added'], isEmpty);
  });
}
