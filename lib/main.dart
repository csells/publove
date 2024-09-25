// 'Would be neat to see a list of pub packages by ratio of
// days-since-last-publish to usage or other “important & abandoned” list.'
// --Erik Seidel, 2024-09-25
// https://x.com/_eseidel/status/1838789824276500661
import 'package:flutter/material.dart';

import 'package_data.dart';

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
          builder: (context, packageDataSnapshot) {
            return packageDataSnapshot.hasError
                ? Center(child: Text('Error: ${packageDataSnapshot.error}'))
                : packageDataSnapshot.hasData
                    ? Center(
                        child: PackageDataListView(packageDataSnapshot.data!),
                      )
                    : Center(child: const CircularProgressIndicator());
          },
        ),
      );
}

class PackageDataListView extends StatelessWidget {
  const PackageDataListView(this.packageData, {super.key});
  final List<PackageData> packageData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Published')),
          DataColumn(label: Text('Popularity Score')),
          DataColumn(label: Text('Likes')),
          DataColumn(label: Text('Null Safe')),
          DataColumn(label: Text('Dart 3')),
          DataColumn(label: Text('Ratio')),
        ],
        rows: packageData.map((packageData) {
          return DataRow(cells: [
            DataCell(Text(packageData.name)),
            DataCell(Text('${packageData.daysSincePublished} days ago')),
            DataCell(Text(_toPercent(packageData.popularityScore))),
            DataCell(Text(packageData.likes.toString())),
            DataCell(Text(packageData.isNullSafe.toString())),
            DataCell(Text(packageData.isDart3.toString())),
            DataCell(Text(packageData.ratio.toStringAsFixed(0))),
          ]);
        }).toList(),
      ),
    );
  }

  String _toPercent(double value) => '${(value * 100).toStringAsFixed(0)}%';
}