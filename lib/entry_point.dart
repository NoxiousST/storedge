import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:storedge/constants.dart';
import 'package:storedge/main.dart';
import 'package:storedge/route/route_constants.dart';
import 'package:storedge/route/screen_export.dart';
import 'package:storedge/screens/item/item_list_screen.dart';
import 'package:storedge/screens/pages.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late void Function() myMethod;

  late final List _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ItemListScreen(
        builder: (BuildContext context, void Function() methodFromChild) {
          myMethod = methodFromChild; // Assign the method from the child
        },
      ),
      const Page1(),
    ];
  }

  int _currentIndex = 0;

  ThemeMode themeMode = ThemeMode.light;

  bool get useLightMode => switch (themeMode) {
        ThemeMode.system =>
          View.of(context).platformDispatcher.platformBrightness ==
              Brightness.light,
        ThemeMode.light => true,
        ThemeMode.dark => false
      };

  PreferredSizeWidget createAppBar() {
    return AppBar(title: const Text('StorEdge'), actions: [
      _BrightnessButton(
        handleBrightnessChange: (useLightMode) =>
            Main.of(context).handleBrightnessChange(useLightMode),
      ),
    ]);
  }

  void handleScreenChanged(int screenSelected) {
    setState(() {
      _currentIndex = screenSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBars(
        onSelectItem: (index) {
          setState(() {
            _currentIndex = index;
            handleScreenChanged(_currentIndex);
          });
        },
        selectedIndex: _currentIndex,
        isExampleBar: false,
      ),
      floatingActionButton: RotationTransition(
          turns: const AlwaysStoppedAnimation(45 / 360),
          child: FloatingActionButton(
            backgroundColor: Colors.indigoAccent,
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            onPressed: () =>
                Navigator.pushNamed(context, itemFormScreenRoute).then((res) {
              if (res == 'refresh') {
                _pages[0].refreshItems();
              }
            }),
            child: Icon(Icons.close_rounded,
                size: 24, color: Theme.of(context).colorScheme.onPrimary),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    required this.handleBrightnessChange,
  });

  final Function handleBrightnessChange;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      message: 'Toggle brightness',
      child: IconButton(
        icon: isBright
            ? const Icon(Icons.dark_mode_outlined)
            : const Icon(Icons.light_mode_outlined),
        onPressed: () => handleBrightnessChange(!isBright),
      ),
    );
  }
}

class NavigationBars extends StatefulWidget {
  const NavigationBars({
    super.key,
    this.onSelectItem,
    required this.selectedIndex,
    required this.isExampleBar,
    this.isBadgeExample = false,
  });

  final void Function(int)? onSelectItem;
  final int selectedIndex;
  final bool isExampleBar;
  final bool isBadgeExample;

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant NavigationBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    // App NavigationBar should get first focus.
    Widget navigationBar = Focus(
      autofocus: !(widget.isExampleBar || widget.isBadgeExample),
      child: NavigationBar(
        elevation: 4,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (!widget.isExampleBar) widget.onSelectItem!(index);
        },
        destinations: appBarDestinations,
      ),
    );

    return navigationBar;
  }
}

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_rounded),
    label: 'Dashboard',
    selectedIcon: Icon(Icons.widgets),
  ),
  NavigationDestination(
    icon: Icon(Icons.tune_rounded),
    label: 'Setting',
    selectedIcon: Icon(Icons.tune_rounded),
  ),
];
