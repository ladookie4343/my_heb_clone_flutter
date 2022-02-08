import 'dart:collection';

import 'package:my_heb_clone/models/department.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/services/heb_http_service.dart';


class ProductsProvider {
  final _hebHttpService = HebHttpService();

  var _departments = <Department>[];

  UnmodifiableListView<Department> get departments =>
      UnmodifiableListView(_departments);

  var _allProducts = <Product>[];

  UnmodifiableListView<Product> get allProducts =>
      UnmodifiableListView(_allProducts);

  Future<void> fetchDepartments() async {
    // _departments = LocalData.data;
    _departments = await _hebHttpService.getDepartmentsWithCategoriesAndTypes();
  }

  Future<void> fetchProducts(String departmentId, String categoryId) async {
    final currentDepartment =
        _departments.firstWhere((department) => department.id == departmentId);
    final category = currentDepartment.getCategory(categoryId);
    final products = await _hebHttpService.getProducts(categoryId);

    category.products = products;
  }

  Future<void> fetchAllProducts() async {
    _allProducts = await _hebHttpService.getAllProducts();
  }
}
