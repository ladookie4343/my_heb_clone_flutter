import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/category.dart';
import 'package:my_heb_clone/models/department.dart';
import 'package:my_heb_clone/providers/products_provider.dart';
import 'package:my_heb_clone/screens/shop/products_screen.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/heb_chip.dart';
import 'package:my_heb_clone/widgets/product_view.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  final Department department;

  const CategoriesScreen(this.department, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(
        context,
        title: Text(
          department.title,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: _buildBottomAppBarButtons(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 8.0, right: 8.0),
          child: Column(
            children: department.categories.map((category) {
              return FutureBuilder(
                  future: context
                      .read<ProductsProvider>()
                      .fetchProducts(department.id, category.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return _buildCategoryView(context, category);
                    }
                  });
            }).toList(),
          ),
        ),
      ),
    );
  }

  PreferredSize _buildBottomAppBarButtons(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * .06),
      child: Container(
        height: MediaQuery.of(context).size.height * .06,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(width: 10),
              ...department.categories
                  .map((category) =>
                      _buildCategoryAppBarButton(context, category))
                  .toList(),
              Container(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryView(BuildContext context, Category category) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProductsScreen(category)),
                ),
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // have to have this container height due to this issue: https://github.com/flutter/flutter/issues/73786
        Container(
          height: 300,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...category.products
                  .take(10)
                  .map((product) => ProductView(product: product))
                  .toList(),
              _buildViewAllCircleButton(context, category)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildViewAllCircleButton(BuildContext context, Category category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductsScreen(category)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(bottom: 5.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: 2.0,
                ),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: accentColor,
              ),
            ),
            Text(
              'View all',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAppBarButton(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductsScreen(category)),
      ),
      child: HebChip(category.title, backgroundButton),
    );
  }
}
