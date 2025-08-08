// lib/app/data/models/news_item.dart
class NewsItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  final String? content; // full text (for detail)
  final String? externalUrl;
  bool isBookmarked;

  NewsItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    this.content,
    this.externalUrl,
    this.isBookmarked = false,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String? ?? 'Unknown',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      content: json['content'] as String?,
      externalUrl: json['externalUrl'] as String?,
      isBookmarked: (json['isBookmarked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'source': source,
    'publishedAt': publishedAt.toIso8601String(),
    'content': content,
    'externalUrl': externalUrl,
    'isBookmarked': isBookmarked,
  };

  NewsItem copyWith({bool? isBookmarked}) =>
      NewsItem(
        id: id,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        source: source,
        publishedAt: publishedAt,
        content: content,
        externalUrl: externalUrl,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );
}
