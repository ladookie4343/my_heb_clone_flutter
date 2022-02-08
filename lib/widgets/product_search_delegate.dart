import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/providers/products_provider.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/widgets/custom_search.dart';
import 'package:my_heb_clone/widgets/product_view_grid.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ProductSearchDelegate extends CustomSearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => null;

  @override
  Widget? buildLeading(BuildContext context) => GestureDetector(
        onTap: () {
          close(context, null);
        },
        child: Icon(
          Icons.close,
          size: 28,
          color: selectedGrey,
        ),
      );

  @override
  Widget buildResults(BuildContext context) {
    context.read<UserProvider>().saveSearchTerm(query);
    var allProducts = context.read<ProductsProvider>().allProducts;
    var filteredProducts = allProducts
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredProducts.length == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20, width: 100.w),
          Text(
            'No exact match for "$query"',
            style: Theme.of(context).textTheme.headline6,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 120, horizontal: 40),
            child: Column(
              children: [
                Icon(Icons.search, size: 64, color: selectedGrey,),
                Text('No products found')
              ],
            ),
          )
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 40.0,
      crossAxisSpacing: 10.0,
      children: filteredProducts
          .map((product) => ProductViewGrid(product: product))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var user = context.read<UserProvider>().user!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (query.isEmpty)
          Text('Recent', style: Theme.of(context).textTheme.headline5),
        if (user.recentSearches != null)
          ...user.recentSearches!
              .take(5)
              .map((e) => buildSuggestion(
                    context,
                    e,
                  ))
              .toList(),
      ].expand((widget) => [widget, SizedBox(height: 40)]).toList(),
    );
  }

  Widget buildSuggestion(BuildContext context, String searchQuery) {
    final style = Theme.of(context)
        .textTheme
        .bodyText2
        ?.copyWith(fontSize: 16, fontWeight: FontWeight.w400);
    return GestureDetector(
      onTap: () {
        query = searchQuery;
        showResults(context);
      },
      child: Text(searchQuery, style: style),
    );
  }
}
