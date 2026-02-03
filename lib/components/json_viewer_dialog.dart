import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../la_theme.dart';
import '../models/la_cluster.dart';
import '../models/la_project.dart';

class JsonViewerDialog extends StatelessWidget {
  const JsonViewerDialog({super.key, required this.project});

  final LAProject project;

  static Future<void> show(BuildContext context, LAProject project) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return JsonViewerDialog(project: project);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> jsonData = project.toGeneratorJson();
    final String prettyJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(jsonData);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Project JSON (toGeneratorJson)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy to clipboard',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: prettyJson));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('JSON copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Debug Info:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: LAColorTheme.laPalette,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Servers: ${project.servers.length}'),
                  Text('Clusters: ${project.clusters.length}'),
                  Text(
                    'serverServices: ${project.serverServices.length} entries',
                  ),
                  Text(
                    'clusterServices: ${project.clusterServices.length} entries',
                  ),
                  if (project.clusters.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    const Text(
                      'Clusters:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (final LACluster cluster in project.clusters)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          '- ${cluster.name} (serverId: ${cluster.serverId})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                  if (project.clusterServices.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    const Text(
                      'Cluster Services:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (final MapEntry<String, List<String>> entry in project.clusterServices.entries)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          '- ${entry.key}: ${entry.value.join(", ")}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  prettyJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
