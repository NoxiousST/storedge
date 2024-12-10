import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storedge/constants.dart';
import 'package:storedge/utils/currency_text_input_formatter.dart';

class ItemCard extends StatelessWidget {
  ItemCard(
      {super.key,
      required this.image,
      required this.name,
      required this.price,
      required this.stock,
      required this.category,
      required this.openContainer});

  final String image, name, category;
  final double price;
  final int stock;
  final VoidCallback openContainer;

  final _formatter = CurrencyTextInputFormatter.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      height: 220,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(defaultBorderRadious),
              ),
              child: Image.file(File(image)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2, vertical: defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!),
                  const SizedBox(height: 2),
                  Text(
                    _formatter.formatDouble(price),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 18,
                        color: Colors.indigoAccent,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(defaultBorderRadious / 2)
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Text(stock.toString(),
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InkWellOverlay extends StatelessWidget {
  const _InkWellOverlay({
    this.openContainer,
    this.height,
    this.child,
  });

  final VoidCallback? openContainer;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: openContainer,
        child: child,
      ),
    );
  }
}
