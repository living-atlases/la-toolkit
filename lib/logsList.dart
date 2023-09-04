import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:la_toolkit/logSearchInput.dart';
import 'package:la_toolkit/redux/entityApi.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:tuple/tuple.dart';

import 'components/statusIcon.dart';
import 'laTheme.dart';
import 'models/cmdHistoryEntry.dart';

class LogList extends StatefulWidget {
  final String projectId;
  final Function(CmdHistoryEntry) onTap;
  final Function(CmdHistoryEntry) onRepeat;
  final Function(CmdHistoryEntry) onDelete;
  final Function(CmdHistoryEntry, String desc) onUpdateDesc;

  const LogList(
      {Key? key,
      required this.projectId,
      required this.onTap,
      required this.onDelete,
      required this.onRepeat,
      required this.onUpdateDesc})
      : super(key: key);

  @override
  State<LogList> createState() => _LogListState();
}

class _LogListState extends State<LogList> {
  static const _pageSize = 20;

  static EntityApi<CmdHistoryEntry> cmdApi =
      EntityApi<CmdHistoryEntry>('cmdHistoryEntry');

  final PagingController<int, CmdHistoryEntry> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  String? _searchTerm;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final List<dynamic> newItemsJson = await cmdApi.find(
          filter: Tuple2<String, String>("projectId", widget.projectId),
          skip: pageKey,
          sort: "createdAt DESC",
          where: _searchTerm != null
              ? jsonEncode({
                  "or": _searchTerm!
                          .split(' ')
                          .map((s) => {
                                "desc": {"contains": s}
                              })
                          .toList() +
                      _searchTerm!
                          .split(' ')
                          .map((s) => {
                                "result": {"contains": s}
                              })
                          .toList(),
                })
              : null,
          limit: _pageSize);
      print("LOGS retrieved ${newItemsJson.length}");
      final List<CmdHistoryEntry> newItems = [];
      for (var j in newItemsJson) {
        j['cmd'] = j['cmd'][0];
        j['date'] = j['createdAt'];
        CmdHistoryEntry cmd = CmdHistoryEntry.fromJson(j);
        newItems.add(cmd);
      }
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
          ),
      child: CustomScrollView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          slivers: <Widget>[
            LogSearchInput(
              onChanged: _updateSearchTerm,
            ),
            PagedSliverList<int, CmdHistoryEntry>.separated(
                pagingController: _pagingController,
                separatorBuilder: (context, index) => const Divider(),
                builderDelegate: PagedChildBuilderDelegate<CmdHistoryEntry>(
                  animateTransitions: true,
                  transitionDuration: const Duration(milliseconds: 500),
                  itemBuilder: (context, item, index) => LogItem(
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
  final CmdHistoryEntry log;
  final Function(CmdHistoryEntry) onTap;
  final Function(CmdHistoryEntry) onRepeat;
  final Function(CmdHistoryEntry) onDelete;
  final Function(CmdHistoryEntry, String desc) onUpdateDesc;

  const LogItem(
      {required this.log,
      required this.onTap,
      required this.onRepeat,
      required this.onDelete,
      required this.onUpdateDesc,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String desc = log.getDesc();
    if (log.desc != log.getDesc()) {
      onUpdateDesc(log, desc); // Update the backend (not done in db migration)
    }
    String duration = log.duration != null
        ? 'duration: ${LADateUtils.formatDuration(log.duration!)}, '
        : '';
    return ListTile(
        title: Text(desc),
        subtitle: Text(
            "${LADateUtils.formatDate(log.date)}, ${duration}finished status: ${log.result.toS()}"),
        onTap: () => onTap(log),
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            Tooltip(
                message: "Repeat this command",
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: ResultType.ok.color),
                  onPressed: () => onRepeat(log),
                )), // icon-1
            Tooltip(
                message: "Delete this log",
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
