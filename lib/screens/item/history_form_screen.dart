import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_button/group_button.dart';
import 'package:storedge/models/history.dart';
import 'package:storedge/models/itemmodel.dart';
import 'package:storedge/services/database_helper.dart';

class HistoryFormScreen extends StatefulWidget {
  final ItemModel item;
  final int stock;

  const HistoryFormScreen({super.key, required this.item, required this.stock});

  @override
  State<HistoryFormScreen> createState() => _HistoryFormScreenState();
}

class _HistoryFormScreenState extends State<HistoryFormScreen> {
  final _gap = 20.0;
  final _radioButton = ["Masuk", "Keluar"];

  final db = DatabaseHelper.instance;

  final _formKey = GlobalKey<FormState>();
  final _typeController = GroupButtonController(selectedIndex: 0);
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  late FocusNode myFocusNode;

  @override
  void initState() {
    if (widget.stock == 0) _typeController.disableIndexes([1]);
    super.initState();
    myFocusNode = FocusNode();
  }
  Future<void> _saveHistory(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final history = History(
        _typeController.selectedIndex!,
        int.parse(_amountController.text),
        selectedDate.millisecondsSinceEpoch,
        widget.item.id!,
      );

      const successMessage = "History successfully added.";
      const errorMessage = "History failed to save.";

      try {
        await db.insertHistory(history);

        // Update the item stock based on the type
        widget.item.stock += history.type == 0 ? history.amount : -history.amount;
        await db.updateItem(widget.item.id!, widget.item);

        // Only show the snack bar and pop if context is mounted
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(successMessage)),
          );
          Navigator.pop(context, 'refresh');
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Riwayat"),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: GroupButton(
                  options: GroupButtonOptions(
                      mainGroupAlignment: MainGroupAlignment.start,
                      buttonHeight: 50,
                      buttonWidth: 120,
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.indigoAccent,
                      unselectedColor: Colors.indigoAccent[50]),
                  isRadio: true,
                  controller: _typeController,
                  onSelected: (indexStr, index, isSelected) =>
                      log('$index button is selected $index and $isSelected'),
                  buttons: _radioButton,
                ),
              ),
              SizedBox(height: _gap),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.filter_8_rounded),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  hintText: "0",
                  labelText: 'Amount',
                ),
                validator: (value) {
                  if ((value == null || value.isEmpty) ||
                      (_typeController.selectedIndex == 1 &&
                          (int.parse(value) > widget.stock))) {
                    return 'Please enter item amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: _gap),
              TextFormField(
                controller: _dateController,
                canRequestFocus: false,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_month_rounded),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  hintText: "Enter history date",
                  labelText: 'Date',
                ),
                keyboardType: TextInputType.multiline,
              ),
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
          onPressed: () => _saveHistory(context),
          child: Text("Add",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
