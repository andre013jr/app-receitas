import 'package:flutter/material.dart';
import 'screens/initial_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // Importe o Firebase Core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // CORREÇÃO: Adicione o parâmetro "options" com as suas credenciais
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBWFI1M_G-7wxtFAyYxV2Tqz6JLizz0Mzo",
      authDomain: "app-receitas-andre-caio.firebaseapp.com",
      projectId: "app-receitas-andre-caio",
      storageBucket: "app-receitas-andre-caio.appspot.com", // Corrigi o domínio do storage bucket
      messagingSenderId: "101078431598",
      appId: "1:101078431598:web:da63fd9850117be7aab37f",
      measurementId: "G-EP26HV4SEN"
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receitas App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const InitialScreen(),
    );
  }
}