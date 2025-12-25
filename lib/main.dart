import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/temperature_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    print('Firebase initialized successfully');
    
    // Check database connection
    await firebaseService.checkDatabaseConnection();
    
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Show error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TemperatureProvider(),
      child: MaterialApp(
        title: 'Vaccine Temperature Monitor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
