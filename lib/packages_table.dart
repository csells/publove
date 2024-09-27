import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:intl/intl.dart';

import 'package_data.dart';

class PackagesTable extends StatelessWidget {
  PackagesTable({super.key, required List<PackageData> packages})
      : _packages = packages,
        _controller = ExpandableTableController(
          headerHeight: 48,
          duration: const Duration(milliseconds: 0),
          firstHeaderCell: ExpandableTableCell(child: _HeaderCell('Name')),
          firstColumnWidth: 256,
          headers: [
            _header('Published'),
            _header('Popularity Score'),
            _header('Likes'),
            _header('Null Safe'),
            _header('Dart 3'),
            _header('Ratio'),
          ],
          rows: [
            for (var package in packages)
              ExpandableTableRow(
                firstCell: _firstCell(package),
                cells: package.notes.isNotEmpty ? null : _subCells(package),
                legend:
                    package.notes.isNotEmpty ? _TableCell(package.notes) : null,
                children: package.notes.isNotEmpty ? [_subRow(package)] : null,
              ),
          ],
        );

  final List<PackageData> _packages;
  static final _likesFormat = NumberFormat.decimalPattern();
  final ExpandableTableController _controller;

  @override
  Widget build(BuildContext context) => ExpandableTable(
        controller: _controller,
      );

  static String _toPercent(double value) =>
      '${(value * 100).toStringAsFixed(0)}%';

  static ExpandableTableHeader _header(String name) => ExpandableTableHeader(
        cell: ExpandableTableCell(
          child: _HeaderCell(name),
        ),
      );

  static ExpandableTableCell _tableCell(
    String text, {
    bool bad = false,
    Alignment alignment = Alignment.centerLeft,
  }) =>
      ExpandableTableCell(
        child: _TableCell(text, bad: bad, alignment: alignment),
      );

  static ExpandableTableRow _subRow(PackageData package) => ExpandableTableRow(
        firstCell: ExpandableTableCell(
          child: Row(
            children: [
              SizedBox(width: 32),
              _TableCell(package.name),
            ],
          ),
        ),
        cells: _subCells(package),
      );

  static List<ExpandableTableCell> _subCells(PackageData package) => [
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

  static ExpandableTableCell _firstCell(PackageData package) =>
      ExpandableTableCell(
        builder: (context, details) => Row(
          children: [
            SizedBox(
              width: 16,
              child: details.row?.children != null
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Transform.rotate(
                        angle: details.row?.childrenExpanded == true
                            ? 90 * pi / 180
                            : 0,
                        child: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : null,
            ),
            _TableCell(package.name),
          ],
        ),
      );
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
