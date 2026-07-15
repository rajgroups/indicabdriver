import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/routes/routes.dart';
import 'package:indicab_driver/services/SocketService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SocketService(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Indicab Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC107)),
        scaffoldBackgroundColor: const Color(0xFFF8F8F5),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes, // This was missing
    );
  }
}
