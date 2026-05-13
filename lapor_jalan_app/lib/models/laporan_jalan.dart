import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanJalan {
  String? id;
  String? image;
  String? description;
  String? kategoriKerusakan;
  String? latitude;
  String? longitude;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String? userId;
  String? userFullName;

  LaporanJalan({
    this.id,
    this.image,
    this.description,
    this.kategoriKerusakan,
    this.longitude,
    this.latitude,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.userFullName,
  });

  factory LaporanJalan.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return LaporanJalan(
      id: doc.id,
      image: data['image'],
      description: data['description'],
      kategoriKerusakan: data['kategori_kerusakan'],
      createdAt: data['created_at'] != null
          ? data['created_at'] as Timestamp
          : null,
      updatedAt: data['updated_at'] != null
          ? data['updated_at'] as Timestamp
          : null,
      latitude: data['latitude'],
      longitude: data['longitude'],
      userId: data['user_id'],
      userFullName: data['user_full_name'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'image': image,
      'description': description,
      'kategori_kerusakan': kategoriKerusakan,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
      'user_full_name': userFullName,
    };
  }
}
