import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'home_page.dart';

class EditBookingPage extends StatefulWidget {
  final Map booking;

  EditBookingPage({required this.booking});

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.parse(widget.booking['tanggal_booking']);
    _startTime = _parseTime(widget.booking['jam_mulai']);
    _endTime = _parseTime(widget.booking['jam_selesai']);
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm:ss').format(dt);
  }

  Future<void> _submitEdit() async {
    if (_selectedDate == null || _startTime == null || _endTime == null) return;

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jam selesai harus lebih besar dari jam mulai.'),
        ),
      );
      return;
    }

    print({
      'id': widget.booking['id'].toString(),
      'tanggal_booking': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'jam_mulai': _formatTime(_startTime!),
      'jam_selesai': _formatTime(_endTime!),
    });

    try {
      final response = await _dio.post(
        'http://sportygo.fortunis11.com/API-SportyGo/booking/update.php',
        data: {
          'id': widget.booking['id'].toString(),
          'tanggal_booking': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'jam_mulai': _formatTime(_startTime!),
          'jam_selesai': _formatTime(_endTime!),
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      dynamic result = response.data;
      if (result is String) {
        result = jsonDecode(result);
      }

      if (result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking berhasil diperbarui.')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memperbarui booking.'),
          ),
        );
      }
    } catch (e) {
      print('Error saat submit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memperbarui booking.')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime! : _endTime!,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanggalStr =
        _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : 'Pilih tanggal';

    final jamMulaiStr =
        _startTime != null ? _startTime!.format(context) : 'Pilih jam mulai';
    final jamSelesaiStr =
        _endTime != null ? _endTime!.format(context) : 'Pilih jam selesai';

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Booking'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text('Tanggal Booking'),
                subtitle: Text(tanggalStr),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              Divider(),
              ListTile(
                title: Text('Jam Mulai'),
                subtitle: Text(jamMulaiStr),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(isStart: true),
              ),
              Divider(),
              ListTile(
                title: Text('Jam Selesai'),
                subtitle: Text(jamSelesaiStr),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(isStart: false),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitEdit,
                child: Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
