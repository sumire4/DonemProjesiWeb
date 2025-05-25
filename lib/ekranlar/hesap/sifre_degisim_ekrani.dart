import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SifreDegisimEkrani extends StatefulWidget {
  const SifreDegisimEkrani({super.key});

  @override
  _SifreDegisimEkraniState createState() => _SifreDegisimEkraniState();
}

class _SifreDegisimEkraniState extends State<SifreDegisimEkrani> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _eskiSifreController = TextEditingController();
  final TextEditingController _yeniSifreController = TextEditingController();
  final TextEditingController _yeniSifreTekrarController = TextEditingController();

  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  Future<void> _sifreDegistir() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapılmamış.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Re-authenticate (eski şifre doğrulama)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _eskiSifreController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // Şifreyi güncelle
      await user.updatePassword(_yeniSifreController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifreniz başarıyla değiştirildi.')),
      );

      // İstersen ekranı kapat veya temizle
      _eskiSifreController.clear();
      _yeniSifreController.clear();
      _yeniSifreTekrarController.clear();

    } on FirebaseAuthException catch (e) {
      String mesaj = 'Bir hata oluştu.';
      if (e.code == 'wrong-password') {
        mesaj = 'Eski şifre yanlış.';
      } else if (e.code == 'weak-password') {
        mesaj = 'Şifre çok zayıf.';
      } else if (e.code == 'requires-recent-login') {
        mesaj = 'Güvenlik nedeniyle yeniden giriş yapmanız gerekiyor.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mesaj)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _eskiSifreController.dispose();
    _yeniSifreController.dispose();
    _yeniSifreTekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şifre Değiştir'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _eskiSifreController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Eski Şifre',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Eski şifre boş olamaz';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _yeniSifreController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Yeni şifre boş olamaz';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _yeniSifreTekrarController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre (Tekrar)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tekrar şifre boş olamaz';
                      }
                      if (value != _yeniSifreController.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _sifreDegistir,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Şifreyi Değiştir'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
