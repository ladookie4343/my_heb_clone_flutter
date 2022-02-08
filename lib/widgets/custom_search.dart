import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../colors.dart';

Future<T?> customShowSearch<T>({
  required BuildContext context,
  required CustomSearchDelegate<T> delegate,
  String? query = '',
  bool useRootNavigator = false,
}) {
  delegate.query = query ?? delegate.query;
  delegate._currentBody = _CustomSearchBody.suggestions;
  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push(_CustomSearchPageRoute<T>(
    delegate: delegate,
  ));
}

abstract class CustomSearchDelegate<T> {
  CustomSearchDelegate({
    this.searchFieldLabel,
    this.searchFieldStyle,
    this.searchFieldDecorationTheme,
    this.keyboardType,
    this.textInputAction = TextInputAction.search,
  }) : assert(searchFieldStyle == null || searchFieldDecorationTheme == null);

  Widget buildSuggestions(BuildContext context);

  Widget buildResults(BuildContext context);

  Widget? buildLeading(BuildContext context);

  List<Widget>? buildActions(BuildContext context);

  PreferredSizeWidget? buildBottom(BuildContext context) => null;

  String get query => _queryTextController.text;

  set query(String value) {
    _queryTextController.text = value;
    _queryTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: _queryTextController.text.length));
  }

  void showResults(BuildContext context) {
    _focusNode?.unfocus();
    _currentBody = _CustomSearchBody.results;
  }

  void showSuggestions(BuildContext context) {
    assert(_focusNode != null,
        '_focusNode must be set by route before showSuggestions is called.');
    _focusNode!.requestFocus();
    _currentBody = _CustomSearchBody.suggestions;
  }

  void close(BuildContext context, T result) {
    _currentBody = null;
    _focusNode?.unfocus();
    Navigator.of(context)
      ..popUntil((Route<dynamic> route) => route == _route)
      ..pop(result);
  }

  final String? searchFieldLabel;

  final TextStyle? searchFieldStyle;

  final InputDecorationTheme? searchFieldDecorationTheme;

  final TextInputType? keyboardType;

  final TextInputAction textInputAction;

  Animation<double> get transitionAnimation => _proxyAnimation;

  // The focus node to use for manipulating focus on the search page. This is
  // managed, owned, and set by the _SearchPageRoute using this delegate.
  FocusNode? _focusNode;

  final TextEditingController _queryTextController = TextEditingController();

  final ProxyAnimation _proxyAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  final ValueNotifier<_CustomSearchBody?> _currentBodyNotifier =
      ValueNotifier<_CustomSearchBody?>(null);

  _CustomSearchBody? get _currentBody => _currentBodyNotifier.value;

  set _currentBody(_CustomSearchBody? value) {
    _currentBodyNotifier.value = value;
  }

  _CustomSearchPageRoute<T>? _route;
}

enum _CustomSearchBody {
  suggestions,
  results,
}

class _CustomSearchPageRoute<T> extends PageRoute<T> {
  _CustomSearchPageRoute({
    required this.delegate,
  }) {
    assert(
      delegate._route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before opening another search with the same delegate instance.',
    );
    delegate._route = this;
  }

  final CustomSearchDelegate<T> delegate;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get maintainState => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child, // child is the value returned by pageBuilder
    );
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    delegate._proxyAnimation.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _CustomSearchPage<T>(
      delegate: delegate,
      animation: animation,
    );
  }

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    assert(delegate._route == this);
    delegate._route = null;
    delegate._currentBody = null;
  }
}

class _CustomSearchPage<T> extends StatefulWidget {
  const _CustomSearchPage({
    required this.delegate,
    required this.animation,
  });

  final CustomSearchDelegate<T> delegate;
  final Animation<double> animation;

  @override
  State<StatefulWidget> createState() => _CustomSearchPageState<T>();
}

class _CustomSearchPageState<T> extends State<_CustomSearchPage<T>> {
  // This node is owned, but not hosted by, the search page. Hosting is done by
  // the text field.
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate._queryTextController.addListener(_onQueryChanged);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
    focusNode.addListener(_onFocusChanged);
    widget.delegate._focusNode = focusNode;
  }

  @override
  void dispose() {
    super.dispose();
    widget.delegate._queryTextController.removeListener(_onQueryChanged);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate._focusNode = null;
    focusNode.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    if (widget.delegate._currentBody == _CustomSearchBody.suggestions) {
      focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(_CustomSearchPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      oldWidget.delegate._queryTextController.removeListener(_onQueryChanged);
      widget.delegate._queryTextController.addListener(_onQueryChanged);
      oldWidget.delegate._currentBodyNotifier
          .removeListener(_onSearchBodyChanged);
      widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
      oldWidget.delegate._focusNode = null;
      widget.delegate._focusNode = focusNode;
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus &&
        widget.delegate._currentBody != _CustomSearchBody.suggestions) {
      widget.delegate.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    setState(() {
      // rebuild ourselves because query changed.
    });
  }

  void _onSearchBodyChanged() {
    setState(() {
      // rebuild ourselves because search body changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
    ));

    final String searchFieldLabel = widget.delegate.searchFieldLabel ??
        MaterialLocalizations.of(context).searchFieldLabel;
    Widget? body;
    switch (widget.delegate._currentBody) {
      case _CustomSearchBody.suggestions:
        body = KeyedSubtree(
          key: const ValueKey<_CustomSearchBody>(_CustomSearchBody.suggestions),
          child: widget.delegate.buildSuggestions(context),
        );
        break;
      case _CustomSearchBody.results:
        body = KeyedSubtree(
          key: const ValueKey<_CustomSearchBody>(_CustomSearchBody.results),
          child: widget.delegate.buildResults(context),
        );
        break;
      case null:
        break;
    }

    Widget? leading = widget.delegate.buildLeading(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Theme(
          data: ThemeData(
            primarySwatch: formSwatch,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) leading,
                if (leading != null)
                  SizedBox(
                    height: 8,
                  ),
                TextField(
                  controller: widget.delegate._queryTextController,
                  focusNode: focusNode,
                  cursorHeight: 20,
                  textInputAction: widget.delegate.textInputAction,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: widget.delegate.keyboardType,
                  onSubmitted: (String _) {
                    widget.delegate.showResults(context);
                  },
                  decoration: InputDecoration(
                      prefixIconConstraints: BoxConstraints(maxWidth: 32),
                      prefixIcon: Icon(Icons.search, size: 32),
                      hintText: searchFieldLabel,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontSize: 16),
                      suffixIcon:
                          widget.delegate._queryTextController.text.length > 0
                              ? IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    widget.delegate.query = '';
                                  },
                                )
                              : null,
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: accentColor))),
                ),
                if (widget.delegate._currentBody ==
                    _CustomSearchBody.suggestions)
                  SizedBox(height: 32),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
