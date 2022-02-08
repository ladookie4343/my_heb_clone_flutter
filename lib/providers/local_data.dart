import 'package:my_heb_clone/models/category.dart';
import 'package:my_heb_clone/models/department.dart';
import 'package:my_heb_clone/models/product.dart';

class LocalData {
  static final data = [
    Department('1', 'Fruit & Vegetables')
      ..categories = [
        Category('1', 'Fruit', '1')
          ..products = [
            Product(
              id: '1',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '2',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '3',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '4',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '5',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '6',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '7',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '8',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
          ],
        Category('2', 'Vegetables', '1')
          ..products = [
            Product(
              id: '1',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '2',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '3',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
            Product(
              id: '4',
              title: 'Fresh Young Coconut, Each',
              price: 4.1,
              priceType: 'each',
              imageId: 'dressing-oil-vinegar-490118.jpg',
              categoryId: '1',
            ),
          ],
      ]
  ];
}
