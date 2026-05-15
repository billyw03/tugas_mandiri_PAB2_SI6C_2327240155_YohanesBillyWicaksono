import 'package:lapor_jalan_app/models/laporan_jalan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _laporanCollection = _database.collection(
    'laporan_jalan',
  );

  static Future<void> addLaporan(LaporanJalan laporan) async {
    Map<String, dynamic> newLaporan = {
      'image': laporan.image,
      'description': laporan.description,
      'kategori_kerusakan': laporan.kategoriKerusakan,
      'latitude': laporan.latitude,
      'longitude': laporan.longitude,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': laporan.userId,
      'user_full_name': laporan.userFullName,
    };

    await _laporanCollection.add(newLaporan);
  }

  static Future<void> updateLaporan(LaporanJalan laporan) async {
    Map<String, dynamic> updatedLaporan = {
      'image': laporan.image,
      'description': laporan.description,
      'kategori_kerusakan': laporan.kategoriKerusakan,
      'latitude': laporan.latitude,
      'longitude': laporan.longitude,
      'created_at': laporan.createdAt,
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': laporan.userId,
      'user_full_name': laporan.userFullName,
    };

    await _laporanCollection.doc(laporan.id).update(updatedLaporan);
  }

  static Future<void> deleteLaporan(LaporanJalan laporan) async {
    await _laporanCollection.doc(laporan.id).delete();
  }

  static Future<QuerySnapshot> retrieveLaporan() {
    return _laporanCollection.get();
  }

  static Stream<List<LaporanJalan>> getLaporanList() {
    return _laporanCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
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
          }).toList();
        });
  }
}
