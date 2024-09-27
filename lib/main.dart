// 'Would be neat to see a list of pub packages by ratio of
// days-since-last-publish to usage or other “important & abandoned” list.'
// --Erik Seidel, 2024-09-25
// https://x.com/_eseidel/status/1838789824276500661
import 'package:flutter/material.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:intl/intl.dart';

import 'package_data.dart';

// TODO: include the mover score?
// https://github.com/ericwindmill/pub_analytics/blob/fa63a022ab3f3cb19c45367a809be417d99d8cfe/lib/model/package.dart#L75

void main() async => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: PackageList());
}

class PackageList extends StatelessWidget {
  const PackageList({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Pub Packages: Important & Abandoned'),
        ),
        body: FutureBuilder(
          future: PackageData.fetchPackages(),
          builder: (context, packageDataSnapshot) =>
              packageDataSnapshot.hasError
                  ? Center(child: Text('Error: ${packageDataSnapshot.error}'))
                  : packageDataSnapshot.hasData
                      ? Center(
                          child: PackageDataListView(packageDataSnapshot.data!),
                        )
                      : Center(child: const CircularProgressIndicator()),
        ),
      );
}

class PackageDataListView extends StatelessWidget {
  PackageDataListView(this.packageData, {super.key});
  final List<PackageData> packageData;

  final _likesFormat = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: ExpandableTable(
          headerHeight: 48,
          firstHeaderCell: ExpandableTableCell(child: _HeaderCell('Name')),
          headers: [
            _header('Published'),
            _header('Popularity Score'),
            _header('Likes'),
            _header('Null Safe'),
            _header('Dart 3'),
            _header('Ratio'),
          ],
          rows: [
            for (var package in packageData)
              ExpandableTableRow(
                firstCell: ExpandableTableCell(child: _TableCell(package.name)),
                cells: package.notes.isNotEmpty ? null : _subCells(package),
                legend:
                    package.notes.isNotEmpty ? _TableCell(package.notes) : null,
                children: package.notes.isNotEmpty ? [_subRow(package)] : null,
              ),
          ],
        ),
      );

  String _toPercent(double value) => '${(value * 100).toStringAsFixed(0)}%';

  ExpandableTableHeader _header(String name) => ExpandableTableHeader(
        cell: ExpandableTableCell(
          child: _HeaderCell(name),
        ),
      );

  ExpandableTableCell _tableCell(
    String text, {
    bool bad = false,
    Alignment alignment = Alignment.centerLeft,
  }) =>
      ExpandableTableCell(
        child: _TableCell(text, bad: bad, alignment: alignment),
      );

  ExpandableTableRow _subRow(PackageData package) => ExpandableTableRow(
        firstCell: ExpandableTableCell(
          child: _TableCell('\t\t${package.name}'),
        ),
        cells: _subCells(package),
      );

  List<ExpandableTableCell> _subCells(PackageData package) => [
        _tableCell(
          '${package.daysSincePublished} days ago',
          bad: package.daysSincePublished > 180,
        ),
        _tableCell(
          _toPercent(package.popularityScore),
          bad: package.popularityScore < 0.01,
          alignment: Alignment.centerRight,
        ),
        _tableCell(
          _likesFormat.format(package.likes),
          alignment: Alignment.centerRight,
        ),
        _tableCell(package.isNullSafe.toString(),
            alignment: Alignment.centerRight),
        _tableCell(package.isDart3.toString(),
            alignment: Alignment.centerRight),
        _tableCell(package.ratio.toStringAsFixed(0),
            alignment: Alignment.centerRight),
      ];
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.name);
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black,
        child: Center(
          child: Text(
            name,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
}

class _TableCell extends StatelessWidget {
  const _TableCell(
    this.text, {
    this.bad = false,
    this.alignment = Alignment.centerLeft,
  });
  final String text;
  final bool bad;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: alignment,
          child: Text(text, style: TextStyle(color: bad ? Colors.red : null)),
        ),
      );
}
