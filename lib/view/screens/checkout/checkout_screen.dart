import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/stripe/pages/home.dart';
import 'package:flutter_restaurant/stripe/services/payment.dart';
import 'package:flutter/services.dart';
import 'package:flutter_restaurant/data/model/body/place_order_body.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/data/model/response/order_model.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/coupon_provider.dart';
import 'package:flutter_restaurant/provider/location_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/not_logged_in_screen.dart';
import 'package:flutter_restaurant/view/screens/address/add_new_address_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/order_successful_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/payment_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/custom_check_box.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../stripe/services/payment.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final double amount;
  final String orderType;
  CheckoutScreen(
      {@required this.cartList,
      @required this.amount,
      @required this.orderType});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _noteController = TextEditingController();
  GoogleMapController _mapController;
  bool _isCashOnDeliveryActive;
  bool _isDigitalPaymentActive;
  List<Branches> _branches = [];
  bool _loading = true;
  static SharedPreferences sharedPreferences;
  Set<Marker> _markers = HashSet<Marker>();
  bool _isLoggedIn;
  bool isChecked = true;
  DateTime selectedDate = DateTime.now();
  // String dropdownValue = 'One';
DateTime newDate = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7);
  TextEditingController _controller2;
  String _valueChanged2 = '';
  // DateTime _valueChanged2 = DateTime.now();
  String _valueToValidate2 = '';
  String _valueSaved2 = '';

  @override
  void initState() {
    super.initState();

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (_isLoggedIn) {
      _branches = Provider.of<SplashProvider>(context, listen: false)
          .configModel
          .branches;
      Provider.of<LocationProvider>(context, listen: false)
          .initAddressList(context);
      Provider.of<OrderProvider>(context, listen: false).clearPrevData();
      _isCashOnDeliveryActive =
          Provider.of<SplashProvider>(context, listen: false)
                  .configModel
                  .cashOnDelivery ==
              'true';
      _isDigitalPaymentActive =
          Provider.of<SplashProvider>(context, listen: false)
                  .configModel
                  .digitalPayment ==
              'true';
     StripeService.init();
  
    }

    _controller2 = TextEditingController(text: DateTime.now().toString());

    String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');

    _getValue();
  }

  /// This implementation is just to simulate a load data behavior
  /// from a data base sqlite or from a API
  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = '2000-10-22 14:30';

        _controller2.text = DateTime.now().toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(title: getTranslated('checkout', context)),
      body: _isLoggedIn
          ? Consumer<OrderProvider>(
              builder: (context, order, child) {
                return Consumer<LocationProvider>(
                  builder: (context, address, child) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView(
                              physics: BouncingScrollPhysics(),
                              children: [
                                _branches.length > 1
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 10, 10, 0),
                                              child: Text(
                                                  getTranslated(
                                                      'select_branch', context),
                                                  style: rubikMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .FONT_SIZE_LARGE)),
                                            ),
                                            SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding: EdgeInsets.all(
                                                    Dimensions
                                                        .PADDING_SIZE_SMALL),
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: _branches.length,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      order.setBranchIndex(
                                                          index);
                                                      _setMarkers(index);
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: Dimensions
                                                              .PADDING_SIZE_SMALL),
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: Dimensions
                                                              .PADDING_SIZE_EXTRA_SMALL,
                                                          horizontal: Dimensions
                                                              .PADDING_SIZE_SMALL),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: index ==
                                                                order
                                                                    .branchIndex
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : ColorResources
                                                                .getBackgroundColor(
                                                                    context),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Text(
                                                          _branches[index].name,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: rubikMedium
                                                              .copyWith(
                                                            color: index ==
                                                                    order
                                                                        .branchIndex
                                                                ? Colors.white
                                                                : Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText1
                                                                    .color,
                                                          )),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Container(
                                              height: 200,
                                              padding: EdgeInsets.all(Dimensions
                                                  .PADDING_SIZE_SMALL),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .PADDING_SIZE_SMALL),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                              child: Stack(children: [
                                                GoogleMap(
                                                  mapType: MapType.normal,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                          target: LatLng(
                                                            double.parse(
                                                                _branches[0]
                                                                    .latitude),
                                                            double.parse(
                                                                _branches[0]
                                                                    .longitude),
                                                          ),
                                                          zoom: 18),
                                                  zoomControlsEnabled: true,
                                                  markers: _markers,
                                                  onMapCreated:
                                                      (GoogleMapController
                                                          controller) async {
                                                    await Geolocator
                                                        .requestPermission();
                                                    _mapController = controller;
                                                    _loading = false;
                                                    _setMarkers(0);
                                                  },
                                                ),
                                                _loading
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ))
                                                    : SizedBox(),
                                              ]),
                                            ),
                                          ])
                                    : SizedBox(),

                                // Address
                                widget.orderType != 'take_away'
                                    ? Column(children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .PADDING_SIZE_SMALL),
                                          child: Row(children: [
                                            Text(
                                                getTranslated(
                                                    'delivery_address',
                                                    context),
                                                style: rubikMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                            Expanded(child: SizedBox()),
                                            TextButton.icon(
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddNewAddressScreen(
                                                              fromCheckout:
                                                                  true))),
                                              icon: Icon(Icons.add),
                                              label: Text(
                                                  getTranslated('add', context),
                                                  style: rubikRegular),
                                            ),
                                          ]),
                                        ),
                                        SizedBox(
                                          height: 60,
                                          child: address.addressList != null
                                              ? address.addressList.length > 0
                                                  ? ListView.builder(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      padding: EdgeInsets.only(
                                                          left: Dimensions
                                                              .PADDING_SIZE_SMALL),
                                                      itemCount: address
                                                          .addressList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        bool _isAvailable = _branches
                                                                    .length ==
                                                                1 &&
                                                            (_branches[0]
                                                                        .latitude ==
                                                                    null ||
                                                                _branches[0]
                                                                    .latitude
                                                                    .isEmpty);
                                                        if (!_isAvailable) {
                                                          double _distance =
                                                              Geolocator
                                                                      .distanceBetween(
                                                                    double.parse(
                                                                        _branches[order.branchIndex]
                                                                            .latitude),
                                                                    double.parse(
                                                                        _branches[order.branchIndex]
                                                                            .longitude),
                                                                    double.parse(address
                                                                        .addressList[
                                                                            index]
                                                                        .latitude),
                                                                    double.parse(address
                                                                        .addressList[
                                                                            index]
                                                                        .longitude),
                                                                  ) /
                                                                  1000;
                                                          _isAvailable = _distance <
                                                              _branches[order
                                                                      .branchIndex]
                                                                  .coverage;
                                                        }
                                                        return InkWell(
                                                          onTap: () {
                                                            if (_isAvailable) {
                                                              order
                                                                  .setAddressIndex(
                                                                      index);
                                                            }
                                                          },
                                                          child: Stack(
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 200,
                                                                  margin: EdgeInsets.only(
                                                                      right: Dimensions
                                                                          .PADDING_SIZE_LARGE),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: index ==
                                                                            order
                                                                                .addressIndex
                                                                        ? Theme.of(context)
                                                                            .accentColor
                                                                        : ColorResources.getBackgroundColor(
                                                                            context),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    border: index ==
                                                                            order
                                                                                .addressIndex
                                                                        ? Border.all(
                                                                            color:
                                                                                ColorResources.getPrimaryColor(context),
                                                                            width: 2)
                                                                        : null,
                                                                  ),
                                                                  child: Row(
                                                                      children: [
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                          child:
                                                                              Icon(
                                                                            address.addressList[index].addressType == 'Home'
                                                                                ? Icons.home_outlined
                                                                                : address.addressList[index].addressType == 'Workplace'
                                                                                    ? Icons.work_outline
                                                                                    : Icons.list_alt_outlined,
                                                                            color: index == order.addressIndex
                                                                                ? ColorResources.getPrimaryColor(context)
                                                                                : Theme.of(context).textTheme.bodyText1.color,
                                                                            size:
                                                                                30,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(address.addressList[index].addressType,
                                                                                    style: rubikRegular.copyWith(
                                                                                      fontSize: Dimensions.FONT_SIZE_SMALL,
                                                                                      color: ColorResources.getGreyBunkerColor(context),
                                                                                    )),
                                                                                Text(address.addressList[index].address, style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                                                                              ]),
                                                                        ),
                                                                        index ==
                                                                                order.addressIndex
                                                                            ? Align(
                                                                                alignment: Alignment.topRight,
                                                                                child: Icon(Icons.check_circle, color: ColorResources.getPrimaryColor(context)),
                                                                              )
                                                                            : SizedBox(),
                                                                      ]),
                                                                ),
                                                                !_isAvailable
                                                                    ? Positioned(
                                                                        top: 0,
                                                                        left: 0,
                                                                        bottom:
                                                                            0,
                                                                        right:
                                                                            20,
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              color: Colors.black.withOpacity(0.6)),
                                                                          child:
                                                                              Text(
                                                                            getTranslated('out_of_coverage_for_this_branch',
                                                                                context),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                rubikRegular.copyWith(color: Colors.white, fontSize: 10),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : SizedBox(),
                                                              ]),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: Text(getTranslated(
                                                          'no_address_available',
                                                          context)))
                                              : Center(
                                                  child: CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(Theme.of(
                                                                  context)
                                                              .primaryColor))),
                                        ),
                                        SizedBox(height: 20),
                                      ])
                                    : SizedBox(),

                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.PADDING_SIZE_SMALL),
                                  child: Text(
                                      getTranslated('payment_method', context),
                                      style: rubikMedium.copyWith(
                                          fontSize:
                                              Dimensions.FONT_SIZE_LARGE)),
                                ),
                                _isCashOnDeliveryActive
                                    ? CustomCheckBox(
                                        title: getTranslated(
                                            'cash_on_delivery', context),
                                            amount : widget.amount.toInt().toString(),
                                        index: 0
                                 //      index: _isCashOnDeliveryActive ? 1 : 0
                                        )
                                    : SizedBox(),
                                 _isDigitalPaymentActive
                                    ? CustomCheckBox(
                                        title: getTranslated(
                                            'digital_payment', context),
                                             amount : widget.amount.toInt().toString(),
                                        index: _isCashOnDeliveryActive ? 1 : 0
                                        //  index: 1
                                         )
                                    : SizedBox(),


// Date Picker

// body: Center(

                                // Padding(
                                //   padding: EdgeInsets.all(
                                //       Dimensions.PADDING_SIZE_SMALL),
                                //   child: Column(
                                //     mainAxisSize: MainAxisSize.min,
                                //     children: <Widget>[
                                //       Text("${selectedDate.toLocal()}"
                                //           .split(' ')[0]),
                                //       SizedBox(
                                //         height: 20.0,
                                //       ),
                                //       RaisedButton(
                                //         onPressed: () => _selectDate(context),
                                //         child: Text('Select date'),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // ),

                                // Time Dropdown

                                // DropdownButton<String>(
                                //   value: dropdownValue,
                                //   icon: const Icon(Icons.arrow_downward),
                                //   elevation: 16,
                                //   style:
                                //       const TextStyle(color: Colors.deepPurple),
                                //   underline: Container(
                                //     height: 2,
                                //     color: Colors.deepPurpleAccent,
                                //   ),
                                //   onChanged: (String newValue) {
                                //     setState(() {
                                //       dropdownValue = newValue;
                                //     });

                                //     print("dropdownValue: " + dropdownValue);
                                //   },
                                //   items: <String>['One', 'Two', 'Free', 'Four']
                                //       .map<DropdownMenuItem<String>>(
                                //           (String value) {
                                //     return DropdownMenuItem<String>(
                                //       value: value,
                                //       child: Text(value),
                                //     );
                                //   }).toList(),
                                // ),

// Date Time Picker
                                DateTimePicker(
                                  type: DateTimePickerType.dateTime,
                                  dateMask: 'd MMMM, yyyy - hh:mm a',
                                  controller: _controller2,
                                  //initialValue: _initialValue,
                                  firstDate: selectedDate,
                                  lastDate: newDate,
                                  //icon: Icon(Icons.event),
                                  dateLabelText: 'Pickup Date Time',
                                  use24HourFormat: false,
                                  locale: Locale('en', 'US'),
                                  onChanged: (val) =>
                                      setState(() => _valueChanged2 = val),
                                  validator: (val) {
                                    setState(
                                        () => _valueToValidate2 = val ?? '');
                                    // print("Value to validate: " +
                                    //     _valueToValidate2);
                                    return null;
                                  },
                                  onSaved: (val) =>
                                      setState(() => _valueSaved2 = val ?? ''),
                                ),

                                
                                Padding(
                                  padding: EdgeInsets.all(
                                      Dimensions.PADDING_SIZE_SMALL),
                                  child: CustomTextField(
                                    controller: _noteController,
                                    hintText: getTranslated(
                                        'additional_note', context),
                                    maxLines: 5,
                                    inputType: TextInputType.multiline,
                                    inputAction: TextInputAction.newline,
                                    capitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ),
                              ]),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                          child: !order.isLoading
                              ? Builder(
                                  builder: (context) => CustomButton(
                                      btnTxt: getTranslated(
                                          'confirm_order', context),
                                      onTap: () async {

                        print("Checkout Screen mai: ");
                     //    prefs2 = prefs.getString("transaction_id");
                     final prefs = await SharedPreferences.getInstance();
                                        print(prefs.getString("transaction_id"));
                                            print("dasdasd");
                            //  print(             StripeService.getValue());
                           // print(StripeService.getValue2());
                           String tranIdval = '';
                    if(order.paymentMethodIndex != 0  && (widget.orderType !=
                                                'take_away' &&
                                            (order.addressIndex >= 0)      )  && _valueChanged2!='' ){
                   await  HomePageState().payViaNewCard(context,widget.amount.toInt().toString()+'00');
                   tranIdval = prefs.getString("transaction_id");
                   } 
                     print("ccccccc"+widget.amount.toInt().toString()+'00');

                 //    print(StripeService.getValue2());
//                       if((prefs.getString("transaction_id")==null && order.paymentMethodIndex != 0) || (prefs.getString("transaction_id")=='' && order.paymentMethodIndex != 0) )
// {

//    ScaffoldMessenger.of(context)
//                                               .showSnackBar(SnackBar(
//                                             content: Text('payment is not done'),
//                                             backgroundColor: Colors.red,
//                                           ));

// }                              
                                     // else  if (widget.amount <
                                          if (widget.amount <
                                            Provider.of<SplashProvider>(context,
                                                    listen: false)
                                                .configModel
                                                .minimumOrderValue) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                    'Minimum order amount is ${Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue}',
                                                  ),
                                                  backgroundColor: Colors.red));
                                        } else if (widget.orderType !=
                                                'take_away' &&
                                            (address.addressList == null ||
                                                address.addressList.length ==
                                                    0 ||
                                                order.addressIndex < 0)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(getTranslated(
                                                'select_an_address', context)),
                                            backgroundColor: Colors.red,
                                          ));
                                        }else if(_valueChanged2==null || _valueChanged2=='')
                                        {
                                            ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text('select_an_time'),
                                            backgroundColor: Colors.red,
                                          ));

                                        }else if((prefs.getString("transaction_id")==null && order.paymentMethodIndex != 0) || (prefs.getString("transaction_id")=='' && order.paymentMethodIndex != 0) )
{

   ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text('payment is not done'),
                                            backgroundColor: Colors.red,
                                          ));

} 
                                         else {
                                          List<Cart> carts = [];
                                          for (int index = 0;
                                              index < widget.cartList.length;
                                              index++) {
                                            CartModel cart =
                                                widget.cartList[index];
                                            List<int> _addOnIdList = [];
                                            List<int> _addOnQtyList = [];
                                            cart.addOnIds.forEach((addOn) {
                                              _addOnIdList.add(addOn.id);
                                              _addOnQtyList.add(addOn.quantity);
                                            });
                                            carts.add(Cart(
                                              cart.product.id.toString(),
                                              cart.discountedPrice.toString(),
                                              '',
                                              cart.variation,
                                              cart.discountAmount,
                                              cart.quantity,
                                              cart.taxAmount,
                                              _addOnIdList,
                                              _addOnQtyList,
                                            ));
                                          }
                                          order.placeOrder(
                                            
                                            PlaceOrderBody(
                                              
                                              cart: carts,
                                              couponDiscountAmount:
                                                  Provider.of<CouponProvider>(
                                                          context,
                                                          listen: false)
                                                      .discount,
                                              couponDiscountTitle: '',
                                              deliveryAddressId: widget
                                                          .orderType !=
                                                      'take_away'
                                                  ? Provider.of<
                                                              LocationProvider>(
                                                          context,
                                                          listen: false)
                                                      .addressList[
                                                          order.addressIndex]
                                                      .id
                                                  : 0,
                                              orderAmount: widget.amount,
                                              
                                              orderNote:
                                                  _noteController.text ?? '',
                                              orderTime: _valueChanged2 ?? '',
                                              tranId: tranIdval ?? '',
                                              // orderDate:
                                              // selectedDate.toLocal() ?? '',

                                              // orderDate:
                                              //     _valueChanged2.toLocal() ?? '',

                                              // orderDate: DateConverter
                                              //         .localDateToIsoString(
                                              //             _valueChanged2) ??
                                              //     '',

                                              orderDate: _valueChanged2 ?? '',

                                              orderType: widget.orderType,
                                              paymentMethod:
                                                  _isCashOnDeliveryActive
                                                      ? order.paymentMethodIndex ==
                                                              0
                                                          ? 'cash_on_delivery'
                                                          : 'Stripe'
                                                      : null,
                                              couponCode: Provider.of<
                                                                  CouponProvider>(
                                                              context,
                                                              listen: false)
                                                          .coupon !=
                                                      null
                                                  ? Provider.of<CouponProvider>(
                                                          context,
                                                          listen: false)
                                                      .coupon
                                                      .code
                                                  : null,
                                              branchId:
                                                  _branches[order.branchIndex]
                                                      .id,

                                              // orderTime: Provider.of<OrderProvider>(
                                              //             context,
                                              //             listen: false)
                                              //         .or,
                                            ),
                                            _callback,
                                          );
                                        }
                                      }),
                                )
                              : Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor))),
                        ),
                      ],
                    );
                  },
                );
              },
            )
          : NotLoggedInScreen(),
    );
  }

  void _callback(
      bool isSuccess, String message, String orderID, int addressID) async {
    print("ammar order:");
    if (isSuccess) {
       Provider.of<CartProvider>(context, listen: false).clearCartList();
       Provider.of<OrderProvider>(context, listen: false).stopLoader();
      if (_isCashOnDeliveryActive &&
          Provider.of<OrderProvider>(context, listen: false)
                  .paymentMethodIndex ==
              0) {

                 print("ammar order: " + orderID);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => OrderSuccessfulScreen(
                    orderID: orderID, status: 0, addressID: addressID)));
      } else {  //here we can add payment system
      print ("haider bhai: " + orderID);
       /* OrderModel _orderModel = OrderModel(
          paymentMethod: '',
          id: int.parse(orderID),
          userId: Provider.of<ProfileProvider>(context, listen: false)
              .userInfoModel
              .id,
          couponDiscountAmount:
              Provider.of<CouponProvider>(context, listen: false).discount,
          createdAt: DateConverter.localDateToIsoString(DateTime.now()),
          updatedAt: DateConverter.localDateToIsoString(DateTime.now()),
          orderStatus: 'pending',
          paymentStatus: 'unpaid',
          // couponDiscountAmount:
          //     Provider.of<CouponProvider>(context, listen: false).discount,
        );*/
        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => PaymentScreen(
        //             orderModel: _orderModel, fromCheckout: true)));


        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => OrderSuccessfulScreen(
        //             orderID: orderID, status: 0, addressID: addressID)));


        // order.setPaymentMethod(index),

        // if(index==1) {
// print('yes yes $amount');
// HomePageState().payViaNewCard(context,amount+'00');

// }




//  if((StripeService.getValue2()==null && order.paymentMethodIndex != 0) || (StripeService.getValue2()=='' && order.paymentMethodIndex != 0) )
// HomePageState().payViaNewCard(context,'100');    
// if(StripeService.getValue2()==null  || StripeService.getValue2()=='' )
// {

//    ScaffoldMessenger.of(context)
//                                               .showSnackBar(SnackBar(
//                                             content: Text('payment is not done'),
//                                             backgroundColor: Colors.red,
//                                           ));

// }else{        

  
      
//       if(StripeService.getValue2()!=null  || StripeService.getValue2()!='' )
// {
//        Provider.of<CartProvider>(context, listen: false).clearCartList();
//        Provider.of<OrderProvider>(context, listen: false).stopLoader();

//        Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => OrderSuccessfulScreen(
//                     orderID: orderID, status: 0, addressID: addressID)));
         final prefs = await SharedPreferences.getInstance();
 prefs.setString("transaction_id","");
//await sharedPreferences.remove("transaction_id");
// }

// }
print("pakistan");
             Navigator.pushReplacement(
             context,
             MaterialPageRoute(
                 builder: (_) => OrderSuccessfulScreen(
                     orderID: orderID, status: 0, addressID: addressID)));

      
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  void _setMarkers(int selectedIndex) async {
    Uint8List activeImageData =
        await convertAssetToUnit8List(Images.restaurant_marker, width: 70);
    Uint8List inactiveImageData = await convertAssetToUnit8List(
        Images.unselected_restaurant_marker,
        width: 70);

    // Marker
    _markers = HashSet<Marker>();
    for (int index = 0; index < _branches.length; index++) {
      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.parse(_branches[index].latitude),
            double.parse(_branches[index].longitude)),
        infoWindow: InfoWindow(
            title: _branches[index].name, snippet: _branches[index].address),
        icon: BitmapDescriptor.fromBytes(
            selectedIndex == index ? activeImageData : inactiveImageData),
      ));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
          double.parse(_branches[selectedIndex].latitude),
          double.parse(_branches[selectedIndex].longitude),
        ),
        zoom: 17)));

    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath,
      {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  /*void _setBounds(Branches branche) async {
    if(_mapController != null && _branches.length > 1) {
      LatLng _southwest = LatLng(double.parse(_branches[0].latitude), double.parse(_branches[0].longitude));
      LatLng _northeast = LatLng(double.parse(_branches[1].latitude), double.parse(_branches[1].longitude));
      double _distance = Geolocator.distanceBetween(_southwest.latitude, _southwest.longitude, _northeast.latitude, _northeast.longitude);
      List<LatLng> _latLngList = [];
      _branches.forEach((branch) => _latLngList.add(LatLng(double.parse(branch.latitude), double.parse(branch.longitude))));
      for(int index=0; index<_branches.length; index++) {
        LatLng _latLng = _latLngList[0];
        _latLngList.removeAt(0);
        _latLngList.forEach((latLng) {
          double _dist = Geolocator.distanceBetween(_latLng.latitude, _latLng.longitude, latLng.latitude, latLng.longitude);
          print(_dist.toString());
          if(_dist > _distance) {
            _southwest = _latLng;
            _northeast = latLng;
            _distance = _dist;
          }
        });
      }

      print('${_southwest.latitude} ${_northeast.latitude} $_mapController}');
      if (_southwest.latitude < _northeast.latitude) {
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: _southwest, northeast: _northeast), 30));
      } else {
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: _northeast, northeast: _southwest), 30));
      }
    }

    _setMarkers(0);
  }*/

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime picked = await showDatePicker(
  //       context: context,
  //       initialDate: selectedDate,
  //       firstDate: DateTime(2015, 8),
  //       lastDate: DateTime(2101));
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //   }
  // }
}
