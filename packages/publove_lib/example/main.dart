import 'dart:io';

import 'package:csv/csv.dart';
import 'package:publove_lib/publove_lib.dart';

void main(List<String> args) async {
  if (args.length > 2) print('usage: publove [pages] [skip]');
  final pages = args.isNotEmpty ? int.parse(args[0]) : 1;
  final skip = args.length == 2 ? int.parse(args[1]) : 0;
  final stream = fetchPackages(pages: pages, skip: skip);
  final rows = [
    [
      'Name',
      'Publisher',
      'Published (days ago)',
      'Popularity',
      'Likes',
      'Love #',
      'Notes',
    ],
  ];

  await for (var package in stream) {
    rows.add([
      package.name,
      package.publisher,
      '${DateTime.now().difference(package.published).inDays}',
      package.popularityScore.toString(),
      package.likes.toString(),
      package.loveNum.toString(),
      package.notes,
    ]);
  }

  final csv = const ListToCsvConverter().convert(rows);
  print(csv);
  exit(0);
}

Stream<PackageData> fetchPackages({required int pages, int skip = 0}) async* {
  const pageSize = 10;
  final offset = skip * pageSize;
  var count = 0;

  for (var page = 1 + offset; page <= pages + offset; ++page) {
    final stream = PackageData.fetchPackages(page: page);
    await for (var package in stream) {
      stderr.writeln(
        '${++count + offset}.\t${package.name} '
        '${package.notes.isNotEmpty ? " (${package.notes})" : ''}',
      );

      yield package;
    }
  }
}
