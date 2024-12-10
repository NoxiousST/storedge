import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:storedge/constants.dart';
import 'package:storedge/models/itemmodel.dart';
import 'package:storedge/route/screen_export.dart';
import 'package:storedge/screens/item/components/item_card.dart';
import 'package:storedge/services/database_helper.dart';

typedef MyBuilder = void Function(
    BuildContext context, void Function() methodFromChild);

class ItemListScreen extends StatefulWidget {
  final MyBuilder builder;

  const ItemListScreen({super.key, required this.builder});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<ItemModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    refreshItems();
  }

   void refreshItems() {
    setState(() {
      _itemsFuture = _dbHelper.getAllItems();
    });
  }

  void _showMarkedAsDoneSnackbar(bool? isMarkedAsDone) {
    log(isMarkedAsDone.toString());
    if (isMarkedAsDone ?? false) {
      refreshItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, refreshItems);
    return Scaffold(
        body: FutureBuilder<List<ItemModel>>(
            future: _itemsFuture, // Fetch items from the database
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No items found"));
              }

              final items = snapshot.data!;

              return CustomScrollView(slivers: [
                SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding, vertical: defaultPadding),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200.0,
                        mainAxisSpacing: defaultPadding,
                        crossAxisSpacing: defaultPadding,
                        childAspectRatio: 0.58,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final item = items[index];

                          return _OpenContainerWrapper(
                            transitionType: ContainerTransitionType.fade,
                            closedBuilder:
                                (BuildContext _, VoidCallback openContainer) {
                              return ItemCard(
                                image: item.image,
                                name: item.name,
                                price: item.price,
                                stock: item.stock,
                                category: item.category!,
                                openContainer: openContainer,
                              );
                            },
                            item: item,
                            onClosed: _showMarkedAsDoneSnackbar,
                          );
                        },
                        childCount: items.length,
                      ),
                    ))
              ]);
            }));
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper(
      {required this.closedBuilder,
      required this.transitionType,
      required this.onClosed,
      required this.item});

  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool?> onClosed;
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious),
        ),
        child: OpenContainer<bool>(
          transitionType: transitionType,
          openBuilder: (BuildContext context, VoidCallback _) {
            return ItemDetailsScreen(item: item);
          },
          onClosed: onClosed,
          tappable: false,
          closedBuilder: closedBuilder,
        ));
  }
}
