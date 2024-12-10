import 'package:flutter/material.dart';
import 'package:storedge/entry_point.dart';
import 'package:storedge/models/itemmodel.dart';
import 'package:storedge/route/route_constants.dart';
import 'package:storedge/screens/item/history_form_screen.dart';

import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    /*case itemListScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          return const ItemListScreen();
        },
      );*/
    case itemFormScreenRoute:
      final args = settings.arguments as ItemModel?;
      return MaterialPageRoute(
        builder: (context) {
          return ItemFormScreen(item: args);
        },
      );
    case itemDetailsScreenRoute:
      final item = settings.arguments as ItemModel;
      return MaterialPageRoute(
        builder: (context) {
          return ItemDetailsScreen(item: item);
        },
      );
    case historyFormScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) {
          return HistoryFormScreen(
            item: args['item'],
            stock: args['stock'],
          );
        },
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
  }
}
