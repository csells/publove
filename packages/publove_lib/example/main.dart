import 'dart:io';

import 'package:csv/csv.dart';
import 'package:publove_lib/publove_lib.dart';

void main(List<String> args) async {
  if (args.length > 1) print('usage: publove [pages]');
  final pages = args.length == 1 ? int.parse(args[0]) : 1;
  final stream = fetchPackages(pages: pages);
  final rows = [
    [
      'Name',
      'Published (days ago)',
      'Popularity',
      'Likes',
      'Null Safe',
      'Dart 3',
      'Love #',
      'Notes',
    ],
  ];

  await for (var package in stream) {
    rows.add([
      package.name,
      '${DateTime.now().difference(package.published).inDays}',
      package.popularityScore.toString(),
      package.likes.toString(),
      package.isNullSafe.toString(),
      package.isDart3.toString(),
      package.loveNum.toString(),
      package.notes,
    ]);
  }

  final csv = const ListToCsvConverter().convert(rows);
  print(csv);
  exit(0);
}

Stream<PackageData> fetchPackages({required int pages}) async* {
  for (var page = 1; page <= pages; ++page) {
    final packages = await PackageData.fetchPackages(page: page);
    for (var package in packages) {
      yield package;
    }
  }
}
