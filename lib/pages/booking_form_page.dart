import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> lapangan;

  BookingPage({required this.lapangan});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _tanggal;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;
  final Dio _dio = Dio();
  bool _loading = false;

  bool _isEndTimeAfterStart(TimeOfDay start, TimeOfDay end) {
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      start.hour,
      start.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      end.hour,
      end.minute,
    );
    return endDateTime.isAfter(startDateTime);
  }

  Future<void> _submitBooking() async {
    if (_tanggal == null || _jamMulai == null || _jamSelesai == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lengkapi semua data booking.')));
      return;
    }

    // Validasi jam selesai harus lebih dari jam mulai
    if (!_isEndTimeAfterStart(_jamMulai!, _jamSelesai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jam selesai harus lebih dari jam mulai.')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final tanggalBooking = DateFormat('yyyy-MM-dd').format(_tanggal!);
    final jamMulai = _jamMulai!.format(context);
    final jamSelesai = _jamSelesai!.format(context);

    setState(() => _loading = true);

    try {
      print(
        "Booking dikirim ke: http://sportygo.fortunis11.com/API-SportyGo/booking/create.php",
      );
      print(
        "Data booking: {id_user: $userId,id_lapangan: ${widget.lapangan['id']},tanggal_booking: $tanggalBooking,jam_mulai: $jamMulai,jam_selesai: $jamSelesai}",
      );

      final response = await _dio.post(
        'http://sportygo.fortunis11.com/API-SportyGo/booking/create.php',
        data: {
          'id_user': userId,
          'id_lapangan': widget.lapangan['id'].toString(),
          'tanggal_booking': tanggalBooking,
          'jam_mulai': jamMulai,
          'jam_selesai': jamSelesai,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final result =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking berhasil!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking gagal: ${result['message']}')),
        );
      }
    } catch (e) {
      print("Error saat booking: $e"); // 👈 tambahkan ini
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat booking.')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pickTime(bool isMulai) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isMulai) {
          _jamMulai = picked;
        } else {
          _jamSelesai = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Lapangan'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lapangan['nama_lapangan'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(widget.lapangan['lokasi']),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(
                _tanggal != null
                    ? DateFormat('dd MMMM yyyy').format(_tanggal!)
                    : 'Pilih Tanggal',
              ),
              onTap: _pickDate,
            ),

            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(
                _jamMulai != null
                    ? 'Jam Mulai: ${_jamMulai!.format(context)}'
                    : 'Pilih Jam Mulai',
              ),
              onTap: () => _pickTime(true),
            ),

            ListTile(
              leading: Icon(Icons.access_time_outlined),
              title: Text(
                _jamSelesai != null
                    ? 'Jam Selesai: ${_jamSelesai!.format(context)}'
                    : 'Pilih Jam Selesai',
              ),
              onTap: () => _pickTime(false),
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _loading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text(
                  _loading ? 'Loading...' : 'Kirim Booking',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
