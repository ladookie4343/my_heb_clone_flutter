import 'package:dots_indicator/dots_indicator.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:flutter/material.dart';

class HebIntroPageScroller extends StatefulWidget {
  const HebIntroPageScroller({Key? key}) : super(key: key);

  @override
  _HebIntroPageScrollerState createState() => _HebIntroPageScrollerState();
}

class _HebIntroPageScrollerState extends State<HebIntroPageScroller> {
  final _pageController = PageController();
  var _currentPage = 0;
  final _introPages = [
    HebIntroPage(
      imageResource: 'assets/images/intro_placeholder.png',
      title: 'Welcome to H-E-B',
      description: 'A whole lot of Texas, right in your pocket.',
    ),
    HebIntroPage(
      imageResource: 'assets/images/intro_placeholder.png',
      title: 'Curbside Pickup',
      description: "You pop the trunk, we'll do the rest.",
    ),
    HebIntroPage(
      imageResource: 'assets/images/intro_placeholder.png',
      title: 'Home delivery',
      description: 'From store to door in no time flat.',
    ),
    HebIntroPage(
      imageResource: 'assets/images/intro_placeholder.png',
      title: 'Coupons and shopping lists',
      description: 'Save time and money with just a few taps.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _introPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (_, index) => _introPages[index],
          ),
        ),
        DotsIndicator(
          dotsCount: _introPages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
            spacing: EdgeInsets.all(4.0),
            size: Size.square(5.0),
            activeSize: Size.square(6.0),
            color: Colors.white,
            activeColor: selectedGrey,
            shape: CircleBorder(side: BorderSide(color: selectedGrey)),
          ),
        ),
      ]),
    );
  }
}

class HebIntroPage extends StatelessWidget {
  final String imageResource;
  final String title;
  final String description;

  const HebIntroPage({
    Key? key,
    required this.imageResource,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Placeholder()),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        )
      ],
    );
  }
}
