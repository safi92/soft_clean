import 'package:flutter/material.dart';
import 'package:flutter_restaurant/stripe/services/payment.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  onItemPress(BuildContext context, int index) async {
    switch (index) {
      case 0:
        payViaNewCard(context,'0');
        break;
      case 1:
        Navigator.pushNamed(context, '/existing-cards');
        break;
    }
  }
/*
setamount(String amounts) async {

    final prefs = await SharedPreferences.getInstance();

    var ammt = await prefs.setString("ammt", amounts);
print("aaaaaaaaa ammt");

}*/

  payViaNewCard(BuildContext context,String amounts) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response = await StripeService.payWithNewCard(amount: amounts, currency: 'USD');
    await dialog.hide();
    print("hello g");
    print(amounts);
   /* Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(response.message),
      duration: new Duration(milliseconds: response.success == true ? 1200 : 3000),
    ));*/
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('SELECT PAYMENT'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, index) {
              Icon icon;
              Text text;

              switch (index) {
                case 0:
                  icon = Icon(Icons.add_circle, color: theme.primaryColor);
                  text = Text('Pay via new card');
                  break;
                case 1:
                  icon = Icon(Icons.credit_card, color: theme.primaryColor);
                  text = Text('Pay via existing card');
                  break;
              }

              return InkWell(
                onTap: () {
                  onItemPress(context, index);
                },
                child: ListTile(
                  title: text,
                  leading: icon,
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
                  color: theme.primaryColor,
                ),
            itemCount: 2),
      ),
    );
  }
}
