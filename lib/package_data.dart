import 'package:pub_api_client/pub_api_client.dart';

class PackageData {
  PackageData({
    required this.name,
    required this.published,
    required this.popularityScore,
    required this.isNullSafe,
    required this.isDart3,
    required this.likes,
    this.notes = '',
  }) : daysSincePublished = DateTime.now().difference(published).inDays;

  final String name;
  final DateTime published;
  final int daysSincePublished;
  final double popularityScore;
  final bool isNullSafe;
  final bool isDart3;
  final int likes;
  final String notes;

  /// ratio of days since publication to popularity score
  double get ratio => daysSincePublished / popularityScore;

  static Future<PackageData> fromPackageResult(PackageResult result) async {
    final client = PubClient(debug: true);
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
      notes: name == 'provider'
          ? 'the author of provider recommends using riverpod instead'
          : '',
    );
  }

  static Future<List<PackageData>> fetchPackages() async {
    final client = PubClient(debug: true);
    final results = await client.search('', sort: SearchOrder.top);
    return Future.wait(
      results.packages.map((result) => PackageData.fromPackageResult(result)),
    );
  }
}
