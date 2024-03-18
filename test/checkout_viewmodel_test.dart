import 'package:flutter_test/flutter_test.dart';
import 'package:shoppingcart/main.dart';

class MockRootAppDependencyProvider extends RootAppDependencyProvider {
  @override
  ShoppingCartRepo shoppingCartRepo() {
    return MockShoppingCartRepo();
  }
}

class MockShoppingCartRepo extends ShoppingCartRepo {
  @override
  int get numItemsInCart => super.numItemsInCart;
  @override
  void updateItemsInCart() {
    numItemsInCart += 1;
    notifyListeners();
  }
}

void main() {
  group("Checkout View Model Unit Tests", () {
    late MockRootAppDependencyProvider dependencyProvider;
    late CheckoutViewModel checkoutViewModel;
    late ShoppingCartRepo mockShoppingCartRepo;

    setUp(() {
      dependencyProvider = MockRootAppDependencyProvider();
      mockShoppingCartRepo = dependencyProvider.shoppingCartRepo();
      checkoutViewModel = CheckoutViewModel(mockShoppingCartRepo);
    });

    test(
        "Given CheckoutViewModel, when updateShoppingCartCount is called, numItemsInCart in the shopping cart repo is updated.",
        () {
      checkoutViewModel.updateShoppingCartCount();
      expect(1, mockShoppingCartRepo.numItemsInCart);
    });
  });
}
