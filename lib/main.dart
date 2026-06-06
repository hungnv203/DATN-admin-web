import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/cinema_remote_data_source.dart';
import 'data/datasources/movie_remote_data_source.dart';
import 'data/datasources/showtime_remote_data_source.dart';
import 'data/datasources/booking_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/cinema_repository_impl.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'data/repositories/showtime_repository_impl.dart';
import 'data/repositories/booking_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cinema_provider.dart';
import 'presentation/providers/movie_provider.dart';
import 'presentation/providers/showtime_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/dashboard_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dioClient = DioClient();
  
  final cinemaRepository = CinemaRepositoryImpl(CinemaRemoteDataSourceImpl(dioClient));
  final showtimeRepository = ShowtimeRepositoryImpl(ShowtimeRemoteDataSourceImpl(dioClient));
  final bookingRepository = BookingRepositoryImpl(BookingRemoteDataSourceImpl(dioClient));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthRepositoryImpl(
              AuthRemoteDataSourceImpl(dioClient),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CinemaProvider(cinemaRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieProvider(
            MovieRepositoryImpl(
              MovieRemoteDataSourceImpl(dioClient),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ShowtimeProvider(showtimeRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(
            bookingRepository: bookingRepository,
            showtimeRepository: showtimeRepository,
          ),
        ),
      ],
      child: const MovieBookingAdminApp(),
    ),
  );
}

class MovieBookingAdminApp extends StatelessWidget {
  const MovieBookingAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return MaterialApp(
      title: 'MovieBooking Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1015),
        primaryColor: const Color(0xFF66FCF1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16171E),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Color(0xFFC5C6C7)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF66FCF1)),
          ),
        ),
      ),
      home: authProvider.isAuthenticated ? const DashboardShell() : const LoginScreen(),
    );
  }
}
