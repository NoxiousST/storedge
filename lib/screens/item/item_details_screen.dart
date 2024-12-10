import 'dart:developer';
import 'dart:io';

import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:storedge/constants.dart';
import 'package:storedge/models/history.dart';
import 'package:storedge/models/itemmodel.dart';
import 'package:storedge/route/route_constants.dart';
import 'package:storedge/screens/item/components/item_info.dart';
import 'package:storedge/services/database_helper.dart';

class ItemDetailsScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailsScreen> {
  final _duration = 750;
  final _delay = 150;

  final DatabaseHelper db = DatabaseHelper();
  late Future<List<History>> _historyFuture;
  late ItemModel item;
  int stock = 0;
  bool refresh = false;

  @override
  void initState() {
    item = widget.item;

    _showWidgetsWithDelays();
    _refreshHistory();
    super.initState();
  }

  Future<void> _refreshItem() async {
    try {
      final refreshedItem = await db.getItemById(item.id!);
      setState(() {
        item = refreshedItem;
        refresh = true;
      });
    } catch (error) {
      log('Something went wrong: $error');
    }
  }

  Future<void> _refreshHistory() async {
    try {
      _historyFuture = db.getHistory(widget.item.id!);
      final history = await _historyFuture;

      if (mounted) {
        setState(() {
          stock = history.fold(
            0,
            (total, hist) =>
                hist.type == 0 ? total + hist.amount : total - hist.amount,
          );
        });
      }
    } catch (error) {
      log('Something went wrong: $error');
    }
  }

  Future<void> _deleteItem() async {
    const successMessage = "Item successfully deleted.";
    const errorMessage = "Item failed to delete.";

    try {
      db.deleteItem(widget.item.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(successMessage)),
      );

      setState(() {
        refresh = true;
      });

    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  final List<bool> _isVisible = List.filled(7, false);

  void _showWidgetsWithDelays() {
    for (int i = 0; i < _isVisible.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + _delay * i), () {
        setState(() {
          _isVisible[i] = true; // Set each widget to visible after a delay
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        if (context.mounted) {
          Navigator.pop(context, refresh);
        }
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    floating: true,
                    actions: [
                      IconButton(
                          onPressed: () async {
                            final bool shouldPop = await _dialogBuilder() ?? false;
                            if (context.mounted && shouldPop) {
                              Navigator.pop(context, refresh);
                            }
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.red)
                    ]),
                SliverToBoxAdapter(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious * 2),
                      ),
                      child: Image.file(File(item.image)),
                    ),
                  ),
                ),
                ItemInfo(
                  title: item.name,
                  description: item.description!,
                  price: item.price,
                  category: item.category!,
                  stock: stock,
                  isVisible: _isVisible,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding, vertical: defaultPadding / 2),
                  sliver: SliverToBoxAdapter(
                    child: Entry.all(
                      visible: _isVisible[5],
                      duration: Duration(milliseconds: _duration),
                      scale: 1,
                      child: Text(
                        "Riwayat Barang",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<History>>(
                    future: _historyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SliverToBoxAdapter(
                          child: Entry.all(
                              visible: _isVisible[6],
                              duration: Duration(milliseconds: _duration),
                              scale: 1,
                              child: const Center(
                                  child: CircularProgressIndicator())),
                        );
                      } else if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Entry.all(
                              visible: _isVisible[6],
                              duration: Duration(milliseconds: _duration),
                              scale: 1,
                              child: Center(
                                  child: Text("Error: ${snapshot.error}"))),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SliverToBoxAdapter(
                            child: Entry.all(
                                visible: _isVisible[6],
                                duration: Duration(milliseconds: _duration),
                                scale: 1,
                                child: const Center(
                                    child: Text("No history found"))));
                      }

                      final history = snapshot.data!;

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Entry.all(
                              visible: _isVisible[6],
                              duration: Duration(milliseconds: _duration),
                              scale: 1,
                              child: HistoryCard(history: history[index])),
                          childCount: history.length,
                        ),
                      );
                    }),
                const SliverToBoxAdapter(child: SizedBox(height: 120))
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Entry.all(
            visible: _isVisible[5],
            duration: Duration(milliseconds: _duration),
            scale: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 36, right: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: FilledButton(
                      onPressed: () => Navigator.pushNamed(
                              context, itemFormScreenRoute,
                              arguments: widget.item)
                          .then((res) {
                        if (res == 'refresh') {
                          _refreshItem();
                        }
                      }),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        fixedSize: const Size(double.infinity, 60),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16)),
                        ),
                      ),
                      child: Text("Edit Barang",
                          style: Theme.of(context).textTheme.titleSmall!.apply(
                              color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: FilledButton(
                      onPressed: () => Navigator.pushNamed(
                          context, historyFormScreenRoute,
                          arguments: {
                            "item": widget.item,
                            "stock": stock,
                          }).then((res) {
                        if (res == 'refresh') {
                          _refreshHistory();
                        }
                      }),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        fixedSize: const Size(double.infinity, 60),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16)),
                        ),
                      ),
                      child: const Text("Tambah Riwayat"),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Future<bool?> _dialogBuilder() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Do you really want to delete this item? This processs cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                _deleteItem();
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }
}

class HistoryCard extends StatelessWidget {
  final History history;

  const HistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding, vertical: defaultPadding / 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding / 3),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(defaultBorderRadious)),
            child: Icon(
                history.type == 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 36,
                color: history.type == 0 ? Colors.teal : Colors.red),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTime.fromMillisecondsSinceEpoch(history.date)
                    .toLocal()
                    .toString()
                    .split(' ')[0],
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Text(history.type == 0 ? 'Masuk' : 'Keluar',
                  style: Theme.of(context).textTheme.bodyLarge)
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(defaultPadding / 2),
                  decoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      borderRadius:
                          BorderRadius.circular(defaultBorderRadious)),
                  child: Text(
                    history.amount.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .apply(color: Theme.of(context).colorScheme.onPrimary),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
