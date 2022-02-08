import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/user.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/widgets/custom_search.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/pill_button.dart';
import 'package:my_heb_clone/widgets/product_search_delegate.dart';
import 'package:my_heb_clone/widgets/store_configuration_header.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: StoreConfigurationHeader(user: user),
        centerTitle: false,
        action: IconButton(
          onPressed: () {
            customShowSearch(
              useRootNavigator: true,
              context: context,
              delegate: ProductSearchDelegate(),
            );
          },
          icon: Icon(Icons.search_sharp),
        ),
      ),
      // floatingActionButton: FAB(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Stack(
                children: [
                  Placeholder(),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get ready to feast',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        PillButton(
                          onPressed: () {},
                          child: Text('Shop now'),
                          color: accentColor,
                          noPadding: true,
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 24),
              Text('Sliced & ready to eat',
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(height: 12),
              Placeholder(fallbackHeight: 200),
              SizedBox(height: 52),
              Stack(
                children: [
                  Placeholder(fallbackHeight: 100),
                  Text(
                    'Covid-19 vaccines',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
              SizedBox(height: 52),
              Text('Shop our picks',
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(height: 12),
              Container(
                height: 160,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 8,
                    itemBuilder: (_, __) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Placeholder(),
                      );
                    }),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
