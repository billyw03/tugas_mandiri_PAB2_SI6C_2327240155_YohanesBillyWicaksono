import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lapor_jalan_app/services/laporan_service.dart';
import 'package:lapor_jalan_app/models/laporan_jalan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filter kategori yang dipilih, null = Semua
  String? _selectedKategori;

  // Daftar semua kategori (sama persis dengan AddLaporanScreen)
  final List<String> _kategoriList = [
    'Jalan Berlubang',
    'Aspal Retak',
    'Jalan Amblas',
    'Genangan Air',
    'Longsor di Jalan',
  ];

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  String generateAvatarUrl(String? fullName) {
    final formattedName = (fullName ?? 'User').trim().replaceAll(' ', '+');
    return 'https://ui-avatars.com/api/?name=$formattedName&color=FFFFFF&background=E53935';
  }

  // Fungsi filter laporan berdasarkan kategori yang dipilih
  List<LaporanJalan> _filterLaporan(List<LaporanJalan> semua) {
    if (_selectedKategori == null) return semua;
    return semua
        .where((l) => l.kategoriKerusakan == _selectedKategori)
        .toList();
  }

  // Warna per kategori untuk chip filter
  Color _getChipColor(String kategori) {
    switch (kategori) {
      case 'Jalan Berlubang':
        return const Color(0xFFE53935);
      case 'Aspal Retak':
        return const Color(0xFFFF7043);
      case 'Jalan Amblas':
        return const Color(0xFFD84315);
      case 'Genangan Air':
        return const Color(0xFF1565C0);
      case 'Longsor di Jalan':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lapor Jalan Rusak',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Keluar'),
                  content: const Text(
                    'Apakah Anda yakin ingin keluar dari akun?',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(color: Color(0xFFE53935)),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) signOut();
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header profil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    generateAvatarUrl(currentUser?.displayName),
                    width: 72,
                    height: 72,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.white24,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser?.displayName ?? 'Pengguna',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentUser?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Label daftar laporan
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Daftar Laporan Jalan Rusak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),

          // ===== FILTER CHIP BY KATEGORI =====
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Chip "Semua"
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Semua'),
                    selected: _selectedKategori == null,
                    onSelected: (_) {
                      setState(() => _selectedKategori = null);
                    },
                    selectedColor: const Color(0xFFE53935),
                    labelStyle: TextStyle(
                      color: _selectedKategori == null
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _selectedKategori == null
                          ? const Color(0xFFE53935)
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                ),
                // Chip per kategori
                ..._kategoriList.map((kategori) {
                  final isSelected = _selectedKategori == kategori;
                  final chipColor = _getChipColor(kategori);
                  // Label singkat biar muat di chip
                  final shortLabel = kategori
                      .replaceAll('Jalan ', '')
                      .replaceAll('Aspal ', '');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(shortLabel),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedKategori = kategori);
                      },
                      selectedColor: chipColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? chipColor : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }),
              ],
            ),
          ),

          // ===== END FILTER CHIP =====
          const SizedBox(height: 8),

          // List laporan
          Expanded(
            child: StreamBuilder(
              stream: LaporanService.getLaporanList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE53935)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                final semuaLaporan = snapshot.data ?? [];

                // Filter berdasarkan kategori yang dipilih
                final laporanList = _filterLaporan(semuaLaporan);

                if (laporanList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report_problem_outlined,
                          size: 72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedKategori == null
                              ? 'Belum ada laporan.'
                              : 'Belum ada laporan\nkategori "$_selectedKategori".',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedKategori == null
                              ? 'Tekan tombol + untuk menambah laporan'
                              : 'Coba pilih kategori lain atau tambah laporan baru',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {},
                  color: const Color(0xFFE53935),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: laporanList.length,
                    itemBuilder: (context, index) {
                      final laporan = laporanList[index];
                      final isOwner =
                          currentUserId != null &&
                          laporan.userId == currentUserId;
                      return LaporanListItem(
                        laporan: laporan,
                        isOwner: isOwner,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddLaporanScreen()),
          );
        },
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text(
          'Tambah Laporan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
