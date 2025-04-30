import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';


class HaberEkrani extends StatefulWidget {
  const HaberEkrani({super.key});

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
  final url = Uri.parse('https://api.allorigins.win/get?url=${Uri.encodeComponent('https://tr.motorsport.com/rss/f1/news/')}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> jsonData = jsonDecode(data);
    final rssString = jsonData['contents'];

    final rssFeed = RssFeed.parse(rssString);

    return rssFeed.items.map((item) {
      final imageUrl = item.enclosure?.url ?? ''; // ✔️ Enclosure'dan resim al
      return {
        'title': item.title ?? '',
        'description': _cleanHtmlTags(item.description ?? ''),
        'pubDate': item.pubDate ?? '',
        'imageUrl': imageUrl,
        'link': item.link ?? '',
      };
    }).toList();
  } else {
    throw Exception('RSS verisi alınamadı. Hata kodu: ${response.statusCode}');
  }
}

  
  String _cleanHtmlTags(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '').trim();
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.75 : 0.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
                        if (haber['imageUrl'] != null && haber['imageUrl']!.isNotEmpty)
                          SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: haber['imageUrl']!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
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
                                  haber['title'] ?? '',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    haber['description'] ?? '',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
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
