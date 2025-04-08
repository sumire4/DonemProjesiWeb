import 'package:donemprojesi/anasayfa.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase web yapılandırması
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB2cj0rR_vBvVp_PKgK3ddZcbo4Di12R9s",
      authDomain: "donemprojesi-d99fe.firebaseapp.com",
      projectId: "donemprojesi-d99fe",
      storageBucket: "donemprojesi-d99fe.firebasestorage.app",
      messagingSenderId: "963698986672",
      appId: "1:963698986672:web:b51379c67b71560abc3575",
      measurementId: "G-FE6D2CP51Q"
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
