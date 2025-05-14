import 'package:donemprojesi/ekranlar/puandurum/gecmis_yarislar_sayfasi.dart';
import 'package:flutter/material.dart';
import 'hesap/hesabim_ekrani.dart';
import 'hesap/giris_ekrani.dart';
import 'haber/haber_ekrani.dart';
import 'brief/brief_ekrani.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HaberEkrani(), // Haberler (index 0)
    GecmisYarislarSayfasi(),
    BriefEkrani(),
    const Center(child: Text('Hesap')), // Hesap (index 3) - Giriş ekranına yönlendiriliyor
  ];

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      final user = FirebaseAuth.instance.currentUser;

      // Oturum açık mı kontrol et
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GirisEkrani()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0; // Girişten geri gelince "Haber" sekmesine dön
          });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HesabimEkraniWeb()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0; // Profil ekranından çıkınca da ana sayfaya dön
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    String getTitle() {
      switch (_selectedIndex) {
        case 0:
          return "Haberler";
        case 1:
          return "Puan Durumu";
        case 2:
          return "Yapay Zeka";
        case 3:
          return "Profil";
        default:
          return "Haberler";
      }
    }

    return Scaffold(
      body: Row(
        children: [
          if (!isSmallScreen)
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width >= 800 ? 200 : 80,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    getTitle(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: NavigationRail(
                    extended: MediaQuery.of(context).size.width >= 800,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.article),
                        label: Text('Haber'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.sports_score),
                        label: Text('Puan Durumu'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.auto_awesome),
                        label: Text('Yapay Zeka'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person),
                        label: Text('Profil'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Expanded(
            child: _selectedIndex < _widgetOptions.length - 1
                ? _widgetOptions[_selectedIndex]
                : const Center(child: Text("Hesap")),
          ),
        ],
      ),
      bottomNavigationBar: isSmallScreen
          ? NavigationBar(
              height: 60,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.article), label: "Haber"),
                NavigationDestination(icon: Icon(Icons.sports_score), label: "Puan Durumu"),
                NavigationDestination(icon: Icon(Icons.auto_awesome), label: "Yapay Zeka"),
                NavigationDestination(icon: Icon(Icons.person), label: "Profil"),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            )
          : null,
    );
  }
}