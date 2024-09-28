import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:intl/intl.dart';

import 'package_data.dart';

class PackagesTable extends StatelessWidget {
  // note: using the controller and all of the static members is a bit of a hack
  // but it's the only way I could figure out how to get the ExpandableTable to
  // update with new data as it's available.
  PackagesTable({super.key, required List<PackageData> packages})
      : _controller = ExpandableTableController(
          headerHeight: 48,
          duration: const Duration(milliseconds: 0),
          firstHeaderCell: ExpandableTableCell(
            child: _Cell('Name', isHeader: true, offset: 36),
          ),
          firstColumnWidth: 280,
          visibleScrollbar: true,
          thumbVisibilityScrollbar: true,
          trackVisibilityScrollbar: true,
          headers: [
            _header('Published'),
            _header('Popularity'),
            _header('Likes'),
            _header('Null Safe'),
            _header('Dart 3'),
            _header('*Love #'),
          ],
          rows: [
            for (var package in packages)
              ExpandableTableRow(
                firstCell: _firstCell(package),
                cells: package.notes.isNotEmpty ? null : _subCells(package),
                legend: package.notes.isNotEmpty ? _Cell(package.notes) : null,
                children: package.notes.isNotEmpty ? [_subRow(package)] : null,
              ),
          ],
        );

  static final _likesFormat = NumberFormat.decimalPattern();
  final ExpandableTableController _controller;

  @override
  Widget build(BuildContext context) =>
      ExpandableTable(controller: _controller);

  static String _toPercent(double value) =>
      '${(value * 100).toStringAsFixed(1)}%';

  static ExpandableTableHeader _header(
    String name, {
    Alignment alignment = Alignment.centerLeft,
  }) =>
      ExpandableTableHeader(
        cell: ExpandableTableCell(
          child: _Cell(name, isHeader: true, alignment: alignment),
        ),
      );

  static ExpandableTableCell _cell(
    String text, {
    bool bad = false,
    Alignment alignment = Alignment.centerLeft,
  }) =>
      ExpandableTableCell(
        child: _Cell(text, bad: bad, alignment: alignment),
      );

  static ExpandableTableRow _subRow(PackageData package) => ExpandableTableRow(
        firstCell: ExpandableTableCell(
          child: Row(
            children: [
              SizedBox(width: 64),
              _Cell(package.name),
            ],
          ),
        ),
        cells: _subCells(package),
      );

  static List<ExpandableTableCell> _subCells(PackageData package) => [
        _cell(
          '${package.daysSincePublished} days ago',
          bad: package.daysSincePublished > 180,
        ),
        _cell(
          _toPercent(package.popularityScore),
          alignment: Alignment.centerRight,
        ),
        _cell(
          _likesFormat.format(package.likes),
          alignment: Alignment.centerRight,
        ),
        _cell(
          package.isNullSafe.toString(),
          bad: !package.isNullSafe,
          alignment: Alignment.centerRight,
        ),
        _cell(
          package.isDart3.toString(),
          bad: !package.isDart3,
          alignment: Alignment.centerRight,
        ),
        _cell(
          package.loveNum.toStringAsFixed(0),
          bad: package.loveNum > 160 * .8, // 80% of top score (160)
          alignment: Alignment.centerRight,
        ),
      ];

  static ExpandableTableCell _firstCell(PackageData package) =>
      ExpandableTableCell(
        builder: (context, details) => Row(
          children: [
            SizedBox(
              width: 36,
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
            _Cell(package.name),
          ],
        ),
      );
}

class _Cell extends StatelessWidget {
  const _Cell(
    this.text, {
    this.bad = false,
    this.alignment = Alignment.centerLeft,
    this.isHeader = false,
    this.offset = 0,
  });

  final String text;
  final bool bad;
  final Alignment alignment;
  final bool isHeader;
  final double offset;

  @override
  Widget build(BuildContext context) => Container(
        color: isHeader ? Colors.black : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: alignment,
            child: Row(
              children: [
                SizedBox(width: offset),
                Text(
                  text,
                  style: TextStyle(
                    color: isHeader
                        ? Colors.white
                        : bad
                            ? Colors.red
                            : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
