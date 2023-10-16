import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../laTheme.dart';
import '../models/laServiceName.dart';
import '../models/la_project.dart';
import '../models/pipelinesCmd.dart';
import '../models/pipelinesStepDesc.dart';
import '../utils/StringUtils.dart';
import '../utils/regexp.dart';
import '../utils/utils.dart';
import 'genericTextFormField.dart';

class PipelinesTimeline extends StatefulWidget {
  const PipelinesTimeline(
      {required this.project,
      required this.cmd,
      required this.onChange,
      super.key});

  static const double stepSize = 50;
  static const double stepHeightNotVisible = 0;
  static const double iconSize = 26;
  static const EdgeInsets stepPadding = EdgeInsets.all(15);
  static const EdgeInsets stepPaddingNotVisible = EdgeInsets.zero;
  static const EdgeInsets stepIconPadding = EdgeInsets.all(4);
  static const EdgeInsets titlePadding = EdgeInsets.only(left: 10);
  static const String last = 'solr';
  static const Duration animationDuration = Duration(milliseconds: 300);

  final LAProject project;
  final PipelinesCmd cmd;
  final Function(PipelinesCmd) onChange;

  @override
  State<PipelinesTimeline> createState() => _PipelinesTimelineState();
}

class _PipelinesTimelineState extends State<PipelinesTimeline> {
  late PipelinesCmd cmd;
  late final FocusNode focus;
  late final FocusAttachment _nodeAttachment;
  bool isShiftPressed = false;
  int lastClicked = -1;

  // Based in: https://stackoverflow.com/a/67363189/642847
  @override
  void initState() {
    super.initState();
    cmd = widget.cmd;
    focus = FocusNode(debugLabel: 'Button');
    _nodeAttachment =
        focus.attach(context, onKey: (FocusNode node, RawKeyEvent event) {
      log('Was shift: $isShiftPressed');
      isShiftPressed = event.isShiftPressed;
      return KeyEventResult.handled;
    });
    focus.requestFocus();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nodeAttachment.reparent();
    final List<Widget> leftActions = <Widget>[];
    final List<Widget> rightActions = <Widget>[];
    final List<Widget> commonSteps = <Widget>[];
    final List<Widget> otherSteps = <Widget>[];
    final List<String> otherStepsS = <String>[];
    final List<dynamic> otherStepsO = <dynamic>[];
    bool lastBuilt = false;

    leftActions.add(_DrInput(cmd.drs, cmd.allDrs, (String value) {
      setState(() {
        cmd.drs = value;
        widget.onChange(cmd);
      });
    }));
    rightActions.add(_DoAllDrsBtn(cmd.allDrs, () {
      setState(() {
        cmd.allDrs = !cmd.allDrs;
        if (cmd.allDrs) {
          cmd.drs = '';
          widget.onChange(cmd);
        }
      });
    }));
    commonSteps.add(const Padding(
        padding: PipelinesTimeline.titlePadding,
        child: Text('Pipelines steps:', style: UiUtils.titleStyle)));
    commonSteps.add(const SizedBox(height: 10));
    otherSteps.add(const Padding(
        padding: PipelinesTimeline.titlePadding,
        child: Text('Other tasks:', style: UiUtils.titleStyle)));
    otherSteps.add(const SizedBox(height: 10));

    PipelinesStepDesc.list.asMap().forEach((int index, PipelinesStepDesc step) {
      if (shouldWeUse(widget.project, step)) {
        final Widget stepWidget = _StepWidget(
            cmd: cmd,
            index: index,
            step: step,
            lastBuilt: lastBuilt,
            onPressed: () {
              // print("lastclicked $lastClicked index: $index");
              final bool val = cmd.steps.contains(step.name);
              setState(() {
                if (isShiftPressed) {
                  if (lastClicked >= 0) {
                    final bool loopForward = lastClicked < index;
                    if (loopForward) {
                      for (int x = lastClicked; x < index; x++) {
                        cmd.steps
                            .add(PipelinesStepDesc.allStringList.elementAt(x));
                      }
                    } else {
                      for (int x = lastClicked; x > index; x--) {
                        cmd.steps
                            .add(PipelinesStepDesc.allStringList.elementAt(x));
                      }
                    }
                  }
                  final String el =
                      PipelinesStepDesc.allStringList.elementAt(index);
                  cmd.steps.add(el);
                } else {
                  if (cmd.steps.contains(step.name)) {
                    cmd.steps.remove(step.name);
                    cmd.allSteps = false;
                  } else {
                    cmd.steps.add(step.name);
                  }
                }
                lastClicked = val ? -1 : index;
              });
              widget.onChange(cmd);
            });

        if (!lastBuilt) {
          commonSteps.add(stepWidget);
        } else {
          otherSteps.add(stepWidget);
          otherStepsS.add(step.name);
          otherStepsO.add(step);
        }
      }

      if (PipelinesTimeline.last == step.name) {
        lastBuilt = true;
      }
    });

    commonSteps.add(Padding(
        padding: const EdgeInsets.only(left: 85, top: 20),
        child: GenericActionChip(
            text: 'all steps',
            isPressed: cmd.allSteps,
            onPressed: () => <void>{
                  setState(() {
                    cmd.allSteps = !cmd.allSteps;
                    if (cmd.allSteps) {
                      cmd.steps.addAll(PipelinesStepDesc.allStringList);
                    } else {
                      // ignore: prefer_foreach
                      for (final String step
                          in PipelinesStepDesc.allStringList) {
                        cmd.steps.remove(step);
                      }
                    }
                    widget.onChange(cmd);
                  })
                })));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ResponsiveGridRow(children: <ResponsiveGridCol>[
            ResponsiveGridCol(lg: 9, child: Column(children: leftActions)),
            ResponsiveGridCol(lg: 3, child: Column(children: rightActions))
          ]),
          const SizedBox(height: 40),
          ResponsiveGridRow(children: <ResponsiveGridCol>[
            ResponsiveGridCol(
                lg: 6,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: commonSteps)),
            ResponsiveGridCol(
                lg: 6,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: otherSteps))
          ])
        ]);
  }

  bool shouldWeUse(LAProject project, PipelinesStepDesc step) {
    if (step.depends.isEmpty) {
      return true;
    } else {
      bool add = true;
      for (final LAServiceName dep in step.depends) {
        add = add && project.getService(dep.toS()).use;
      }
      return add;
    }
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.text, required this.visible});

  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: visible
          ? PipelinesTimeline.stepPadding
          : PipelinesTimeline.stepPaddingNotVisible,
      constraints: BoxConstraints(
          minHeight: visible
              ? PipelinesTimeline.stepSize
              : PipelinesTimeline.stepHeightNotVisible,
          maxWidth: 100,
          minWidth: 100),
      duration: PipelinesTimeline.animationDuration,
      child: Text(
        visible ? text : '',
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _StepWidget extends StatelessWidget {
  const _StepWidget(
      {required this.cmd,
      required this.index,
      required this.step,
      required this.lastBuilt,
      required this.onPressed});

  final PipelinesCmd cmd;
  final PipelinesStepDesc step;
  final bool lastBuilt;
  final int index;
  final VoidCallback onPressed;

  static IndicatorStyle selectedIndicatorStyle = IndicatorStyle(
    width: PipelinesTimeline.iconSize,
    color: LAColorTheme.laPalette,
    padding: PipelinesTimeline.stepIconPadding,
    iconStyle: IconStyle(
      color: Colors.white,
      iconData: Icons.check,
    ),
  );
  static IndicatorStyle notSelectedIndicatorStyle = IndicatorStyle(
    width: PipelinesTimeline.iconSize,
    padding: PipelinesTimeline.stepIconPadding,
    iconStyle: IconStyle(
      color: Colors.grey.shade400,
      iconData: Icons.check,
    ),
  );
  static IndicatorStyle noIndicatorStyle = IndicatorStyle(
    width: PipelinesTimeline.iconSize,
    padding: const EdgeInsets.all(2),
    iconStyle: IconStyle(
      color: Colors.transparent,
      iconData: Icons.check,
    ),
  );

  List<T> intersection<T>(Iterable<Iterable<T>> iterables) {
    return iterables
        .map((Iterable<T> e) => e.toSet())
        .reduce((Set<T> a, Set<T> b) => a.intersection(b))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool stepsToMinimize = index > 1 && index <= 10;
    final bool somethingOfStepsSelected = intersection(<List<String>>[
          cmd.steps.toList(),
          PipelinesStepDesc.allStringList
        ]).isNotEmpty ||
        cmd.allSteps;
    // bool somethingOfRestTasksSelected =
    //  intersection([cmd.steps, PipelinesStepDesc.restStringList]).isNotEmpty;
    final bool allVisible = somethingOfStepsSelected || !stepsToMinimize;

    final IndicatorStyle onOffStStyle = !cmd.steps.contains(step.name)
        ? notSelectedIndicatorStyle
        : selectedIndicatorStyle;
    return InkWell(
        onTap: onPressed,
        child: TimelineTile(
          isFirst: index == 0 || lastBuilt,
          isLast: step.name == PipelinesTimeline.last || lastBuilt,
          // This defines the size of left part (the title) and the BoxConstraint of _StepTittle
          lineXY: 0.3,
          alignment: TimelineAlign.manual,

          /* beforeLineStyle: index == 3
              ? const LineStyle(
                  color: Colors.transparent,
                  thickness: 6,
                )
              : const LineStyle(), */
          indicatorStyle: index > PipelinesStepDesc.lastStep || !stepsToMinimize
              ? onOffStStyle
              : !somethingOfStepsSelected
                  ? noIndicatorStyle
                  : onOffStStyle,
          endChild: _StepDescription(desc: step.desc, visible: allVisible),
          startChild: _StepTitle(text: step.name, visible: allVisible),
        ));
  }
}

class _StepDescription extends StatelessWidget {
  const _StepDescription({required this.desc, required this.visible});

  final String desc;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: visible
          ? PipelinesTimeline.stepPadding
          : PipelinesTimeline.stepPaddingNotVisible,
      constraints: BoxConstraints(
          minHeight: visible
              ? PipelinesTimeline.stepSize
              : PipelinesTimeline.stepHeightNotVisible),
      duration: PipelinesTimeline.animationDuration,
      child: Text(visible ? StringUtils.capitalize(desc) : ''),
    );
  }
}

class _DrInput extends StatelessWidget {
  const _DrInput(this.initialValue, this.allDrs, this.onChanged);

  final String? initialValue;
  final bool allDrs;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return GenericTextFormField(
      label: 'Data resource/s',
      hint:
          'A data resource or a list of data resources, like: dr893 dr915 (space separated)',
      error:
          "Wrong data resource/s. It should start with 'dr', like 'dr893' or a list like 'dr893 dr915 dr200'",
      regexp: LARegExp.drs,
      onChanged: onChanged,
      enabled: !allDrs,
      allowEmpty: allDrs,
      initialValue: initialValue,
    );
  }
}

class _DoAllDrsBtn extends StatelessWidget {
  const _DoAllDrsBtn(this.isPressed, this.onPressed);

  final VoidCallback onPressed;
  final bool isPressed;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        height: 100.0,
        child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: <Widget>[
              const SizedBox(width: 20),
              const Text('or '),
              const SizedBox(width: 20),
              GenericActionChip(
                  text: 'do all drs',
                  onPressed: onPressed,
                  isPressed: isPressed)
            ])));
  }
}

class GenericActionChip extends StatelessWidget {
  const GenericActionChip(
      {super.key,
      required this.onPressed,
      required this.isPressed,
      required this.text});

  final VoidCallback onPressed;
  final bool isPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
        onPressed: onPressed,
        backgroundColor: isPressed ? LAColorTheme.laPalette : null,
        avatar: isPressed ? const Icon(Icons.check, color: Colors.white) : null,
        labelPadding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        label: Text(text,
            style: TextStyle(
                fontSize: 16, color: isPressed ? Colors.white : null)));
  }
}
