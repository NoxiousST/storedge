import 'dart:io';

import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storedge/models/itemmodel.dart';
import 'package:storedge/screens/item/components/image_input.dart';
import 'package:storedge/services/database_helper.dart';
import 'package:storedge/utils/currency_text_input_formatter.dart';

enum ImageSourceType { gallery, camera }

class ItemFormScreen extends StatefulWidget {
  final ItemModel? item;

  const ItemFormScreen({super.key, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final List<String> listCategory = <String>[
    'Graphics Card',
    'Processor',
    'Motherboard',
    'Memory'
  ];
  final _gap = 20.0;
  final _duration = 750;
  final _delay = 150;

  final db = DatabaseHelper.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  late String _dropdownValue;
  late bool _isItem;

  File? _image;

  late FocusNode myFocusNode;

  final _formatter = CurrencyTextInputFormatter.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    setState(() {
      _isItem = widget.item != null;
      _dropdownValue = listCategory.first;
    });

    myFocusNode = FocusNode();

    if (widget.item != null) {
      setState(() {
        _image = File(widget.item!.image);
        _dropdownValue = widget.item!.category!;
      });
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description ?? '';
      _priceController.text = _formatter.formatDouble(widget.item!.price);
      _categoryController.text = widget.item!.category ?? '';
    }
  }

  Future<void> _saveItem(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image.')),
      );
      return;
    }

    final item = ItemModel(
      _nameController.text,
      _descriptionController.text,
      _formatter.getDouble(),
      _dropdownValue,
      _image!.path,
      0,
    );

    final successMessage =
        _isItem ? "Item successfully updated." : "Item successfully added.";
    const errorMessage = "Item failed to save.";

    try {
      await (_isItem
          ? db.updateItem(widget.item!.id!, item)
          : db.insertItem(item));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        Navigator.pop(context, 'refresh');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Entry.all(
                    duration: Duration(milliseconds: _duration),
                    child: ImageInput(
                      imagePath: _isItem ? widget.item!.image : null,
                      onImageSelected: (File? image) {
                        setState(() {
                          _image = image;
                        });
                      },
                    )),
                SizedBox(height: _gap),
                Entry.all(
                    scale: 1,
                    duration: Duration(milliseconds: _duration),
                    delay: Duration(milliseconds: _delay * 1),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter item name",
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    )),
                SizedBox(height: _gap),
                Entry.all(
                    scale: 1,
                    duration: Duration(milliseconds: _duration),
                    delay: Duration(milliseconds: _delay * 2),
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: "Enter item description",
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    )),
                SizedBox(height: _gap),
                Entry.all(
                    scale: 1,
                    duration: Duration(milliseconds: _duration),
                    delay: Duration(milliseconds: _delay * 3),
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[_formatter],
                      decoration: const InputDecoration(
                        hintText: "Enter the price",
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                    )),
                SizedBox(height: _gap),
                Entry.all(
                    scale: 1,
                    duration: Duration(milliseconds: _duration),
                    delay: Duration(milliseconds: _delay * 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: DropdownMenu<String>(
                        expandedInsets: EdgeInsets.zero,
                        initialSelection: _dropdownValue,
                        label: const Text('Category'),
                        onSelected: (String? value) {
                          setState(() {
                            _dropdownValue = value!;
                          });
                        },
                        dropdownMenuEntries: listCategory
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                              value: value,
                              label: value
                          );
                        }).toList(),
                      ),
                    )),
              ],
            ),
          ),
        )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Visibility(
          visible: !keyboardIsOpen,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.indigoAccent,
              minimumSize: const Size.fromHeight(55),
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () => _saveItem(context),
            child: Text(widget.item == null ? 'Tambah' : 'Update',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold)),
          ),
        ));
  }
}
