import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/ui/bloc/audio_cubit.dart';
import 'package:tetris/ui/bloc/background_image_cubit.dart';
import 'package:tetris/ui/bloc/score_cubit.dart';
import 'package:tetris/ui/bloc/tetris_bloc.dart';
import 'package:tetris/ui/screens/main_menu_screen.dart';
import 'package:tetris/ui/screens/tetris_single_play_screen.dart';
import 'package:tetris/app_const.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  }, (error, stackTrace) {
    // Здесь можно логировать ошибки в сервисы мониторинга
    print('Caught an error: $error');
    print('Stacktrace: $stackTrace');
  }, zoneSpecification: ZoneSpecification(
    // Переопределение функции print для добавления дополнительной информации
    print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      final taggedLine = "[${DateTime.now()}] $line";
      parent.print(zone, taggedLine);
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TetrisBloc()),
        BlocProvider(create: (_) => ScoreCubit()),
        BlocProvider(create: (_) => AudioCubit()),
        BlocProvider(create: (_) => BackgroundImageCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Tetris',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          dialogTheme: DialogTheme(
            backgroundColor: Colors.black.withOpacity(0.8),
            titleTextStyle: AppTextStyle.mediumText,
          ),
          textTheme: const TextTheme(
            titleLarge: AppTextStyle.largeText,
            titleMedium: AppTextStyle.mediumText,
            titleSmall: AppTextStyle.smallText,
          ),
        ),
        routes: {
          AppRoutes.main: (context) => const MainMenuScreen(),
          AppRoutes.tetris: (context) => const TetrisSinglePlayScreen(),
        },
        home: BlocBuilder<AudioCubit, bool>(
          builder: (BuildContext context, state) => const MainMenuScreen(),
        ),
      ),
    );
  }
}
