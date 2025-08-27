class AdminPhoto {
  final int id;
  final String title;
  final String url;
  final bool isSelected;

  AdminPhoto({
    required this.id,
    required this.title,
    required this.url,
    required this.isSelected,
  });

  factory AdminPhoto.fromJson(Map<String, dynamic> json) {
    return AdminPhoto(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'isSelected': isSelected,
    };
  }
}
