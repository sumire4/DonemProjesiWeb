import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'ekranlar/haberDetayEkrani.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HaberEkrani extends StatefulWidget {
  const HaberEkrani({Key? key}) : super(key: key);

  @override
  State<HaberEkrani> createState() => _HaberEkraniState();
}

class _HaberEkraniState extends State<HaberEkrani> {
  late Future<List<Map<String, String>>> _haberler;

  @override
  void initState() {
    super.initState();
    _haberler = fetchHaberler();
  }

  Future<List<Map<String, String>>> fetchHaberler() async {
    // Test için örnek veriler
    await Future.delayed(Duration(seconds: 1)); // Simüle edilmiş ağ gecikmesi
    
    return [
      {
        'title': 'Alonso\'dan Verstappen\'e övgüler: "Bana 2012\'yi hatırlatıyor"',
        'description': 'Suzuka\'da pole pozisyonunu kazanan ve ardından kariyerinin 64. yarış zaferine ulaşan Verstappen\'in performansı, İspanyol pilottan büyük övgü aldı.',
        'pubDate': '8 Nisan 2024',
        'imageUrl': 'https://cdn-1.motorsport.com/images/amp/Y99JQRbY/s1000/max-verstappen-red-bull-racing.jpg',
        'link': 'https://tr.motorsport.com/f1/news/alonsodan-verstappene-ovguler-bana-2012yi-hatirlatiyor/10710956/'
      },
      {
        'title': 'Norris: "Red Bull, yavaş virajlarda bizden daha hızlı"',
        'description': 'McLaren pilotu, Suzuka\'daki performanslarını değerlendirdi.',
        'pubDate': '8 Nisan 2024',
        'imageUrl': 'https://cdn-1.motorsport.com/images/amp/2jXZgDx0/s1000/lando-norris-mclaren-1.jpg',
        'link': 'https://tr.motorsport.com/f1/news/norris-red-bull-yavas-virajlarda-bizden-daha-hizli/10710953/'
      },
      {
        'title': 'Verstappen: "Araçtaki sorunlar henüz çözülmedi"',
        'description': 'Red Bull pilotu, Suzuka\'daki zaferinin ardından konuştu.',
        'pubDate': '8 Nisan 2024',
        'imageUrl': 'https://cdn-1.motorsport.com/images/amp/0RrGWmM0/s1000/max-verstappen-red-bull-racing.jpg',
        'link': 'https://tr.motorsport.com/f1/news/verstappen-aractaki-sorunlar-henuz-cozulmedi/10710947/'
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _haberler = fetchHaberler();
          });
        },
        child: FutureBuilder<List<Map<String, String>>>(
          future: _haberler,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hata: ${snapshot.error}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _haberler = fetchHaberler();
                        });
                      },
                      child: const Text("Tekrar Dene"),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Hiç haber bulunamadı."));
            }

            final haberler = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: haberler.length,
              itemBuilder: (context, index) {
                final haber = haberler[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      final url = Uri.parse(haber['link']!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (haber['imageUrl'] != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: haber['imageUrl']!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  haber['title'] ?? 'Başlık Yok',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (haber['description'] != null)
                                  Expanded(
                                    child: Text(
                                      haber['description']!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                Text(
                                  haber['pubDate'] ?? '',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
