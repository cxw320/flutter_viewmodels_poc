import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(RootApp());
}

//STEP1) Initialize the root of our widget tree.
class RootApp extends StatelessWidget {
  //Advantage of using factory method here:
  //We want this to be the public facing constructor that takes in no parameters.
  //Instead, we call the private constructor to pass in dependencies the appRouter may need.
  //In this case, we initialize and pass in ShoppingCartRepo.
  factory RootApp() {
    final shoppingCartRepo = ShoppingCartRepo();
    final appRouter = Router(shoppingCartRepo: shoppingCartRepo);
    return RootApp._(appRouter);
  }

  final Router appRouter;

  //Private constructor that takes in our navigation class.
  const RootApp._(this.appRouter);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: appRouter.buildRouterDelegate());
  }
}

//STEP2) Initialize our navigation class:
class Router {
  //Shopping repository is in the highest level here in router so it can be available to both viewmodels
  final ShoppingCartRepo shoppingCartRepo;
  Router({required this.shoppingCartRepo});

  //This creates our ShoppingScreen widget and the ShoppingViewModel instance
  Widget getShoppingScreen() {
    final shoppingViewModel = ShoppingViewModel(shoppingCartRepo);
    return ShoppingScreen(viewModel: shoppingViewModel);
  }

//This creates our CheckoutScreen widget and the CheckoutViewModel instance
  Widget getCheckoutScreen() {
    final checkoutViewModel = CheckoutViewModel(shoppingCartRepo);
    return CheckoutScreen(viewModel: checkoutViewModel);
  }

  //This method returns the GoRouter we delegate we need to attach to our rootwidget.
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

//Imagine this is a home screen where someone is browsing through a product catalogue.
//We may need to still display the items in the shopping cart in the corner.
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
              Text("Number of Items in your cart: ${state.toString()}"),
              ElevatedButton(
                  onPressed: () => context.go('/checkout'),
                  child: const Text("checkout"))
            ],
          );
        });
  }
}

//Imagine this is the checkout screen where you can actually modify the shopping cart state.
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
              Text("Number of Items in Cart: ${state.toString()}"),
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

//This is a singleton repository shared amongst multiple view models
//The number of items in the cart is updated and kept here
class ShoppingCartRepo extends ChangeNotifier {
  var numItemsInCart = 0;

  void updateItemsInCart() {
    numItemsInCart += 1;
    notifyListeners();
  }
}
