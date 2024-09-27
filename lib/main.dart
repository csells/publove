// 'Would be neat to see a list of pub packages by ratio of
// days-since-last-publish to usage or other “important & abandoned” list.'
// --Erik Seidel, 2024-09-25
// https://x.com/_eseidel/status/1838789824276500661
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package_data.dart';
import 'packages_table.dart';

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

class PackageDataListView extends StatefulWidget {
  const PackageDataListView(this.packages, {super.key});
  final List<PackageData> packages;

  @override
  State<PackageDataListView> createState() => _PackageDataListViewState();
}

class _PackageDataListViewState extends State<PackageDataListView> {
  int page = 1;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 1000,
                  child: PackagesTable(packages: widget.packages),
                ),
              ),
            ),
            Column(
              children: [
                Text('Packages: ${widget.packages.length}'),
                Gap(8),
                OutlinedButton(
                  onPressed: _morePressed,
                  child: Text('More...'),
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> _morePressed() async {
    final packages = await PackageData.fetchPackages(page: ++page);
    setState(() => widget.packages.addAll(packages));
    // setState(() => widget.packages.clear());
  }
}
