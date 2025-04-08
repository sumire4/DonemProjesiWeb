import 'package:donemprojesi/ekranlar/ekranlar/gecmisYarislarSayfasi.dart';
import 'package:flutter/material.dart';
import 'ekranlar/ekranlar/hesabimEkrani.dart';
import 'ekranlar/girişEkrani.dart';
import 'ekranlar/haberEkrani.dart';
import 'ekranlar/ekranlar/briefEkrani.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HaberEkrani(), // Haberler (index 0)
    GecmisYarislarSayfasi(),
    Briefekrani(),
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
          MaterialPageRoute(builder: (context) => HesabimEkrani()),
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
    
    String _getTitle() {
      switch (_selectedIndex) {
        case 0:
          return "Haberler";
        case 1:
          return "Skorlar";
        case 2:
          return "AI";
        case 3:
          return "Hesap";
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
                    _getTitle(),
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
                        label: Text('Skor'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.auto_awesome),
                        label: Text('AI'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person),
                        label: Text('Hesap'),
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
                NavigationDestination(icon: Icon(Icons.sports_score), label: "Skor"),
                NavigationDestination(icon: Icon(Icons.auto_awesome), label: "AI"),
                NavigationDestination(icon: Icon(Icons.person), label: "Hesap"),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            )
          : null,
    );
  }
}