import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  factory MyApp() {
    final shoppingCartRepo = ShoppingCartRepo();
    final appRouter = Router(shoppingCartRepo: shoppingCartRepo);
    return MyApp._(appRouter);
  }

  final Router appRouter;

  const MyApp._(this.appRouter);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: appRouter.buildRouterDelegate());
  }
}

class Router {
  final ShoppingCartRepo shoppingCartRepo;
  Router({required this.shoppingCartRepo});

  Widget getShoppingScreen() {
    final shoppingViewModel = ShoppingViewModel(shoppingCartRepo);
    return ShoppingScreen(viewModel: shoppingViewModel);
  }

  Widget getCheckoutScreen() {
    final checkoutViewModel = CheckoutViewModel(shoppingCartRepo);
    return CheckoutScreen(viewModel: checkoutViewModel);
  }

  GoRouter buildRouterDelegate() {
    return GoRouter(routes: <RouteBase>[
      GoRoute(
          path: "/",
          builder: (BuildContext context, GoRouterState state) =>
              getShoppingScreen()),
      GoRoute(
          path: "/checkout",
          builder: (BuildContext context, GoRouterState state) =>
              getCheckoutScreen())
    ]);
  }
}

//Person is shopping on a  home feed, we need a counter in the corner
class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key, required this.viewModel});
  final ShoppingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: viewModel.shoppingCartCount,
        builder: (context, state, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.toString()),
              ElevatedButton(
                  onPressed: () => context.go('/checkout'),
                  child: const Text("checkout"))
            ],
          );
        });
  }
}

//In checkout screen, we need number of items
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.viewModel});
  final CheckoutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: viewModel.shoppingCartCount,
        builder: (context, state, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.toString()),
              ElevatedButton(
                  onPressed: viewModel.updateShoppingCartCount,
                  child: const Text("update")),
              ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text("go to shop"))
            ],
          );
        });
  }
}

class CheckoutViewModel {
  ValueNotifier<int> shoppingCartCount = ValueNotifier<int>(0);
  final ShoppingCartRepo shoppingCartRepo;

  CheckoutViewModel(this.shoppingCartRepo) {
    getRepoValue();
    shoppingCartRepo.addListener(getRepoValue);
  }

  void updateShoppingCartCount() {
    shoppingCartRepo.updateItemsInCart();
  }

  void getRepoValue() {
    print(shoppingCartRepo.numItemsInCart);
    shoppingCartCount.value = shoppingCartRepo.numItemsInCart;
  }

  void dispose() {
    shoppingCartRepo.removeListener(getRepoValue);
  }
}

class ShoppingViewModel {
  ValueNotifier<int> shoppingCartCount = ValueNotifier<int>(0);
  final ShoppingCartRepo shoppingCartRepo;

  ShoppingViewModel(this.shoppingCartRepo) {
    getRepoValue();
    shoppingCartRepo.addListener(getRepoValue);
  }

  void updateShoppingCartCount() {
    shoppingCartRepo.updateItemsInCart();
  }

  void getRepoValue() {
    print(shoppingCartRepo.numItemsInCart);
    shoppingCartCount.value = shoppingCartRepo.numItemsInCart;
  }

  void dispose() {
    shoppingCartRepo.removeListener(getRepoValue);
  }
}

class ShoppingCartRepo extends ChangeNotifier {
  var numItemsInCart = 0;

  void updateItemsInCart() {
    numItemsInCart += 1;
    notifyListeners();
  }
}
