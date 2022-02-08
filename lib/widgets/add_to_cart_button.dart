import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';

const double _kInitialButtonSize = 18;

class AddToCartButton extends StatefulWidget {
  final Product product;

  AddToCartButton({required this.product});

  @override
  _AddToCartButtonState createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  double _width = _kInitialButtonSize;
  double _height = _kInitialButtonSize;
  bool _visible = false;
  Timer? _timer;
  Color? _color;
  int _start = 2;

  void openButton() {
    setState(() {
      _width = 150;
      _height = 32;
      _color = accentColor;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        closeButton();
      } else {
        _start--;
      }
    });
  }

  void closeButton() {
    _timer?.cancel();
    setState(() {
      _width = _kInitialButtonSize;
      _height = _kInitialButtonSize;
      _visible = false;
      _start = 2;
    });
  }

  void holdButtonOpen() {
    _start = 2;
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String productId = widget.product.id;
    var userProvider = context.read<UserProvider>();
    var numberOfProductInShoppingCart =
        context.select<UserProvider, int>((userProvider) {
      return userProvider.numberOfProductInShoppingCart(productId);
    });

    _color = numberOfProductInShoppingCart > 0 ? accentColor : selectedGrey;

    return GestureDetector(
      onTap: () {
        if (numberOfProductInShoppingCart == 0) {
          userProvider.addProductToShoppingCart(widget.product);
        }
        openButton();
        // wait a bit to add buttons to container to prevent overflow error
        Future.delayed(Duration(milliseconds: 120), () {
          setState(() {
            _visible = true;
          });
        });
      },
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(25),
        ),
        width: numberOfProductInShoppingCart > 9 ? _width + 5 : _width,
        height: _height,
        duration: const Duration(milliseconds: 160),
        child: numberOfProductInShoppingCart > 0
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_visible)
                      GestureDetector(
                        onTap: () {
                          holdButtonOpen();
                          var remaining = userProvider.removeProductFromShoppingCart(widget.product);
                          if (remaining == 0) {
                            // close the button immediately if their are zero items left.
                            closeButton();
                          }
                        },
                        child: Icon(
                          numberOfProductInShoppingCart > 1
                              ? Icons.remove
                              : Icons.delete,
                          color: Colors.white,
                          size: _kInitialButtonSize,
                        ),
                      ),
                    Text(
                      '$numberOfProductInShoppingCart',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(color: Colors.white),
                    ),
                    if (_visible)
                      GestureDetector(
                        onTap: () {
                          holdButtonOpen();
                          userProvider.addProductToShoppingCart(widget.product);
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: _kInitialButtonSize,
                        ),
                      ),
                  ],
                ),
              )
            : Align(
                alignment: Alignment(-1, -1),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: _kInitialButtonSize,
                ),
              ),
      ),
    );
  }
}
