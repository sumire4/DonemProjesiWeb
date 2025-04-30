import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KayitEkrani extends StatefulWidget {
  @override
  _KayitEkraniState createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _kayitOl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kayıt başarılı -> Giriş ekranına yönlendir
      Navigator.pop(context); // Giriş ekranına geri dön
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _handleFirebaseAuthError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _handleFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi girdiniz.';
      case 'weak-password':
        return 'Parola çok zayıf (en az 6 karakter olmalı).';
      default:
        return 'Bilinmeyen bir hata oluştu.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _kayitOl,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Kayıt Ol'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
