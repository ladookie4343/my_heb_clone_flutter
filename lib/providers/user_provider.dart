import 'package:flutter/cupertino.dart';
import 'package:my_heb_clone/models/day_availability.dart';
import 'package:my_heb_clone/models/order.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/models/shopping_method.dart';
import 'package:my_heb_clone/models/store.dart';
import 'package:my_heb_clone/models/user.dart';
import 'package:my_heb_clone/services/heb_auth_service.dart';
import 'package:my_heb_clone/services/heb_http_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:my_heb_clone/services/secure_storage.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  final _hebHttpService = HebHttpService();
  final _hebAuthService = HebAuthService();

  User? get user {
    return _user;
  }

  Future<void> createAccount(User user) async {
    final auth = await _hebAuthService.signupNewUser(user.email, user.password);
    user.id = auth.localId;
    user.auth = auth;
    _user = user;
    await _hebHttpService.createUser(user);
  }

  Future<void> login(String email, String password) async {
    final auth = await _hebAuthService.loginUser(email, password);
    final userResponse =
        await _hebHttpService.getUser(auth.localId, auth.idToken);
    final store = await _hebHttpService.getStore(userResponse.storeId);

    _user = User(
      id: auth.localId,
      email: userResponse.email,
      firstName: userResponse.firstName,
      lastName: userResponse.lastName,
      phoneNumber: userResponse.phoneNumber,
      auth: auth,
      optIn: userResponse.optIn,
      timeSlot: _validate(userResponse.timeSlot),
      password: '',
      shoppingMethod:
          EnumToString.fromString(ShoppingMethod.values, userResponse.shopType),
      store: store,
      shoppingCart: {
        for (var cartItem in userResponse.cartItems)
          cartItem.productId: cartItem
      },
      orders: userResponse.orders,
    );

    SecureStorage.storeUserInfo(_user!);
  }

  DateTime? _validate(DateTime? timeSlot) {
    if (timeSlot == null) return null;

    if (timeSlot.isBefore(DateTime.now().add(Duration(hours: 1)))) {
      return null;
    } else {
      return timeSlot;
    }
  }

  int numberOfProductInShoppingCart(String productId) {
    if (user!.shoppingCart.containsKey(productId)) {
      return user!.shoppingCart[productId]!.quantity;
    }
    return 0;
  }

  int get totalNumberOfProductsInShoppingCart => user!.shoppingCart.values
      .fold<int>(0, (value, element) => value + element.quantity);

  double get totalPriceOfShoppingCart => user!.shoppingCart.values.fold(
        0.0,
        (previousValue, element) =>
            previousValue + (element.product?.price ?? 0.0) * element.quantity,
      );

  Future<void> tryAutoLogin() async {
    _user = await SecureStorage.retrieveUserInfo();
    if (_user == null) return;

    if (_user!.auth!.isExpired) {
      var auth = await _hebAuthService.refreshAuth(_user!.auth!.refreshToken);
      _user!.auth = auth;
    }
  }

  Future<void> updateShoppingMethod(ShoppingMethod shoppingMethod) async {
    _user!.shoppingMethod = shoppingMethod;
    notifyListeners();
    await _hebHttpService.updateShoppingMethod(_user!, shoppingMethod);
    SecureStorage.storeUserInfo(user!);
  }

  Future<void> updateStore(Store store) async {
    _user!.store = store;
    notifyListeners();
    await _hebHttpService.updateStore(_user!, store.id);
    SecureStorage.storeUserInfo(user!);
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    _user!.phoneNumber = phoneNumber;
    notifyListeners();
    await _hebHttpService.updatePhoneNumber(_user!, phoneNumber);
    SecureStorage.storeUserInfo(user!);
  }

  Future<void> updateTimeSlot(TimeSlot? timeSlot) async {
    _user!.timeSlot = timeSlot?.startTime;
    notifyListeners();
    await _hebHttpService.updateTimeSlot(_user!, timeSlot?.startTime);
    SecureStorage.storeUserInfo(user!);
  }

  Future<Order> submitOrder(Order order) async {
    var id = await _hebHttpService.createOrder(user!, order);
    order.id = id;
    _user!.orders.add(order);
    emptyShoppingCart();
    updateTimeSlot(null);
    return order;
  }

  void addProductToShoppingCart(Product product) {
    _user!.addProductToShoppingCart(product);
    notifyListeners();
    _hebHttpService.updateShoppingCart(_user!);
  }

  int removeProductFromShoppingCart(Product product) {
    var remaining = _user!.removeProductFromShoppingCart(product);
    notifyListeners();
    _hebHttpService.updateShoppingCart(user!);
    return remaining;
  }

  void emptyShoppingCart() {
    _user!.emptyShoppingCart();
    notifyListeners();
    _hebHttpService.updateShoppingCart(user!);
  }

  Future<void> logout() async {
    await SecureStorage.clearUserInfo();
  }

  void saveSearchTerm(String query) {
    if (query.trim() == "") return;
    if (user!.recentSearches == null) {
      user!.recentSearches = [];
    }
    if (user!.recentSearches!.contains(query)) {
      user!.recentSearches!.removeWhere((element) => element == query);
    }
    _user!.recentSearches!.insert(0, query);
    _user!.recentSearches = _user!.recentSearches!.take(5).toList();
    SecureStorage.storeUserInfo(user!);
  }
}
