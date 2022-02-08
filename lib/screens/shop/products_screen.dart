import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/category.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/models/type.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/heb_chip.dart';
import 'package:my_heb_clone/widgets/product_view_grid.dart';

class ProductsScreen extends StatefulWidget {
  final Category _category;

  const ProductsScreen(this._category, {Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _currentSelectedTypeId = 'all';
  late List<Product> _currentSelectedProducts;

  @override
  void initState() {
    super.initState();
    _currentSelectedProducts = widget._category.products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(
        context,
        title: Text(
          widget._category.title,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 5),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: borderColor,
                  ),
                ),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTypeButton(Type('all', 'All', '')),
                  ...widget._category.types
                      .map((type) => _buildTypeButton(type))
                      .toList(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 73,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 40.0,
                  crossAxisSpacing: 10.0,
                  children: _currentSelectedProducts
                      .map((product) => ProductViewGrid(product: product))
                      .toList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(Type type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedTypeId = type.id;
          _currentSelectedProducts = type.id == 'all'
              ? widget._category.products
              : widget._category.products
                  .where((product) => product.typeId == _currentSelectedTypeId)
                  .toList();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 1.0),
        child: type.id == _currentSelectedTypeId
            ? HebChip(type.title, selectedGrey)
            : Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                    type.title,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
      ),
    );
  }
}
