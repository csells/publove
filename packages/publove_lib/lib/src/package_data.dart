import 'package:pub_api_client/pub_api_client.dart';

import 'package_notes.dart';

class PackageData {
  PackageData({
    required this.name,
    required this.publisher,
    required this.published,
    required this.popularityScore,
    required this.likes,
    String? notes,
  })  : daysSincePublished = DateTime.now().difference(published).inDays,
        notes = notes ?? packageNotes[name] ?? '';

  final String name;
  final DateTime published;
  final String publisher;
  final int daysSincePublished;
  final double popularityScore;
  final int likes;
  final String notes;

  /// ratio of days since publication to popularity score
  double get loveNum => daysSincePublished / popularityScore;

  String get url => 'https://pub.dev/packages/$name';

  static Future<PackageData> fromPackageResult(PackageResult result) async {
    final client = PubClient();
    final name = result.package;
    final publisher = await client.packagePublisher(name);
    final info = await client.packageInfo(name);
    final metrics = (await client.packageMetrics(name))!;

    return PackageData(
      name: name,
      publisher: publisher.publisherId ?? 'unknown',
      published: info.latest.published,
      popularityScore: metrics.score.popularityScore!,
      likes: metrics.score.likeCount,
    );
  }

  static Stream<PackageData> fetchPackages({int page = 1}) async* {
    final client = PubClient();
    final results = await client.search('', sort: SearchOrder.top, page: page);

    for (var result in results.packages) {
      late final PackageData package;
      try {
        package = await PackageData.fromPackageResult(result);
      } catch (e) {
        package = PackageData(
          name: result.package,
          publisher: 'unknown',
          published: DateTime.now(),
          popularityScore: 0,
          likes: 0,
          notes: 'error: $e',
        );
      }

      yield package;
    }
  }
}
