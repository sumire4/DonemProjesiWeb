import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:donemprojesi/ekranlar/brief/chat_message.dart';
import 'package:donemprojesi/ekranlar/brief/chat_bubble.dart';
import 'package:donemprojesi/services/chat_gpt_service.dart';

class Race {
  final String name;
  final DateTime date;

  Race({required this.name, required this.date});

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      name: json['name'],
      date: DateTime.parse(json['race_date']),
    );
  }
}

Future<List<Race>> loadRaces() async {
  final jsonString = await rootBundle.loadString('assets/f1_races_2025.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((json) => Race.fromJson(json)).toList();
}

Race findNextRace(List<Race> races) {
  final now = DateTime.now();
  races.sort((a, b) => a.date.compareTo(b.date));
  return races.firstWhere((race) => race.date.isAfter(now));
}

class BriefEkrani extends StatefulWidget {
  const BriefEkrani({super.key});

  @override
  _BriefEkraniState createState() => _BriefEkraniState();
}

class _BriefEkraniState extends State<BriefEkrani> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late ChatGPTService _chatService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
    _getInitialF1Prediction();
  }

  void _initializeModel() {
    const apiKey = ' ';
    _chatService = ChatGPTService(apiKey);
  }

  Future<void> _getInitialF1Prediction() async {
    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(text: 'Analiz Ediliyor...', isUser: false));
    });

    try {
      final races = await loadRaces();
      final nextRace = findNextRace(races);
      final today = DateTime.now();

      final prompt = '''
        Bugünün tarihi: ${today.toIso8601String()}

        Önümüzdeki Formula 1 yarışı: ${nextRace.name}, tarihi: ${nextRace.date.toIso8601String()}

        Lütfen pist koşulları ve hava durumunu dikkate alarak bu yarış için pilot ve takım sıralama tahmini yap ve nedenlerini detaylı bir şekilde ayrıntılı olarak açıkla.
        ilk başa da önümüzdeki yarışın konumu ve tarihini yaz
        ''';

      final cevap = await _chatService.sendMessage(prompt);

      setState(() {
        _isLoading = false;
        _messages.removeLast();
        _messages.add(ChatMessage(text: cevap, isUser: false));
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
      // İstersen burada da prompt'u güncelleyip yarışı ekleyebilirsin.
      final cevap = await _chatService.sendMessage(message);

      setState(() {
        _isLoading = false;
        _messages.removeLast();
        _messages.add(ChatMessage(text: cevap, isUser: false));
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
        duration: const Duration(milliseconds: 300),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(17, 33, 33, 37),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(35, 35, 40, 0.067),
          title: const Text(
            'F1 Tahminleri ve Sohbet',
            style: TextStyle(
              color: Color.fromARGB(255, 245, 242, 242),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
                if (_isLoading) const LinearProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'ChatGPT\'ye soru sorun...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color.fromARGB(17, 54, 54, 58),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _sendMessage(value.trim());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text.trim().isNotEmpty) {
                            _sendMessage(_textController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(117, 101, 101, 117),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          minimumSize: const Size(120, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
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
