import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_page.dart';
import 'edit_booking_page.dart';
import 'riwayat_page.dart';
import 'akun_page.dart';
import 'bantuan_page.dart';
import 'semua_lapangan_page.dart';

class BookingHistoryPage extends StatefulWidget {
  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  List<dynamic> _bookings = [];
  final Dio _dio = Dio();
  bool _isLoading = true;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    try {
      final response = await _dio.get(
        'http://sportygo.fortunis11.com/API-SportyGo/booking/read_user.php',
        queryParameters: {
          'id_user': userId,
          'nocache': DateTime.now().millisecondsSinceEpoch, // Tambahan ini
        },
      );

      var result = response.data;
      if (result is String) result = jsonDecode(result);

      print("Response dari API: $result");

      if (result['success'] == true) {
        setState(() {
          _bookings = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _bookings = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error saat fetch: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBooking(String id) async {
    try {
      final response = await _dio.post(
        'http://sportygo.fortunis11.com/API-SportyGo/booking/delete.php',
        data: FormData.fromMap({'id': id}),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      var result = response.data;
      if (result is String) result = jsonDecode(result);

      if (result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking berhasil dibatalkan.')));

        setState(() {
          _bookings.clear();
          _isLoading = true;
        });

        await _fetchHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal membatalkan booking.'),
          ),
        );
      }
    } catch (e) {
      print("Error saat hapus: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat membatalkan booking')),
      );
    }
  }

  void _confirmDelete(String id) {
    print("ID Booking yang diklik: $id (${id.runtimeType})");

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Konfirmasi'),
            content: Text('Yakin ingin membatalkan booking ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tidak'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteBooking(id);
                },
                child: Text('Ya, Batalkan'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Booking'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
              ? Center(child: Text('Belum ada riwayat booking'))
              : ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final item = _bookings[index];
                  final bookingId = item['id'].toString();

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(item['nama_lapangan']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal: ${item['tanggal_booking']}'),
                          Text(
                            'Jam: ${item['jam_mulai']} - ${item['jam_selesai']}',
                          ),
                          Text('Status: ${item['status']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditBookingPage(booking: item),
                                ),
                              );
                              if (updated == true) {
                                _fetchHistory(); // refresh list jika ada perubahan
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDelete(
                                bookingId,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SemuaLapanganPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => BookingHistoryPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AccountPage()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => BantuanPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lapangan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Bantuan',
          ),
        ],
      ),
    );
  }
}
