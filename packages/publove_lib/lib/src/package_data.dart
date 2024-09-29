import 'package:pub_api_client/pub_api_client.dart';

import 'package_notes.dart';

class PackageData {
  PackageData({
    required this.name,
    required this.published,
    required this.popularityScore,
    required this.isNullSafe,
    required this.isDart3,
    required this.likes,
  }) : daysSincePublished = DateTime.now().difference(published).inDays;

  final String name;
  final DateTime published;
  final int daysSincePublished;
  final double popularityScore;
  final bool isNullSafe;
  final bool isDart3;
  final int likes;
  String get notes => packageNotes[name] ?? '';

  /// ratio of days since publication to popularity score
  double get loveNum => daysSincePublished / popularityScore;

  String get url => 'https://pub.dev/packages/$name';

  static Future<PackageData> fromPackageResult(PackageResult result) async {
    final client = PubClient();
    final name = result.package;
    final info = await client.packageInfo(name);
    final metrics = (await client.packageMetrics(name))!;
    final scorecard = metrics.scorecard;

    return PackageData(
      name: name,
      published: info.latest.published,
      popularityScore: metrics.score.popularityScore!,
      isNullSafe:
          scorecard.panaReport?.derivedTags?.contains('is:null-safe') == true,
      isDart3:
          scorecard.panaReport?.derivedTags?.contains('is:dart3-compatible') ==
              true,
      likes: metrics.score.likeCount,
    );
  }

  static Future<List<PackageData>> fetchPackages({int page = 1}) async {
    final client = PubClient();
    final results = await client.search('', sort: SearchOrder.top, page: page);
    return Future.wait(
      results.packages.map((result) => PackageData.fromPackageResult(result)),
    );
  }
}
