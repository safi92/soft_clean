import 'package:flutter/material.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/stripe/pages/home.dart';
import 'package:flutter_restaurant/stripe/stripe_main.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class CustomCheckBox extends StatelessWidget {
  
  // class CustomCheckBox extends StatefulWidget {

  //   @override
  // HomePageState createState() => HomePageState();

  // }

  // class HomePageState extends State<CustomCheckBox> {
  
  final String title;
  final int index;
    final String amount;
  CustomCheckBox({@required this.amount, @required this.title, @required this.index});

// @override
//   void initState() {
//     super.initState();
//     StripeService.init();
//   }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, order, child) {
        return InkWell(
          // onTap: () => order.setPaymentMethod(index),
          onTap: () => {
            order.setPaymentMethod(index),

            // Navigator.pushReplacement(
            // context,
            // MaterialPageRoute(
            //     builder: (_) => StripePayment()))

            // HomePageState.payViaNewCard(context)

    //         ProgressDialog dialog = new ProgressDialog(context),
    // dialog.style(message: 'Please wait...');
    // await dialog.show();
    // var response = await StripeService.payWithNewCard(amount: '250', currency: 'USD');
    // await dialog.hide();
    // Scaffold.of(context).showSnackBar(SnackBar(
    //   content: Text(response.message),
    //   duration: new Duration(milliseconds: response.success == true ? 1200 : 3000),
    // ));
    
// if(index==1) {
// print('yes yes $amount'),
// HomePageState().payViaNewCard(context,amount+'00')
// }

          }
          ,
          child: Row(children: [
            Checkbox(
              value: order.paymentMethodIndex == index,
              activeColor: ColorResources.getPrimaryColor(context),
              onChanged: (bool isChecked) => order.setPaymentMethod(index),
            ),
            Expanded(
              child: Text(title, style: rubikRegular.copyWith(
                color: order.paymentMethodIndex == index ? Theme.of(context).textTheme.bodyText1.color : ColorResources.getGreyColor(context),
              )),
            ),
          ]),
        );
      },
    );
  }
}
