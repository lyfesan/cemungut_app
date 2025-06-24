import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'home_screen.dart';
import 'reward/reward_screen.dart';
import 'transaction/transaction_screen.dart';


class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  final NavigationController navController = Get.find();

  // 2. Create GlobalKeys for each widget to be showcased
  final GlobalKey _orderCardKey = GlobalKey();
  final GlobalKey _pointsCardKey = GlobalKey();
  final GlobalKey _rewardsTabKey = GlobalKey();
  final GlobalKey _detectionKey = GlobalKey();
  final GlobalKey _educationKey = GlobalKey();
  final GlobalKey _bankSampahKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Use this callback to ensure widgets are built before starting the showcase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial();
    });
  }

  // 3. Logic to check preference and start the showcase
  Future<void> _showTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final didShowTutorial = prefs.getBool('didShowCemungutTutorial') ?? false;

    if (!didShowTutorial) {
      ShowCaseWidget.of(context).startShowCase([
        _orderCardKey,
        _pointsCardKey,
        _detectionKey,
        _educationKey,
        _bankSampahKey,
        _rewardsTabKey,
      ]);
      // Set the flag to true so the tutorial doesn't show again
      await prefs.setBool('didShowCemungutTutorial', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. Pass the keys down to the HomeScreen
    final List<Widget> screens = [
      HomeScreen(
        orderCardKey: _orderCardKey,
        pointsCardKey: _pointsCardKey,
        detectionKey: _detectionKey,
        educationKey: _educationKey,
        bankSampahKey: _bankSampahKey,
      ),
      const RewardScreen(),
      const TransactionScreen(),
    ];

    return Obx(
          () => Scaffold(
        body: screens[navController.selectedIndex.value],
        bottomNavigationBar: NavigationBar(
          selectedIndex: navController.selectedIndex.value,
          onDestinationSelected: navController.changeIndex,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Beranda",
            ),
            // 5. Wrap the "Hadiah" tab with its Showcase widget
            Showcase(
              key: _rewardsTabKey,
              title: 'Tukar Poin',
              description: 'Tukarkan poin yang Anda kumpulkan dengan hadiah menarik di sini!',
              child: const NavigationDestination(
                icon: Icon(Icons.wallet_giftcard_rounded),
                label: "Hadiah",
              ),
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Transaksi",
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  void resetIndex() {
    selectedIndex.value = 0;
  }

}
