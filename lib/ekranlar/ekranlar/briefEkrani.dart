import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:donemprojesi/ekranlar/chat_message.dart';
import 'package:donemprojesi/ekranlar/chat_bubble.dart';

class BriefEkrani extends StatefulWidget {
  @override
  _BriefEkraniState createState() => _BriefEkraniState();
}

class _BriefEkraniState extends State<BriefEkrani> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;
  

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    _initializeModel();
    _getInitialF1Prediction();
  }

  void _initializeModel() {
    const apiKey = 'deneme';

    try {
      _model = GenerativeModel(model: 'gemini-2.5-pro-exp-03-25', apiKey: apiKey);
      print("Gemini API başarıyla başlatıldı!");
    } catch (e) {
      print("Gemini API başlatılamadı: $e");
      setState(() {
        _messages.add(ChatMessage(text: 'API başlatılamadı: $e', isUser: false));
      });
    }
  }

  Future<void> _getInitialF1Prediction() async {
    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(text: 'F1 tahminleri alınıyor...', isUser: false));
    });

    try {
      final response = await _model.generateContent([Content.text('Önümüzdeki Formula 1 yarışı için bir sıralama tahmini yapar mısın? Nedenlerini kısaca açıkla.(uygulama açılınca ilk prompt olacak harika soru vs şeyler yazma, kısaca ilk 5e kim girer ve sence kim kazanır onu söyle.)')]);

      setState(() {
        _isLoading = false;
        _messages.removeLast(); // "Tahminler alınıyor..." mesajını kaldır

        String? text;

        try {
          // ignore: unnecessary_null_comparison
          if (response.candidates != null && response.candidates.isNotEmpty && response.candidates.first.content.parts.isNotEmpty) {
            final part = response.candidates.first.content.parts.first;
            if (part is TextPart) {
              text = part.text;
            }
          }
        } catch (e) {
          print("Yanıt işlenirken hata oluştu: $e");
        }

        _messages.add(ChatMessage(text: text ?? 'Tahmin alınırken bir hata oluştu veya cevap boş geldi.', isUser: false));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.removeLast();
        _messages.add(ChatMessage(text: 'Hata: $e', isUser: false));
      });
    } finally {
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _messages.add(ChatMessage(text: 'Cevap bekleniyor...', isUser: false));
      _textController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _model.generateContent([Content.text(message)]);

      setState(() {
        _isLoading = false;
        _messages.removeLast();

        final firstPart = response.candidates.first.content.parts.first;
        String? text = (firstPart is TextPart) ? firstPart.text : null;

        _messages.add(ChatMessage(text: text ?? 'Cevap alınırken bir hata oluştu.', isUser: false));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.removeLast();
        _messages.add(ChatMessage(text: 'Hata: $e', isUser: false));
      });
    } finally {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Material 3 renk paleti
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600, // Buton rengi
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(17, 33, 33, 37),
        appBar: AppBar(backgroundColor: const Color.fromRGBO(35, 35, 40, 0.067),
          title: Text('F1 Tahminleri ve Sohbet',style: TextStyle(color: const Color.fromARGB(255, 245, 242, 242)
          , fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
                ),
                if (_isLoading) LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Gemini\'ye soru sorun...',
                            hintStyle: TextStyle(color: Colors.grey[400]), // ipucu rengi
                            filled: true,
                            fillColor: const Color.fromARGB(17, 54, 54, 58), // arka plan rengi
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: TextStyle(color: Colors.white), // yazı rengi
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _sendMessage(value.trim());
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text.trim().isNotEmpty) {
                            _sendMessage(_textController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(117, 101, 101, 117), // buton arka plan rengi
                          foregroundColor: Colors.white, // buton yazı rengi
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          minimumSize: Size(120, 55), // genişlik ve yükseklik ayarı
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Gönder',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
