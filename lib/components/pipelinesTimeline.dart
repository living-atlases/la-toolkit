import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/pipelinesStepDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'genericTextFormField.dart';

class PipelinesTimeline extends StatefulWidget {
  static const double stepSize = 50;
  static const double iconSize = 26;
  static const EdgeInsets stepPadding = EdgeInsets.all(10);
  static const EdgeInsets stepIconPadding = EdgeInsets.all(4);
  static const String last = "solr-sync";
  const PipelinesTimeline({Key? key}) : super(key: key);

  @override
  _PipelinesTimelineState createState() => _PipelinesTimelineState();
}

class _PipelinesTimelineState extends State<PipelinesTimeline> {
  @override
  Widget build(BuildContext context) {
    List<Widget> leftActions = [];
    List<Widget> rightActions = [];
    List<Widget> commonSteps = [];
    List<Widget> otherSteps = [];
    List<String> otherStepsS = [];
    List<dynamic> otherStepsO = [];
    bool lastBuilt = false;

    leftActions.add(_DrInput());
    rightActions.add(_DoAllBtn());
    commonSteps.add(const Text("Pipelines steps", style: UiUtils.titleStyle));
    commonSteps.add(const SizedBox(height: 10));
    otherSteps.add(const Text("Other tasks", style: UiUtils.titleStyle));
    otherSteps.add(const SizedBox(height: 10));

    PipelinesStepDesc.list.asMap().forEach((int index, PipelinesStepDesc step) {
      Widget stepWidget =
          _StepWidget(index: index, step: step, lastBuilt: lastBuilt);

      if (!lastBuilt) {
        commonSteps.add(stepWidget);
      } else {
        otherSteps.add(stepWidget);
        otherStepsS.add(step.name);
        otherStepsO.add(step);
      }

      if (PipelinesTimeline.last == step.name) {
        lastBuilt = true;
      }
    });

    commonSteps
        .add(const _ChipStep(name: "all steps", desc: "Do all these steps"));

    return Column(children: [
      ResponsiveGridRow(children: [
        ResponsiveGridCol(lg: 6, child: Column(children: leftActions)),
        ResponsiveGridCol(lg: 6, child: Column(children: rightActions))
      ]),
      const SizedBox(height: 40),
      ResponsiveGridRow(children: [
        ResponsiveGridCol(lg: 6, child: Column(children: commonSteps)),
        ResponsiveGridCol(lg: 6, child: Column(children: otherSteps))
      ])
    ]);
  }
}

class _ChipStep extends StatelessWidget {
  final String name;
  final String desc;
  const _ChipStep({Key? key, required this.name, required this.desc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: ActionChip(
          padding: const EdgeInsets.all(5),
          backgroundColor: Colors.transparent,
          shape: const StadiumBorder(
              side: BorderSide(color: LAColorTheme.laPalette)),
          avatar: const CircleAvatar(
              backgroundColor: Colors.transparent,
              foregroundColor: LAColorTheme.laPalette,
              child: Icon(Icons.check_outlined)),
          label: Tooltip(message: desc, child: Text(name)),
          onPressed: () {},
        ));
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PipelinesTimeline.stepPadding,
      constraints: const BoxConstraints(
          minHeight: PipelinesTimeline.stepSize, maxWidth: 100, minWidth: 100),
      child: Text(
        text,
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _StepWidget extends StatelessWidget {
  final PipelinesStepDesc step;
  final bool lastBuilt;
  final int index;
  const _StepWidget(
      {Key? key,
      required this.index,
      required this.step,
      required this.lastBuilt})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    IndicatorStyle selectedIndicatorStyle = IndicatorStyle(
      width: PipelinesTimeline.iconSize,
      color: LAColorTheme.laPalette,
      padding: PipelinesTimeline.stepIconPadding,
      iconStyle: IconStyle(
        color: Colors.white,
        iconData: Icons.check,
      ),
    );
    IndicatorStyle notSelectedIndicatorStyle = IndicatorStyle(
      width: PipelinesTimeline.iconSize,
      padding: PipelinesTimeline.stepIconPadding,
      iconStyle: IconStyle(
        color: Colors.grey.shade400,
        iconData: Icons.check,
      ),
    );
    return InkWell(
        onTap: () {},
        child: TimelineTile(
          isFirst: index == 0 || lastBuilt,
          isLast: step.name == PipelinesTimeline.last || lastBuilt,
          // This defines the size of left part (the title) and the BoxConstraint of _StepTittle
          lineXY: 0.3,
          alignment: TimelineAlign.manual,
          // hasIndicator: index != 8,
          indicatorStyle:
              index > 6 ? notSelectedIndicatorStyle : selectedIndicatorStyle,
          endChild: _StepDescription(desc: step.desc),
          startChild: _StepTitle(text: step.name),
        ));
  }
}

class _StepDescription extends StatelessWidget {
  final String desc;
  const _StepDescription({Key? key, required this.desc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PipelinesTimeline.stepPadding,
      constraints: const BoxConstraints(minHeight: PipelinesTimeline.stepSize),
      child: Text(StringUtils.capitalize(desc)),
    );
  }
}

class _DrInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GenericTextFormField(
      label: 'Data resource/s',
      hint:
          "A data resource or a list of data resources, like: dr893 dr915 (space separated)",
      error:
          "Wrong data resource/s. It should start with 'dr', like 'dr893' or a list like 'dr893 dr915 dr200'",
      regexp: LARegExp.drs,
      onChanged: (value) {},
      initialValue: '',
    );
  }
}

class _DoAllBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        height: 100.0,
        child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              const SizedBox(width: 20),
              const Text("or "),
              const SizedBox(width: 20),
              ActionChip(
                  onPressed: () {},
                  label:
                      const Text("do all drs", style: TextStyle(fontSize: 16)))
            ])));
  }
}
