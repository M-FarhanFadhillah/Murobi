import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:masjid/bloc/ayat/ayat_bloc.dart';
import 'package:masjid/cubit/surat/surat_cubit.dart';
import 'package:masjid/data/api_service.dart';
import 'package:masjid/ui/surat_page.dart';

// Tab Al-Qur'an di navigasi bawah. Providernya sama dengan MyApp di main.dart:
// SuratCubit untuk daftar surat dan AyatBloc untuk isi surat.
class QuranTab extends StatelessWidget {
  const QuranTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SuratCubit(
            ApiService(
              client: http.Client(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => AyatBloc(
            ApiService(
              client: http.Client(),
            ),
          ),
        ),
      ],
      child: const SuratPage(),
    );
  }
}
