import 'package:donemprojesi/ekranlar/hesap/giris_ekrani.dart';
import 'package:donemprojesi/ekranlar/hesap/kaydedilen_haberler_web.dart';
import 'package:donemprojesi/ekranlar/hesap/profil_duzenle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


// ignore: use_key_in_widget_constructors
class HesabimEkraniWeb extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HesabimEkraniWebState createState() => _HesabimEkraniWebState();
}

class _HesabimEkraniWebState extends State<HesabimEkraniWeb> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> _kullaniciVerisi;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _kullaniciVerisi = FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(user!.uid)
          .get();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(child: Text("Giriş yapılmamış.")); // Web'de GirişEkranı yönlendirmesi farklı ele alınmalı
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _kullaniciVerisi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Kullanıcı verisi bulunamadı.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final favoriPilot = data['favoriPilot'] ?? 'Belirtilmemiş';
          final favoriTakim = data['favoriTakim'] ?? 'Belirtilmemiş';
          final kayitTarihi = data['kayitTarihi'] != null
              ? DateFormat('dd.MM.yyyy HH:mm')
                  .format((data['kayitTarihi'] as Timestamp).toDate())
              : 'Bilinmiyor';

          String dosyaAdiDonustur(String isim) {
            return isim.toLowerCase().replaceAll(" ", "_");
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(data['profilResmi'] ?? ''),
                    ),
                    SizedBox(height: 12),
                    Text(user!.email ?? 'E-posta yok',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/pilotlar/${dosyaAdiDonustur(favoriPilot)}.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (_, __, ___) => Icon(Icons.person, size: 80),
                        ),
                        SizedBox(width: 16),
                        Image.asset(
                          'assets/images/takimlar/${dosyaAdiDonustur(favoriTakim)}.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (_, __, ___) => Icon(Icons.flag, size: 80),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _profilBilgiTile(Icons.star, "Favori Pilot", favoriPilot),
                    _profilBilgiTile(Icons.directions_car, "Favori Takım", favoriTakim),
                    _profilBilgiTile(Icons.calendar_today, "Katılma Tarihi", kayitTarihi),
                    SizedBox(height: 24),
                    _profilButton(Icons.edit, "Profili Düzenle", () {
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => ProfilDuzenleWebEkrani(favoriPilot: favoriPilot, 
                      favoriTakim: favoriTakim,
                         ),
                        ),
                      );
                    }),
                    _profilButton(Icons.bookmarks, "Kaydedilenler", () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => KaydedilenHaberlerEkraniWeb()),
                    );
                    }),
                    _profilButton(Icons.logout, "Çıkış Yap", () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(builder: (context) => GirisEkrani()),
                        (route) => false, // önceki sayfaları sil
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _profilBilgiTile(IconData icon, String baslik, String deger) {
    return ListTile(
      leading: Icon(icon),
      title: Text(baslik),
      subtitle: Text(deger),
    );
  }

  Widget _profilButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
