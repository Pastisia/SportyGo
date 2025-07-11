import 'package:flutter/material.dart';
import 'home_page.dart';

class BantuanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pusat Bantuan"),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Butuh Bantuan?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Jika kamu mengalami masalah saat menggunakan aplikasi ini atau memiliki pertanyaan, silakan hubungi kami melalui:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.orange),
              title: Text('WhatsApp Admin'),
              subtitle: Text('0812-3456-7890'),
              onTap: () {
                // Bisa diarahkan ke WA link kalau mau
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Colors.orange),
              title: Text('Email'),
              subtitle: Text('support@sportygo.com'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.orange),
              title: Text('FAQ (Pertanyaan Umum)'),
              subtitle: Text(
                'Cek jawaban dari pertanyaan umum seputar penggunaan aplikasi.',
              ),
              onTap: () {
                // Tambahkan navigasi ke halaman FAQ jika diperlukan
              },
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'Terima kasih telah menggunakan SportyGo!',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
