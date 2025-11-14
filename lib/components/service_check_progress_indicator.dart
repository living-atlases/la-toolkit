import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ServiceCheckProgressIndicator extends StatelessWidget {
  const ServiceCheckProgressIndicator({
    super.key,
    required this.serverName,
    required this.status,
    this.resultsCount = 0,
  });

  final String serverName;
  final String status;
  final int resultsCount;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case 'checking':
        icon = MdiIcons.loading;
        color = Colors.blue;
        statusText = 'Checking...';
        break;
      case 'individual-checks':
        icon = MdiIcons.loading;
        color = Colors.orange;
        statusText = 'Running individual checks...';
        break;
      case 'completed':
        icon = MdiIcons.checkCircle;
        color = Colors.green;
        statusText = 'Completed ($resultsCount checks)';
        break;
      case 'failed':
        icon = MdiIcons.alertCircle;
        color = Colors.red;
        statusText = resultsCount > 0 ? 'Partial failure ($resultsCount checks)' : 'All checks failed';
        break;
      default:
        icon = MdiIcons.helpCircle;
        color = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: status == 'checking' || status == 'individual-checks'
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(icon, color: color, size: 24),
        title: Text(
          serverName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(statusText),
        trailing: resultsCount > 0
            ? Chip(
                label: Text('$resultsCount'),
                backgroundColor: color.withValues(alpha: 0.2),
              )
            : null,
      ),
    );
  }
}
