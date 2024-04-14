import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris/ui/bloc/score_cubit.dart';
import 'package:tetris/ui/screens/main_menu_screen.dart';
import 'package:tetris/ui/screens/tetris_single_play_screen.dart';
import 'app_const.dart';
import 'ui/bloc/tetris_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TetrisBloc()),
        BlocProvider(create: (_) => ScoreCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Tetris',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          dialogTheme: DialogTheme(
            backgroundColor: Colors.black.withOpacity(0.8), // Черный с прозрачностью
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
        home: const MainMenuScreen(),
      ),
    );
  }
}