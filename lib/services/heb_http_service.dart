import 'dart:convert';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:http/http.dart' as http;
import 'package:my_heb_clone/models/category.dart';
import 'package:my_heb_clone/models/department.dart';
import 'package:my_heb_clone/models/order.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/models/shopping_method.dart';
import 'package:my_heb_clone/models/store.dart';
import 'package:my_heb_clone/models/type.dart';
import 'package:my_heb_clone/models/user.dart';
import 'package:my_heb_clone/services/heb_auth_service.dart';

import 'response/user_response.dart';

class HebHttpService {
  static const _authority = 'your-firebase-server';

  HebAuthService _hebAuthService = HebAuthService();

  Future<List<Department>> getDepartmentsWithCategoriesAndTypes() async {
    var departments = await _getAllDepartments();
    var categories = await _getAllCategories();
    var types = await _getAllTypes();

    categories.forEach((category) {
      category.types =
          types.where((type) => type.categoryId == category.id).toList();
    });

    departments.forEach((department) {
      department.categories = categories
          .where((category) => category.departmentId == department.id)
          .toList();
    });

    return departments;
  }

  Future<List<Department>> _getAllDepartments() async {
    final uri = Uri.https(_authority, 'departments.json');
    final response = await http.get(uri);
    return Department.parseDepartments(json.decode(response.body));
  }

  Future<List<Category>> _getAllCategories() async {
    final uri = Uri.https(_authority, 'categories.json');
    final response = await http.get(uri);
    return Category.parseCategories(json.decode(response.body));
  }

  Future<List<Type>> _getAllTypes() async {
    final uri = Uri.https(_authority, 'types.json');
    final response = await http.get(uri);
    return Type.parseTypes(json.decode(response.body));
  }

  Future<List<Product>> getProducts(String categoryId) async {
    final uri = Uri.https(_authority, 'products.json', {
      'orderBy': '"category_id"',
      'equalTo': '"$categoryId"',
    });
    final response = await http.get(uri);
    return Product.parseProducts(json.decode(response.body));
  }

  Future<Product> getProduct(String productId) async {
    final uri = Uri.https(
      _authority,
      'products/$productId.json',
    );
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    return Product.fromJson(json.decode(response.body), productId);
  }

  Future<List<Product>> getAllProducts() async {
    final uri = Uri.https(_authority, 'products.json');
    final response = await http.get(uri);
    return Product.parseProducts(json.decode(response.body));
  }

  Future<List<Store>> getStores() async {
    final uri = Uri.https(_authority, 'stores.json');
    final response = await http.get(uri);
    return Store.parseStores(json.decode(response.body));
    // return Store.parseStores(json.decode(storesJson));
  }

  Future<void> createUser(User user) async {
    final uri = Uri.https(
      _authority,
      'users/${user.id}.json',
      {'auth': user.auth!.idToken},
    );

    await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'optIn': user.optIn
      }),
    );
  }

  Future<void> updateShoppingMethod(
    User user,
    ShoppingMethod shoppingMethod,
  ) async {
    await _updateAuthTokenIfExpired(user);
    final uri = Uri.https(
      _authority,
      'users/${user.id}.json',
      {'auth': user.auth!.idToken},
    );
    await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'shopType': EnumToString.convertToString(shoppingMethod),
      }),
    );
  }

  Future<void> updateStore(User user, String storeId) async {
    await _updateAuthTokenIfExpired(user);
    final uri = Uri.https(
      _authority,
      'users/${user.id}.json',
      {'auth': user.auth!.idToken},
    );
    var response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'storeId': storeId
      }),
    );
    if (response.statusCode > 399) {
      throw Exception(response.body);
    }
  }

  Future<void> updateTimeSlot(User user, DateTime? startTime) async {
    await _updateAuthTokenIfExpired(user);
    final uri = Uri.https(
      _authority,
      'users/${user.id}.json',
      {'auth': user.auth!.idToken},
    );
    var response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'timeSlot': startTime?.toIso8601String() ?? null
      }),
    );
    if (response.statusCode > 399) {
      throw Exception(response.body);
    }
  }

  Future<UserResponse> getUser(String userId, String accessToken) async {
    final uri = Uri.https(
      _authority,
      'users/$userId.json',
      {'auth': accessToken},
    );
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    var userResponse = UserResponse.fromJson(json.decode(response.body));
    userResponse.cartItems.forEach((item) async {
      item.product = await getProduct(item.productId);
    });
    return userResponse;
  }

  Future<Store> getStore(String storeId) async {
    final uri = Uri.https(_authority, 'stores/$storeId.json');
    final response = await http.get(uri);
    return Store.fromJson(json.decode(response.body), id: storeId);
  }

  Future<void> updateShoppingCart(User user) async {
    await _updateAuthTokenIfExpired(user);
    final uri = Uri.https(
      _authority,
      'users/${user.id}.json',
      {'auth': user.auth!.idToken},
    );
    var response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cart': user.shoppingCart.values.toList()
      }),
    );

    if (response.statusCode > 399) {
      throw Exception(response.body);
    }
  }

  Future<String> createOrder(User user, Order order) async {
    await _updateAuthTokenIfExpired(user);
    final uri = Uri.https(
      _authority,
      'users/${user.id}/orders.json',
      {'auth': user.auth!.idToken},
    );
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order),
    );

    if (response.statusCode > 399) {
      throw Exception(response.body);
    }

    return json.decode(response.body)['name'];
  }

  Future<void> updatePhoneNumber(User user, String phoneNumber) async {
    await _updateAuthTokenIfExpired(user);
    final uri = Uri.https(
      _authority,
      'users/${user.id}.json',
      {'auth': user.auth!.idToken},
    );
    var response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': phoneNumber
      }),
    );
    if (response.statusCode > 399) {
      throw Exception(response.body);
    }
  }

  Future<void> _updateAuthTokenIfExpired(User user) async {
    if (user.auth!.isExpired) {
      var auth = await _hebAuthService.refreshAuth(user.auth!.refreshToken);
      user.auth = auth;
    }
  }
}

const String storesJson = """
{
  "14": {
    "address1": "5401 SOUTH FM 1626",
    "allowAtgCurbside": false,
    "city": "KYLE",
    "isCurbside": false,
    "latitude": 30.01533,
    "longitude": -97.86258,
    "name": "Kyle H-E-B plus!",
    "phoneNumber": "(512) 268-7900",
    "postalCode": "78640-6038",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "24": {
    "address1": "11521 NORTH FM620, BUILDING A",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.45495,
    "longitude": -97.82626,
    "name": "Anderson Mill H-E-B plus!",
    "phoneNumber": "(512) 249-0558",
    "postalCode": "78726-1168",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "29": {
    "address1": "701 CAPITOL OF TEXAS HWY-BLD C",
    "allowAtgCurbside": true,
    "city": "WEST LAKE HILLS",
    "isCurbside": true,
    "latitude": 30.2928,
    "longitude": -97.82813,
    "name": "Westlake H-E-B",
    "phoneNumber": "(512) 732-9930",
    "postalCode": "78746-5256",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "31": {
    "address1": "12860 RESEARCH BLVD",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.43494,
    "longitude": -97.7713,
    "name": "Spicewood Springs H-E-B",
    "phoneNumber": "(512) 506-9060",
    "postalCode": "78750-3222",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "34": {
    "address1": "3750 GATTIS SCHOOL RD",
    "allowAtgCurbside": true,
    "city": "ROUND ROCK",
    "isCurbside": true,
    "latitude": 30.49721,
    "longitude": -97.61475,
    "name": "Red Bud Lane and Gattis School H-E-B",
    "phoneNumber": "(512) 341-3775",
    "postalCode": "78664-4642",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "39": {
    "address1": "2509 NORTH MAIN STREET",
    "allowAtgCurbside": true,
    "city": "BELTON",
    "isCurbside": true,
    "latitude": 31.0805,
    "longitude": -97.45759,
    "name": "Belton H-E-B plus!",
    "phoneNumber": "(254) 939-0856",
    "postalCode": "76513-1519",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "45": {
    "address1": "2400 S. CONGRESS",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.23875,
    "longitude": -97.75382,
    "name": "South Congress H-E-B",
    "phoneNumber": "(512) 442-2354",
    "postalCode": "78704-5512",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "68": {
    "address1": "5800 W. SLAUGHTER LANE",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.20247,
    "longitude": -97.87642,
    "name": "Slaughter and Escarpment H-E-B",
    "phoneNumber": "(512) 301-9770",
    "postalCode": "78749-6507",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "71": {
    "address1": "1314 WEST ADAMS",
    "allowAtgCurbside": true,
    "city": "TEMPLE",
    "isCurbside": true,
    "latitude": 31.10153,
    "longitude": -97.35378,
    "name": "Adams and 25th St H-E-B",
    "phoneNumber": "(254) 773-4145",
    "postalCode": "76504-2448",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "74": {
    "address1": "1655 W STATE HIGHWAY 46",
    "allowAtgCurbside": true,
    "city": "NEW BRAUNFELS",
    "isCurbside": true,
    "latitude": 29.71309,
    "longitude": -98.16041,
    "name": "New Braunfels H-E-B at Hwy 46",
    "phoneNumber": "(830) 626-0937",
    "postalCode": "78132-4753",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "91": {
    "address1": "2508 EAST RIVERSIDE DRIVE",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.23547,
    "longitude": -97.72401,
    "name": "Riverside H-E-B plus!",
    "phoneNumber": "(512) 448-3544",
    "postalCode": "78741-3037",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "96": {
    "address1": "7015 VILLAGE CTR DR.",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.35289,
    "longitude": -97.75598,
    "name": "Far West H-E-B",
    "phoneNumber": "(512) 502-8445",
    "postalCode": "78731-3023",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "102": {
    "address1": "8503 NW MILITARY HWY",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.55254,
    "longitude": -98.53463,
    "name": "Alon Market H-E-B",
    "phoneNumber": "(210) 479-4300",
    "postalCode": "78231-1841",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "106": {
    "address1": "1015 S.W.W. WHITE ROAD",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.41476,
    "longitude": -98.40568,
    "name": "W. W. White H-E-B",
    "phoneNumber": "(210) 333-0020",
    "postalCode": "78220-2530",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "108": {
    "address1": "20935 US HIGHWAY 281 NORTH",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.63886,
    "longitude": -98.45756,
    "name": "281 and Evans Road H-E-B plus!",
    "phoneNumber": "(210) 491-2400",
    "postalCode": "78258-7587",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "161": {
    "address1": "7112 ED BLUESTEIN_#125",
    "allowAtgCurbside": false,
    "city": "AUSTIN",
    "isCurbside": false,
    "latitude": 30.31211,
    "longitude": -97.66465,
    "name": "Ed Bluestein H-E-B",
    "phoneNumber": "(512) 926-1491",
    "postalCode": "78723-2924",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "164": {
    "address1": "15000 SAN PEDRO",
    "allowAtgCurbside": false,
    "city": "SAN ANTONIO",
    "isCurbside": false,
    "latitude": 29.5774,
    "longitude": -98.47734,
    "name": "Brook Hollow H-E-B",
    "phoneNumber": "(210) 494-3501",
    "postalCode": "78232-3714",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "178": {
    "address1": "6839 SAN PEDRO",
    "allowAtgCurbside": false,
    "city": "SAN ANTONIO",
    "isCurbside": false,
    "latitude": 29.50282,
    "longitude": -98.4995,
    "name": "San Pedro and Oblate H-E-B",
    "phoneNumber": "(210) 342-2745",
    "postalCode": "78216-7202",
    "state": "TX",
    "storeHours": "Mon-Sun 07:00 AM - 11:00 PM"
  },
  "182": {
    "address1": "3002 S 31 ST",
    "allowAtgCurbside": true,
    "city": "TEMPLE",
    "isCurbside": true,
    "latitude": 31.07223,
    "longitude": -97.37061,
    "name": "Market Place H-E-B",
    "phoneNumber": "(254) 778-4820",
    "postalCode": "76502-1802",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "183": {
    "address1": "9414 N LAMAR BLVD",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.36357,
    "longitude": -97.69689,
    "name": "Lamar and Rundberg H-E-B",
    "phoneNumber": "(512) 835-5400",
    "postalCode": "78753-4106",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "195": {
    "address1": "11551 WEST AVE.",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.54526,
    "longitude": -98.51025,
    "name": "Blanco and West Ave H-E-B",
    "phoneNumber": "(210) 340-7976",
    "postalCode": "78213-1343",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "202": {
    "address1": "5808 BURNET RD",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.33374,
    "longitude": -97.74016,
    "name": "Burnet Rd H-E-B",
    "phoneNumber": "(512) 453-8864",
    "postalCode": "78756-1100",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "211": {
    "address1": "415 N. NEW BRAUNFELS",
    "allowAtgCurbside": false,
    "city": "SAN ANTONIO",
    "isCurbside": false,
    "latitude": 29.42444,
    "longitude": -98.46143,
    "name": "New Braunfels and Houston H-E-B",
    "phoneNumber": "(210) 226-8531",
    "postalCode": "78202-3050",
    "state": "TX",
    "storeHours": "Mon-Sun 07:00 AM - 11:00 PM"
  },
  "218": {
    "address1": "12407 N. MOPAC EXPWY",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.41883,
    "longitude": -97.70326,
    "name": "Parmer and Mopac H-E-B",
    "phoneNumber": "(512) 339-1181",
    "postalCode": "78758-2475",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "225": {
    "address1": "7010 HWY 71 WEST",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.23583,
    "longitude": -97.87471,
    "name": "290 and 71 H-E-B",
    "phoneNumber": "(512) 288-5440",
    "postalCode": "78735-8300",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "227": {
    "address1": "2110 WEST SLAUGHTER LN",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.17524,
    "longitude": -97.82509,
    "name": "Slaughter and Manchaca H-E-B",
    "phoneNumber": "(512) 282-0182",
    "postalCode": "78748-5992",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "229": {
    "address1": "6607 SOUTH IH 35",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.19107,
    "longitude": -97.76922,
    "name": "I 35 and William Cannon H-E-B",
    "phoneNumber": "(512) 441-9266",
    "postalCode": "78744-3410",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "230": {
    "address1": "14087 O'CONNOR RD",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.56937,
    "longitude": -98.3856,
    "name": "Nacogdoches and O'Connor H-E-B",
    "phoneNumber": "(210) 637-1313",
    "postalCode": "78247-1979",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "236": {
    "address1": "1434 WELLS BRANCH PKWY",
    "allowAtgCurbside": true,
    "city": "PFLUGERVILLE",
    "isCurbside": true,
    "latitude": 30.44263,
    "longitude": -97.66419,
    "name": "Wells Branch H-E-B",
    "phoneNumber": "(512) 251-2584",
    "postalCode": "78660-3153",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "237": {
    "address1": "1100 SOUTH IH35",
    "allowAtgCurbside": true,
    "city": "GEORGETOWN",
    "isCurbside": true,
    "latitude": 30.63446,
    "longitude": -97.69028,
    "name": "35 and West University H-E-B",
    "phoneNumber": "(512) 930-5581",
    "postalCode": "78626-5400",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "243": {
    "address1": "641 EAST HOPKINS STREET",
    "allowAtgCurbside": true,
    "city": "SAN MARCOS",
    "isCurbside": true,
    "latitude": 29.88489,
    "longitude": -97.93132,
    "name": "East Hopkins H-E-B",
    "phoneNumber": "(512) 396-8880",
    "postalCode": "78666-7055",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "265": {
    "address1": "170 E WHITESTONE BLVD",
    "allowAtgCurbside": true,
    "city": "CEDAR PARK",
    "isCurbside": true,
    "latitude": 30.5225,
    "longitude": -97.82911,
    "name": "Hwy 183 and Whitestone Blvd H-E-B",
    "phoneNumber": "(512) 259-5500",
    "postalCode": "78613-1900",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "269": {
    "address1": "10710 RESEARCH BLVD. STE 200",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.39868,
    "longitude": -97.74832,
    "name": "North Hills H-E-B",
    "phoneNumber": "(512) 794-8221",
    "postalCode": "78759-5780",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "294": {
    "address1": "6580 F.M. 78",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.48109,
    "longitude": -98.3591,
    "name": "Foster Rd H-E-B",
    "phoneNumber": "(210) 666-2022",
    "postalCode": "78244-1300",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "355": {
    "address1": "201 W. GONZALES",
    "allowAtgCurbside": false,
    "city": "YOAKUM",
    "isCurbside": false,
    "latitude": 29.29278,
    "longitude": -97.15053,
    "name": "Yoakum H-E-B",
    "phoneNumber": "(361) 293-5281",
    "postalCode": "77995-2719",
    "state": "TX",
    "storeHours": "Mon-Sun 07:00 AM - 10:00 PM"
  },
  "372": {
    "address1": "1955 NACOGDOCHES",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.50774,
    "longitude": -98.45759,
    "name": "Oak Park H-E-B",
    "phoneNumber": "(210) 930-3707",
    "postalCode": "78209-2217",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "373": {
    "address1": "16900 N RANCH ROAD 620",
    "allowAtgCurbside": true,
    "city": "ROUND ROCK",
    "isCurbside": true,
    "latitude": 30.50028,
    "longitude": -97.72218,
    "name": "620 and O'Connor H-E-B",
    "phoneNumber": "(512) 238-7909",
    "postalCode": "78681-3922",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "380": {
    "address1": "651 S. WALNUT",
    "allowAtgCurbside": true,
    "city": "NEW BRAUNFELS",
    "isCurbside": true,
    "latitude": 29.68878,
    "longitude": -98.12695,
    "name": "New Braunfels H-E-B at Walnut",
    "phoneNumber": "(830) 608-0017",
    "postalCode": "78130-5722",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "381": {
    "address1": "601 INDIAN TRAIL",
    "allowAtgCurbside": true,
    "city": "HARKER HEIGHTS",
    "isCurbside": true,
    "latitude": 31.07905,
    "longitude": -97.65511,
    "name": "Harker Heights H-E-B",
    "phoneNumber": "(254) 699-8411",
    "postalCode": "76548-1347",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "384": {
    "address1": "6030 MONTGOMERY ROAD",
    "allowAtgCurbside": false,
    "city": "SAN ANTONIO",
    "isCurbside": false,
    "latitude": 29.5105,
    "longitude": -98.37092,
    "name": "Montgomery at Walzem",
    "phoneNumber": "(210) 657-2944",
    "postalCode": "78239-3233",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "385": {
    "address1": "300 OLMOS DRIVE",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.4707,
    "longitude": -98.497,
    "name": "Olmos Park H-E-B",
    "phoneNumber": "(210) 829-7373",
    "postalCode": "78212-1958",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "388": {
    "address1": "6001 WEST PARMER LANE",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.44181,
    "longitude": -97.74278,
    "name": "Parmer and McNeil H-E-B",
    "phoneNumber": "(512) 249-0400",
    "postalCode": "78727-3901",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "389": {
    "address1": "6000 WEST AVENUE",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.51639,
    "longitude": -98.52574,
    "name": "West Ave and Jackson Keller H-E-B",
    "phoneNumber": "(210) 341-7289",
    "postalCode": "78213-2714",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "395": {
    "address1": "12777 IH 10 WEST",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.56222,
    "longitude": -98.5889,
    "name": "De Zavala H-E-B",
    "phoneNumber": "(210) 558-3981",
    "postalCode": "78230-1014",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "397": {
    "address1": "18140 SAN PEDRO",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.60772,
    "longitude": -98.46828,
    "name": "281 and 1604 H-E-B",
    "phoneNumber": "(210) 490-4931",
    "postalCode": "78232-1421",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "398": {
    "address1": "2929 THOUSAND OAKS",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.57781,
    "longitude": -98.44108,
    "name": "Thousand Oaks H-E-B",
    "phoneNumber": "(210) 491-9508",
    "postalCode": "78247-3312",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "404": {
    "address1": "12400 W HIGHWAY 71",
    "allowAtgCurbside": true,
    "city": "BEE CAVE",
    "isCurbside": true,
    "latitude": 30.30489,
    "longitude": -97.93238,
    "name": "Bee Cave H-E-B",
    "phoneNumber": "(512) 263-0528",
    "postalCode": "78738-6517",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "414": {
    "address1": "2508 S. DAY ST.",
    "allowAtgCurbside": true,
    "city": "BRENHAM",
    "isCurbside": true,
    "latitude": 30.14381,
    "longitude": -96.39591,
    "name": "Brenham H-E-B",
    "phoneNumber": "(979) 277-9858",
    "postalCode": "77833-5521",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "415": {
    "address1": "17460 I.H. 35 NORTH",
    "allowAtgCurbside": true,
    "city": "SCHERTZ",
    "isCurbside": true,
    "latitude": 29.59717,
    "longitude": -98.27742,
    "name": "Schertz H-E-B plus!",
    "phoneNumber": "(210) 651-5105",
    "postalCode": "78154-1264",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "416": {
    "address1": "450 E. TRAVIS",
    "allowAtgCurbside": true,
    "city": "LA GRANGE",
    "isCurbside": true,
    "latitude": 29.9073,
    "longitude": -96.87264,
    "name": "La Grange H-E-B",
    "phoneNumber": "(979) 968-8381",
    "postalCode": "78945-2655",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 10:00 PM"
  },
  "425": {
    "address1": "1000 EAST 41 ST.",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.30057,
    "longitude": -97.71973,
    "name": "Hancock Center H-E-B",
    "phoneNumber": "(512) 459-6513",
    "postalCode": "78751-4810",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "428": {
    "address1": "6900 BRODIE LANE",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.21489,
    "longitude": -97.83076,
    "name": "Brodie Lane H-E-B",
    "phoneNumber": "(512) 891-8900",
    "postalCode": "78745-5008",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "432": {
    "address1": "705 S. KEY AVE.",
    "allowAtgCurbside": false,
    "city": "LAMPASAS",
    "isCurbside": false,
    "latitude": 31.06199,
    "longitude": -98.18098,
    "name": "Lampasas H-E-B",
    "phoneNumber": "(512) 556-3461",
    "postalCode": "76550-3114",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "433": {
    "address1": "105 S BOUNDARY",
    "allowAtgCurbside": false,
    "city": "BURNET",
    "isCurbside": false,
    "latitude": 30.7588,
    "longitude": -98.22452,
    "name": "Burnet H-E-B",
    "phoneNumber": "(512) 756-6188",
    "postalCode": "78611-3201",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "445": {
    "address1": "403 SOUTH COLORADO STREET",
    "allowAtgCurbside": true,
    "city": "LOCKHART",
    "isCurbside": true,
    "latitude": 29.88213,
    "longitude": -97.66994,
    "name": "Lockhart H-E-B",
    "phoneNumber": "(512) 398-2301",
    "postalCode": "78644-2702",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "451": {
    "address1": "7301 N FM 620",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.40458,
    "longitude": -97.85202,
    "name": "Four Points H-E-B",
    "phoneNumber": "(512) 336-7700",
    "postalCode": "78726-4539",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "455": {
    "address1": "200 WEST HOPKINS ST.",
    "allowAtgCurbside": false,
    "city": "SAN MARCOS",
    "isCurbside": false,
    "latitude": 29.88305,
    "longitude": -97.94292,
    "name": "West Hopkins H-E-B",
    "phoneNumber": "(512) 396-0100",
    "postalCode": "78666-5615",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "463": {
    "address1": "1150 NW LOOP 1604",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.60792,
    "longitude": -98.50968,
    "name": "Loop 1604 and Blanco Rd H-E-B plus!",
    "phoneNumber": "(210) 408-1641",
    "postalCode": "78248-4552",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "464": {
    "address1": "320 PIERCE",
    "allowAtgCurbside": false,
    "city": "LULING",
    "isCurbside": false,
    "latitude": 29.68092,
    "longitude": -97.65269,
    "name": "Luling H-E-B",
    "phoneNumber": "(830) 875-3831",
    "postalCode": "78648-2427",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "465": {
    "address1": "2701 EAST 7TH",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.26046,
    "longitude": -97.71143,
    "name": "7th Street H-E-B",
    "phoneNumber": "(512) 478-7328",
    "postalCode": "78702-3907",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "475": {
    "address1": "1080 EAST HWY 290",
    "allowAtgCurbside": true,
    "city": "ELGIN",
    "isCurbside": true,
    "latitude": 30.34701,
    "longitude": -97.38258,
    "name": "Elgin H-E-B",
    "phoneNumber": "(512) 285-4168",
    "postalCode": "78621-2519",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "476": {
    "address1": "500 CANYON RIDGE DR.",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.40443,
    "longitude": -97.67201,
    "name": "Tech Ridge H-E-B",
    "phoneNumber": "(512) 973-8143",
    "postalCode": "78753-1632",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "477": {
    "address1": "15300 S IH-35",
    "allowAtgCurbside": true,
    "city": "BUDA",
    "isCurbside": true,
    "latitude": 30.08769,
    "longitude": -97.82074,
    "name": "Buda H-E-B",
    "phoneNumber": "(512) 312-1615",
    "postalCode": "78610-9703",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "479": {
    "address1": "201 FM 685",
    "allowAtgCurbside": true,
    "city": "PFLUGERVILLE",
    "isCurbside": true,
    "latitude": 30.4373,
    "longitude": -97.6133,
    "name": "Pflugerville H-E-B",
    "phoneNumber": "(512) 251-0002",
    "postalCode": "78660-8045",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "480": {
    "address1": "9900 WURZBACH",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.5336,
    "longitude": -98.5595,
    "name": "I10 and Wurzbach H-E-B",
    "phoneNumber": "(210) 696-0794",
    "postalCode": "78230-2212",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "487": {
    "address1": "4500 FM 2338",
    "allowAtgCurbside": true,
    "city": "GEORGETOWN",
    "isCurbside": true,
    "latitude": 30.68312,
    "longitude": -97.71873,
    "name": "Williams Drive H-E-B",
    "phoneNumber": "(512) 863-4427",
    "postalCode": "78628",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "495": {
    "address1": "603 LOUIS HENNA BLVD. BLDG A",
    "allowAtgCurbside": true,
    "city": "ROUND ROCK",
    "isCurbside": true,
    "latitude": 30.48179,
    "longitude": -97.65938,
    "name": "Louis Henna Blvd H-E-B",
    "phoneNumber": "(512) 828-0806",
    "postalCode": "78664-7186",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "555": {
    "address1": "910 KITTY HAWK ROAD",
    "allowAtgCurbside": true,
    "city": "UNIVERSAL CITY",
    "isCurbside": true,
    "latitude": 29.54766,
    "longitude": -98.31298,
    "name": "Kitty Hawk H-E-B",
    "phoneNumber": "(210) 945-2102",
    "postalCode": "78148-3806",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "561": {
    "address1": "407 SOUTH ADAMS",
    "allowAtgCurbside": true,
    "city": "FREDERICKSBURG",
    "isCurbside": true,
    "latitude": 30.27006,
    "longitude": -98.87538,
    "name": "Fredericksburg H-E-B",
    "phoneNumber": "(830) 997-9950",
    "postalCode": "78624-4146",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "566": {
    "address1": "24165 I-H 10 WEST, SUITE 300",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.6659,
    "longitude": -98.63218,
    "name": "Leon Springs H-E-B",
    "phoneNumber": "(210) 687-1007",
    "postalCode": "78257-1161",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "567": {
    "address1": "999 EAST BASSE ROAD",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.4967,
    "longitude": -98.4682,
    "name": "Lincoln Heights Market H-E-B",
    "phoneNumber": "(210) 822-0156",
    "postalCode": "78209-1804",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "568": {
    "address1": "12018 PERRIN BEITEL ROAD",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.5491,
    "longitude": -98.4082,
    "name": "Perrin Beitel and Thousand Oaks H-E-B",
    "phoneNumber": "(210) 655-9071",
    "postalCode": "78217-2116",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "580": {
    "address1": "2800 EAST WHITESTONE",
    "allowAtgCurbside": true,
    "city": "CEDAR PARK",
    "isCurbside": true,
    "latitude": 30.5328,
    "longitude": -97.78545,
    "name": "Parmer and Whitestone H-E-B",
    "phoneNumber": "(512) 528-0027",
    "postalCode": "78613-7273",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "581": {
    "address1": "2511 TRIMMIER RD, SUITE 100",
    "allowAtgCurbside": true,
    "city": "KILLEEN",
    "isCurbside": true,
    "latitude": 31.0909,
    "longitude": -97.7338,
    "name": "Trimmier H-E-B plus!",
    "phoneNumber": "(254) 526-9674",
    "postalCode": "76542-1910",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "582": {
    "address1": "104 HASLER BLVD",
    "allowAtgCurbside": true,
    "city": "BASTROP",
    "isCurbside": true,
    "latitude": 30.10981,
    "longitude": -97.33458,
    "name": "Bastrop H-E-B plus!",
    "phoneNumber": "(512) 321-1011",
    "postalCode": "78602-3740",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "585": {
    "address1": "1520 AUSTIN HWY",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.4937,
    "longitude": -98.43132,
    "name": "Austin Highway H-E-B",
    "phoneNumber": "(210) 828-5076",
    "postalCode": "78218-6039",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "587": {
    "address1": "215 RANCH ROAD 2900",
    "allowAtgCurbside": false,
    "city": "KINGSLAND",
    "isCurbside": false,
    "latitude": 30.659,
    "longitude": -98.4442,
    "name": "Kingsland H-E-B",
    "phoneNumber": "(325) 388-4601",
    "postalCode": "78639-6105",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 10:00 PM"
  },
  "591": {
    "address1": "1700 EAST PALM VALLEY BLVD",
    "allowAtgCurbside": true,
    "city": "ROUND ROCK",
    "isCurbside": true,
    "latitude": 30.5177,
    "longitude": -97.65978,
    "name": "Round Rock H-E-B plus!",
    "phoneNumber": "(512) 388-2649",
    "postalCode": "78664-4677",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "592": {
    "address1": "651 N. US HWY 183",
    "allowAtgCurbside": true,
    "city": "LEANDER",
    "isCurbside": true,
    "latitude": 30.58369,
    "longitude": -97.8582,
    "name": "Leander H-E-B plus!",
    "phoneNumber": "(512) 528-7700",
    "postalCode": "78641-7001",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "593": {
    "address1": "100 N.W.CARLOS G.PARKER BL#101",
    "allowAtgCurbside": true,
    "city": "TAYLOR",
    "isCurbside": true,
    "latitude": 30.6007,
    "longitude": -97.4167,
    "name": "Taylor H-E-B",
    "phoneNumber": "(512) 352-2015",
    "postalCode": "76574-7059",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "611": {
    "address1": "598 E.HWY US 290",
    "allowAtgCurbside": true,
    "city": "DRIPPING SPRINGS",
    "isCurbside": true,
    "latitude": 30.18968,
    "longitude": -98.08146,
    "name": "Dripping Springs H-E-B",
    "phoneNumber": "(512) 858-2972",
    "postalCode": "78620-5482",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "612": {
    "address1": "14414 US HWY 87 WEST",
    "allowAtgCurbside": true,
    "city": "LA VERNIA",
    "isCurbside": true,
    "latitude": 29.35803,
    "longitude": -98.13514,
    "name": "La Vernia H-E-B",
    "phoneNumber": "(830) 779-1790",
    "postalCode": "78121-5922",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "621": {
    "address1": "420 WEST BANDERA ROAD",
    "allowAtgCurbside": true,
    "city": "BOERNE",
    "isCurbside": true,
    "latitude": 29.78173,
    "longitude": -98.73481,
    "name": "Boerne H-E-B plus!",
    "phoneNumber": "(830) 816-2394",
    "postalCode": "78006-2523",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "622": {
    "address1": "20725 HWY 46",
    "allowAtgCurbside": true,
    "city": "SPRING BRANCH",
    "isCurbside": true,
    "latitude": 29.79882,
    "longitude": -98.43022,
    "name": "Bulverde H-E-B plus!",
    "phoneNumber": "(830) 438-3000",
    "postalCode": "78070-6270",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "639": {
    "address1": "1801 E.51ST STREET",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.3013,
    "longitude": -97.69872,
    "name": "Mueller H-E-B",
    "phoneNumber": "(512) 474-2199",
    "postalCode": "78723-3014",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "641": {
    "address1": "1841 CHURCH ST.",
    "allowAtgCurbside": true,
    "city": "GONZALES",
    "isCurbside": true,
    "latitude": 29.51832,
    "longitude": -97.45202,
    "name": "Gonzales H-E-B",
    "phoneNumber": "(830) 672-7595",
    "postalCode": "78629-2406",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 10:00 PM"
  },
  "658": {
    "address1": "23635 WILDERNESS OAK",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.662,
    "longitude": -98.50062,
    "name": "The Market at Stone Oak",
    "phoneNumber": "(210) 482-3300",
    "postalCode": "78258",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "659": {
    "address1": "14028 NORTH US 183",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.47786,
    "longitude": -97.8034,
    "name": "Lakeline H-E-B plus!",
    "phoneNumber": "(512) 249-9012",
    "postalCode": "78717-5992",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "668": {
    "address1": "2990 EAST HWY 190",
    "allowAtgCurbside": true,
    "city": "COPPERAS COVE",
    "isCurbside": true,
    "latitude": 31.11872,
    "longitude": -97.86448,
    "name": "Copperas Cove H-E-B plus!",
    "phoneNumber": "(254) 547-6333",
    "postalCode": "76522-2515",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "673": {
    "address1": "250 UNIVERSITY BLVD.",
    "allowAtgCurbside": true,
    "city": "ROUND ROCK",
    "isCurbside": true,
    "latitude": 30.56107,
    "longitude": -97.68859,
    "name": "University Blvd H-E-B",
    "phoneNumber": "(512) 864-8000",
    "postalCode": "78665-1044",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "694": {
    "address1": "2965 IH35 NORTH",
    "allowAtgCurbside": true,
    "city": "NEW BRAUNFELS",
    "isCurbside": true,
    "latitude": 29.731,
    "longitude": -98.0782,
    "name": "New Braunfels H-E-B plus!",
    "phoneNumber": "(830) 312-5700",
    "postalCode": "78130-4678",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "696": {
    "address1": "5000 GATTIS SCHOOL RD",
    "allowAtgCurbside": true,
    "city": "HUTTO",
    "isCurbside": true,
    "latitude": 30.50112,
    "longitude": -97.58284,
    "name": "Hutto 130 and Gattis School H-E-B plus!",
    "phoneNumber": "(737) 484-0700",
    "postalCode": "78634-2025",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "708": {
    "address1": "14501 RR12",
    "allowAtgCurbside": true,
    "city": "WIMBERLEY",
    "isCurbside": true,
    "latitude": 30.00144,
    "longitude": -98.10174,
    "name": "Wimberley H-E-B",
    "phoneNumber": "(512) 842-3700",
    "postalCode": "78676-6215",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "710": {
    "address1": "8801 SOUTH CONGRESS AVENUE",
    "allowAtgCurbside": true,
    "city": "AUSTIN",
    "isCurbside": true,
    "latitude": 30.16862,
    "longitude": -97.78723,
    "name": "Slaughter and South Congress H-E-B",
    "phoneNumber": "(737) 236-8348",
    "postalCode": "78745",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "714": {
    "address1": "2000 RANCH ROAD 620 S",
    "allowAtgCurbside": true,
    "city": "LAKEWAY",
    "isCurbside": true,
    "latitude": 30.34368,
    "longitude": -97.96662,
    "name": "Lakeway H-E-B",
    "phoneNumber": "(512) 599-5800",
    "postalCode": "78734-6238",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "716": {
    "address1": "1340 E COURT ST",
    "allowAtgCurbside": true,
    "city": "SEGUIN",
    "isCurbside": true,
    "latitude": 29.57065,
    "longitude": -97.94366,
    "name": "Seguin H-E-B",
    "phoneNumber": "(830) 379-8384",
    "postalCode": "78155-5131",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "721": {
    "address1": "1101 W. STAN SCHLUETER LOOP",
    "allowAtgCurbside": true,
    "city": "KILLEEN",
    "isCurbside": true,
    "latitude": 31.07989,
    "longitude": -97.75988,
    "name": "Fort Hood Stan Schlueter H-E-B",
    "phoneNumber": "(254) 226-3600",
    "postalCode": "76542",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "732": {
    "address1": "17238 BULVERDE ROAD",
    "allowAtgCurbside": true,
    "city": "SAN ANTONIO",
    "isCurbside": true,
    "latitude": 29.59497,
    "longitude": -98.41746,
    "name": "Bulverde and 1604 H-E-B",
    "phoneNumber": "(210) 642-4700",
    "postalCode": "78247",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "735": {
    "address1": "1503 FM 1431",
    "allowAtgCurbside": true,
    "city": "MARBLE FALLS",
    "isCurbside": true,
    "latitude": 30.58301,
    "longitude": -98.27972,
    "name": "Marble Falls H-E-B",
    "phoneNumber": "(830) 693-3561",
    "postalCode": "78654-4902",
    "state": "TX",
    "storeHours": "Mon-Sun 06:00 AM - 11:00 PM"
  },
  "773": {
    "address1": "1601 TRINITY ST",
    "allowAtgCurbside": false,
    "city": "AUSTIN",
    "isCurbside": false,
    "latitude": 30.27747,
    "longitude": -97.73507,
    "name": "H-E-B Pharmacy at the UTHTB",
    "phoneNumber": "(512) 320-9998",
    "postalCode": "78712",
    "state": "TX",
    "storeHours": "Mon-Fri 08:00 AM - 06:00 PM"
  }
}
""";