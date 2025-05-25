import 'package:flutter/material.dart';
import '../../../models/pilot_model.dart';
import '../../../models/takim_model.dart';
import '../../../services/pilot_service.dart';
import '../../../services/takim_service.dart';

class StandingsEkrani extends StatefulWidget {
  const StandingsEkrani({super.key});

  @override
  State<StandingsEkrani> createState() => _StandingsEkraniState();
}

class _StandingsEkraniState extends State<StandingsEkrani> {
  late Future<List<TakimModel>> takimSiralama;
  late Future<List<PilotModel>> pilotSiralama;

  String secilenSayfa = 'pilot'; // 'pilot' veya 'takim'

  @override
  void initState() {
    super.initState();
    takimSiralama = TakimService.getirTakimSiralama();
    pilotSiralama = PilotService.getirPilotSiralama();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Butonlar geniş ekranda yatay, dar ekranda dikey
            isWideScreen
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildToggleButtons(),
                  )
                : Column(
                    children: _buildToggleButtons(),
                  ),
            const SizedBox(height: 16),
            Expanded(
              child: secilenSayfa == 'pilot'
                  ? _buildPilotSiralama()
                  : _buildTakimSiralama(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildToggleButtons() {
    return [
      ElevatedButton(
        onPressed: () {
          setState(() {
            secilenSayfa = 'pilot';
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: secilenSayfa == 'pilot' ? Colors.blueAccent : null,
          foregroundColor: secilenSayfa == 'pilot' ? Colors.white : null,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text("Pilot Sıralaması"),
      ),
      const SizedBox(width: 12, height: 12),
      ElevatedButton(
        onPressed: () {
          setState(() {
            secilenSayfa = 'takim';
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: secilenSayfa == 'takim' ? Colors.blueAccent : null,
          foregroundColor: secilenSayfa == 'takim' ? Colors.white : null,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text("Takım Sıralaması"),
      ),
    ];
  }

  Widget _buildPilotSiralama() {
    return FutureBuilder<List<PilotModel>>(
      future: pilotSiralama,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Veri bulunamadı'));
        } else {
          final pilots = snapshot.data!;
          final double imageSize =
              MediaQuery.of(context).size.width >= 800 ? 60 : 40;

          return ListView.separated(
            itemCount: pilots.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final pilot = pilots[index];

              return ListTile(
                leading: ClipOval(
                  child: Image.asset(
                    getPilotAssetImage(pilot.driverName),
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 40),
                  ),
                ),
                title: Text(pilot.driverName),
                subtitle:
                    Text('Takım: ${pilot.teamName} | Puan: ${pilot.points}'),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildTakimSiralama() {
    return FutureBuilder<List<TakimModel>>(
      future: takimSiralama,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Veri bulunamadı'));
        } else {
          final teams = snapshot.data!;
          final double imageSize =
              MediaQuery.of(context).size.width >= 800 ? 60 : 40;

          return ListView.separated(
            itemCount: teams.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final takim = teams[index];

              final logoDosyaAdi = '${takim.displayName.toLowerCase().replaceAll(' ', '_').replaceAll('.', '')}.png';

              return ListTile(
                leading: ClipOval(
                  child: Image.asset(
                    'assets/images/takimlar/$logoDosyaAdi',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
                title: Text(takim.displayName),
                subtitle: Text('Sıra: ${takim.rank} | Puan: ${takim.points}'),
              );
            },
          );
        }
      },
    );
  }
}
