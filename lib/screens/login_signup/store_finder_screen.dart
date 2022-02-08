import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/shopping_method.dart';
import 'package:my_heb_clone/models/store.dart';
import 'package:my_heb_clone/models/user.dart';
import 'package:my_heb_clone/providers/stores_provider.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/bottom_tab_bar.dart';
import 'package:my_heb_clone/widgets/heb_alert_dialog.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sizer/sizer.dart';

class StoreFinderScreen extends StatefulWidget {
  static const routeName = 'store-finder';

  /// if true, this means that we don't save the user's selection on the back-end
  /// when they select a store. Instead we pop the user's selection to the previous
  /// screen and that screen will handle saving the selection on the back-end.
  final bool isCacheOnly;

  final ShoppingMethod? shoppingMethod;

  StoreFinderScreen({this.isCacheOnly = false, Key? key, this.shoppingMethod})
      : super(key: key);

  @override
  State<StoreFinderScreen> createState() => _StoreFinderScreenState();
}

class _StoreFinderScreenState extends State<StoreFinderScreen> {
  Completer<GoogleMapController> _controller = Completer();
  List<Store> stores = [];
  User? user;
  Set<Marker> _markers = Set<Marker>();
  BitmapDescriptor? curbsideMarker;
  BitmapDescriptor? nonCurbsideMarker;
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int currentVisibleStoreIndex = 0;
  bool isMapView = true;
  String? selectedStoreId;

  @override
  void initState() {
    super.initState();
    stores = context.read<StoresProvider>().stores.take(25).toList();
    user = context.read<UserProvider>().user;
    createMarkers();
    itemPositionsListener.itemPositions.addListener(animateToStore);
  }

  Future<void> createMarkers() async {
    curbsideMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      // this doesn't seem to do anything. this shows how to change the marker size:  https://stackoverflow.com/questions/53633404/how-to-change-the-icon-size-of-google-maps-marker-in-flutter
      'assets/images/store_location_curbside.png',
    );
    nonCurbsideMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(1, 1)),
      // this doesn't seem to do anything. this shows how to change the marker size:  https://stackoverflow.com/questions/53633404/how-to-change-the-icon-size-of-google-maps-marker-in-flutter
      'assets/images/store_location.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context,
          title: Text(
            getTitle(),
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          action: IconButton(
            onPressed: () {
              setState(() {
                isMapView = !isMapView;
              });
            },
            icon: isMapView ? Icon(Icons.list) : Icon(Icons.map),
          )),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              zoomControlsEnabled: false,
              padding: EdgeInsets.only(bottom: 33.h),
              initialCameraPosition: CameraPosition(
                target: LatLng(stores[0].latitude, stores[0].longitude),
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                setState(() {
                  _markers = stores
                      .map((store) => Marker(
                          markerId: MarkerId(store.id),
                          position: LatLng(store.latitude, store.longitude),
                          icon: store.isCurbside
                              ? curbsideMarker!
                              : nonCurbsideMarker!))
                      .toSet();
                });
              },
            ),
          ),
          Positioned(
            bottom: 3.h,
            child: Container(
              width: 100.w,
              height: 30.h,
              child: ScrollablePositionedList.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stores.length,
                itemBuilder: _buildStoreTile,
                itemPositionsListener: itemPositionsListener,
              ),
            ),
          ),
          if (!isMapView)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: _buildStoreListItem,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStoreTile(BuildContext context, int index) {
    Store store = stores[index];
    return Container(
      width: 80.w,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: line))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          store.name,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Text('1.24 mi')
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    store.address,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    '${store.city}, ${store.state} ${store.postalCode}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 4.h),
                  buildStoreStatus(context, store, user!),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              color: user!.store != null && store.id == user!.store!.id ? accentColor : null,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: InkWell(
                  onTap: () => _saveStoreAndNavigate(store),
                  child: Text(
                    buttonText(store),
                    style: user!.store != null && store.id == user!.store!.id
                        ? TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          )
                        : Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreListItem(BuildContext context, int index) {
    Store store = stores[index];
    return Container(
      margin: EdgeInsets.only(top: 2.h, left: 2.h, right: 2.h),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    store.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text('1.23 mi')
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${store.address}\n${store.city}, ${store.state} ${store.postalCode}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Image.asset(
                    store.isCurbside
                        ? 'assets/images/curbside.png'
                        : 'assets/images/curbside_not_available.png',
                    width: 3.h,
                    height: 3.h,
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              buildStoreStatus(context, store, user!),
              SizedBox(height: 2.5.h),
              Row(
                children: [
                  if (store.isCurbside ||
                      (!store.isCurbside &&
                          _getShoppingMethod() == ShoppingMethod.inStore))
                    SizedBox(
                      width: 2.5.h,
                      height: 2.5.h,
                      child: Radio(
                        value: store.id,
                        activeColor: accentColor,
                        groupValue: selectedStoreId,
                        onChanged: (String? value) =>
                            _saveStoreAndNavigate(store),
                      ),
                    ),
                  if (store.isCurbside ||
                      (!store.isCurbside &&
                          _getShoppingMethod() == ShoppingMethod.inStore))
                    SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () => _saveStoreAndNavigate(store),
                    child: Text(
                      buttonText(store),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  String buttonText(Store store) {
    return _getShoppingMethod() == ShoppingMethod.inStore
        ? '${store.id == user!.store!.id ? 'Your' : 'Set as'} in-store location'
        : store.isCurbside
            ? '${user!.store != null && store.id == user!.store!.id ? 'Your' : 'Set as'} pickup location'
            : 'Switch to in-store';
  }

  Widget buildStoreStatus(BuildContext context, Store store, User user) {
    final textTheme = Theme.of(context).textTheme;
    Widget widget;

    if (isMapView &&
        _getShoppingMethod() == ShoppingMethod.inStore &&
        store.isCurbside) {
      widget = Row(
        children: [
          Image.asset(
            'assets/images/curbside.png',
            width: 5.w,
            height: 5.w,
          ),
          SizedBox(width: 2.w),
          Text('Curbside available', style: textTheme.subtitle2)
        ],
      );
    } else if (isMapView && !store.isCurbside) {
      widget = Row(
        children: [
          Image.asset(
            'assets/images/curbside_not_available.png',
            width: 5.w,
            height: 5.w,
          ),
          SizedBox(width: 2.w),
          Text(
            'Curbside not available yet',
            style: TextStyle(fontStyle: FontStyle.italic),
          )
        ],
      );
    } else if (store.isCurbside) {
      widget = Row(
        children: [
          Icon(
            Icons.access_time,
            color: accentColor,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Text(nextAvailableDescription, style: textTheme.subtitle2)
        ],
      );
    } else if (!store.isCurbside && !isMapView) {
      widget = Container();
    } else {
      widget = Container();
    }
    return widget;
  }

  String get nextAvailableDescription =>
      'Next available pickup time is Today,${isMapView ? '\n' : ' '}${DateFormat('MMM d').format(DateTime.now())}';

  void animateToStore() {
    var positions = itemPositionsListener.itemPositions.value.toList();
    // 0 is left edge of screen, 1 is right edge of screen
    var properlyPlacedPositions = positions.where((element) =>
        element.itemLeadingEdge >= 0 && element.itemLeadingEdge < .4);
    var newVisibleStoreIndex = properlyPlacedPositions.length > 0
        ? properlyPlacedPositions.first.index
        : currentVisibleStoreIndex;
    if (newVisibleStoreIndex != currentVisibleStoreIndex) {
      _goToStore(newVisibleStoreIndex);
      currentVisibleStoreIndex = newVisibleStoreIndex;
    }
  }

  Future<void> _goToStore(int index) async {
    GoogleMapController controller = await _controller.future;
    CameraPosition position = CameraPosition(
      target: LatLng(stores[index].latitude, stores[index].longitude),
      zoom: 14,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  String getTitle() {
    switch (_getShoppingMethod()) {
      case ShoppingMethod.curbside:
        return 'Choose pickup location';
      case ShoppingMethod.inStore:
        return 'Choose in-store location';
      default:
        return 'Choose store location';
    }
  }

  Future<void> _saveStoreAndNavigate(Store store) async {
    bool? isContinue = true;
    if (_getShoppingMethod() == ShoppingMethod.curbside && !store.isCurbside) {
      isContinue = await showDialog<bool?>(
        context: context,
        builder: (context) => HebAlertDialog(
          title: 'Switch to in-store shopping?',
          content:
              "This store doesn't offer curbside yet, but you can still browse and view details about in-store items.",
          actions: [
            HebAlertDialogButton(
              title: 'CANCEL',
              isPrimary: false,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            HebAlertDialogButton(
              title: 'CONTINUE',
              isPrimary: true,
              onPressed: () {
                if (!widget.isCacheOnly) {
                  context
                      .read<UserProvider>()
                      .updateShoppingMethod(ShoppingMethod.inStore);
                }
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
    }
    if (isContinue != null && isContinue) {
      if (!widget.isCacheOnly) {
        context.read<UserProvider>().updateStore(store);
        Navigator.of(context).pushReplacementNamed(BottomTabBar.routeName);
      } else {
        Navigator.of(context).pop(store);
      }
    }
  }

  ShoppingMethod _getShoppingMethod() {
    return widget.shoppingMethod ?? user!.shoppingMethod!;
  }
}
