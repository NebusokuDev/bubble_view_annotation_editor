import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension ThemeBuilder on Brightness {
  ThemeData theme(
    BuildContext context, {
    Color seedColor = Colors.indigoAccent,
  }) {
    final theme = Theme.of(context);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: this,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.notoSansJpTextTheme(Theme.of(context).textTheme),
      dialogTheme: theme.dialogTheme.copyWith(shape: themeShape),
      cardTheme: theme.cardTheme.copyWith(
        shape: themeShape,
        elevation: themeElevation,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(),
      ),
    );
  }
}

final ShapeBorder themeShape = ContinuousRectangleBorder(
  borderRadius: BorderRadius.circular(10 * 2.3529),
);

final double themeElevation = 10;
