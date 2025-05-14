import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class KaydedilenHaberlerEkraniWeb extends StatelessWidget {
  const KaydedilenHaberlerEkraniWeb({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      
    }
  }

  Future<void> _haberiSil(User user, String link) async {
    final ref = FirebaseFirestore.instance
        .collection('kullanicilar')
        .doc(user.uid)
        .collection('kaydedilenHaberler');

    final query = await ref.where('link', isEqualTo: link).get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kaydedilenler')),
        body: const Center(child: Text('Lütfen giriş yapın')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kaydedilenler')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kullanicilar')
            .doc(user.uid)
            .collection('kaydedilenHaberler')
            .orderBy('savedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Hata: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Hiç haber kaydedilmemiş."));

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final link = data['link'] ?? '';

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListTile(
                      onTap: () {
                        if (link.isNotEmpty) {
                          _launchURL(link);
                        }
                      },
                      leading: data['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['imageUrl'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image_not_supported, size: 60),
                      title: Text(data['title'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(data['pubDate'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark_remove),
                        tooltip: "Kaydı sil",
                        onPressed: () async {
                          await _haberiSil(user, link);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Haber kayıtlardan çıkarıldı')),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
