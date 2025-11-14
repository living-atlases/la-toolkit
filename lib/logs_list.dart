import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tuple/tuple.dart';

import './models/cmd_history_entry.dart';
import 'components/status_icon.dart';
import 'la_theme.dart';
import 'log_search_input.dart';
import 'redux/entity_api.dart';
import 'utils/result_types.dart';
import 'utils/utils.dart';

class LogList extends StatefulWidget {
  const LogList(
      {super.key,
      required this.projectId,
      required this.onTap,
      required this.onDelete,
      required this.onRepeat,
      required this.onUpdateDesc});

  final String projectId;
  final Function(CmdHistoryEntry) onTap;
  final Function(CmdHistoryEntry) onRepeat;
  final Function(CmdHistoryEntry) onDelete;
  final Function(CmdHistoryEntry, String desc) onUpdateDesc;

  @override
  State<LogList> createState() => _LogListState();
}

class _LogListState extends State<LogList> {
  static const int _pageSize = 20;

  static EntityApi<CmdHistoryEntry> cmdApi =
      EntityApi<CmdHistoryEntry>('cmdHistoryEntry');

  final PagingController<int, CmdHistoryEntry> _pagingController =
      PagingController<int, CmdHistoryEntry>(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((int pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  String? _searchTerm;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final List<dynamic> newItemsJson = await cmdApi.find(
          filter: Tuple2<String, String>('projectId', widget.projectId),
          skip: pageKey,
          sort: 'createdAt DESC',
          where: _searchTerm != null
              ? jsonEncode(<String, List<Map<String, Map<String, String>>>>{
                  'or': _searchTerm!
                          .split(' ')
                          .map((String s) => <String, Map<String, String>>{
                                'desc': <String, String>{'contains': s}
                              })
                          .toList() +
                      _searchTerm!
                          .split(' ')
                          .map((String s) => <String, Map<String, String>>{
                                'result': <String, String>{'contains': s}
                              })
                          .toList(),
                })
              : null,
          limit: _pageSize);
      log('LOGS retrieved ${newItemsJson.length}');
      final List<CmdHistoryEntry> newItems = <CmdHistoryEntry>[];
      for (final dynamic jDynamic in newItemsJson) {
        final Map<String, dynamic> j = jDynamic as Map<String, dynamic>;
        // ignore: avoid_dynamic_calls
        j['cmd'] = j['cmd'][0];
        j['date'] = j['createdAt'];
        final CmdHistoryEntry cmd = CmdHistoryEntry.fromJson(j);
        newItems.add(cmd);
      }
      final bool isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final int nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: () => Future<void>.sync(
            () => _pagingController.refresh(),
          ),
      child: CustomScrollView(
          shrinkWrap: true,
          // scrollDirection: Axis.vertical,
          slivers: <Widget>[
            LogSearchInput(
              onChanged: _updateSearchTerm,
            ),
            PagedSliverList<int, CmdHistoryEntry>.separated(
                pagingController: _pagingController,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                builderDelegate: PagedChildBuilderDelegate<CmdHistoryEntry>(
                  animateTransitions: true,
                  transitionDuration: const Duration(milliseconds: 500),
                  itemBuilder:
                      (BuildContext context, CmdHistoryEntry item, int index) =>
                          LogItem(
                              log: item,
                              onTap: widget.onTap,
                              onRepeat: widget.onRepeat,
                              onUpdateDesc: widget.onUpdateDesc,
                              onDelete: widget.onDelete),
                ))
          ]));

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class LogItem extends StatelessWidget {
  const LogItem(
      {required this.log,
      required this.onTap,
      required this.onRepeat,
      required this.onDelete,
      required this.onUpdateDesc,
      super.key});

  final CmdHistoryEntry log;
  final Function(CmdHistoryEntry) onTap;
  final Function(CmdHistoryEntry) onRepeat;
  final Function(CmdHistoryEntry) onDelete;
  final Function(CmdHistoryEntry, String desc) onUpdateDesc;

  @override
  Widget build(BuildContext context) {
    final String desc = log.getDesc();
    if (log.desc != log.getDesc()) {
      onUpdateDesc(log, desc); // Update the backend (not done in db migration)
    }
    final String duration = log.duration != null
        ? 'duration: ${LADateUtils.formatDuration(log.duration!)}, '
        : '';
    return ListTile(
        title: Text(desc),
        subtitle: Text(
            '${LADateUtils.formatDate(log.date)}, ${duration}finished status: ${log.result.toS()}'),
        onTap: () => onTap(log),
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            Tooltip(
                message: 'Repeat this command',
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: ResultType.ok.color),
                  onPressed: () => onRepeat(log),
                )), // icon-1
            Tooltip(
                message: 'Delete this log',
                child: IconButton(
                  icon: const Icon(Icons.delete, color: LAColorTheme.inactive),
                  onPressed: () => onDelete(log),
                )), // icon-2
          ],
        ),
        leading: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: StatusIcon(log.result)));
  }
}
