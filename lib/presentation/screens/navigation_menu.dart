import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'reward/reward_screen.dart';
import 'transaction/transaction_screen.dart';


class NavigationMenu extends StatelessWidget {
  NavigationMenu({super.key});
  final NavigationController navController = Get.find();

  final List<Widget> screens = const [
    HomeScreen(),
    RewardScreen(),
    TransactionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: screens[navController.selectedIndex.value],
        bottomNavigationBar: NavigationBar(
          selectedIndex: navController.selectedIndex.value,
          onDestinationSelected: navController.changeIndex,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home),
                label: "Beranda",
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet_giftcard_rounded),
              label: "Hadiah",
            ),
            NavigationDestination(
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
