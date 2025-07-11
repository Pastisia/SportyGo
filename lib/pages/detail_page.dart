import 'package:flutter/material.dart';
import 'booking_form_page.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> lapangan;

  DetailPage({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Column(
        children: [
          // Bagian Gambar dengan tombol back
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  lapangan['foto_url'] ?? '',
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 280,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.orange),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite_border, color: Colors.orange),
                ),
              ),
            ],
          ),

          // Konten Detail
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lapangan['nama_lapangan'] ?? '-',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    lapangan['lokasi'] ?? '-',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Rp ${lapangan['harga_per_jam']} / jam",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(Icons.star,
                              color: Colors.orange, size: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    lapangan['deskripsi'] ?? 'Tidak ada deskripsi.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  Spacer(),

                  // Tombol Booking
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingPage(lapangan: lapangan),
                          ),
                        );
                      },
                      child: Text(
                        'BOOK NOW',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
