import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/department.dart';
import 'package:my_heb_clone/providers/products_provider.dart';
import 'package:my_heb_clone/screens/shop/categories_screen.dart';
import 'package:my_heb_clone/widgets/custom_search.dart';
import 'package:my_heb_clone/widgets/product_search_delegate.dart';
import 'package:provider/provider.dart';


class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final departments = context.read<ProductsProvider>().departments;
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final department = departments[index];
              return _buildDepartmentListItem(context, department, index);
            },
          ),
          Positioned(child: _buildSearchBar(context))
        ],
      ),
    );
  }

  Widget _buildDepartmentListItem(
    BuildContext context,
    Department department,
    int index,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CategoriesScreen(department)),
      ),
      child: Stack(
        children: [
          Container(
            height: 287,
            width: double.infinity,
            decoration: BoxDecoration(border: Border(bottom: BorderSide())),
            child: Image.asset(
              'assets/images/department_placeholder.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              index % 2 == 0 ? _buildSpacer() : _buildText(department),
              index % 2 == 0 ? _buildText(department) : _buildSpacer(),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildText(Department department) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 26, bottom: 80),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: department.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              WidgetSpan(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpacer() {
    return Expanded(
      child: Container(
        height: 285,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          customShowSearch(
            useRootNavigator: true,
            context: context,
            delegate: ProductSearchDelegate(),
          );
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(25)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.search_sharp, color: selectedGrey),
              SizedBox(width: 4),
              Text(
                'Search',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: unselectedGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
