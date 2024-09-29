// 'Would be neat to see a list of pub packages by ratio of
// days-since-last-publish to usage or other “important & abandoned” list.'
// --Erik Seidel, 2024-09-25
// https://x.com/_eseidel/status/1838789824276500661
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:publove/text_link.dart';

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
  var _moreEnabled = true;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            TextLink(
              '[It] would be neat to see a list of pub packages by ratio '
              'of days-since-last-publish to usage or other "important & '
              'abandoned" list.',
              url: 'https://x.com/_eseidel/status/1838789824276500661',
            ),
            Text('--Erik Seidel, 2024-09-25'),
            Gap(16),
            Expanded(
              child: SelectionArea(
                child: Center(
                  child: SizedBox(
                    width: 1002,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: PackagesTable(packages: widget.packages),
                    ),
                  ),
                ),
              ),
            ),
            Gap(16),
            Text(
              '*Love # is the ratio of days since last publication to'
              ' popularity score. Higher numbers are worse.',
            ),
            Gap(16),
            TextLink(
              'Click here to contribute notes for a package.',
              url:
                  'https://github.com/csells/publove/blob/main/lib/package_notes.dart',
            ),
            Gap(16),
            OutlinedButton(
              onPressed: _moreEnabled ? _morePressed : null,
              child: Text('More (${widget.packages.length})...'),
            ),
          ],
        ),
      );

  Future<void> _morePressed() async {
    setState(() => _moreEnabled = false);
    final packages = await PackageData.fetchPackages(page: ++page);
    setState(() {
      widget.packages.addAll(packages);
      _moreEnabled = true;
    });
  }
}