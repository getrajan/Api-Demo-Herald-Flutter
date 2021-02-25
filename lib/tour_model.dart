class TourModel {
  String id;
  String title;
  String description;
  String coverPhotoURL;

  TourModel({
    this.id,
    this.title,
    this.description,
    this.coverPhotoURL,
  });

  factory TourModel.fromMap(Map<String, dynamic> map) {
    return TourModel(
        id: map['_id'],
        title: map['title'],
        description: map['description'],
        coverPhotoURL: map['coverPhoto']);
  }
}
