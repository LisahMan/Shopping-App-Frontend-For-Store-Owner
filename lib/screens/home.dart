import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home>{

  String _shopName;
  var _homeScaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getShopInfo();
  }


  void _getShopInfo() async{
    final prefs = await SharedPreferences.getInstance();
      _shopName = prefs.getString('shop_name');
  }


      void _logOut(BuildContext context){

      AlertDialog alertDialog =  AlertDialog(
      title: Text("Log Out"),
      content: Text("Do you want to log out?"),
      actions: <Widget>[

        RaisedButton(
          child: Text("Log Out",style: TextStyle(color: Colors.white),),
          onPressed: () {
            _removeInfo();
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/start', (Route<dynamic> route) => false);
          }
        ),

       FlatButton(
         child: Text("Cancel"),
         onPressed: (){
           Navigator.pop(context);
         },

       )
      ],
    );

      showDialog(context: context,
      builder: (context){
        return alertDialog;
      }
      );

  }

  void _removeInfo() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('shopowner_id');
    prefs.remove('shop_id');
    prefs.remove('username');
    prefs.remove('mobile_number');
    prefs.setBool('logged_in', false);
    }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _homeScaffoldState,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: (_shopName==null)
                      ? Text("Shop Name")
                      : Text(_shopName),

              decoration: BoxDecoration(
                  color: Colors.blue
              ),
            ),

            ListTile(
              title: Text("Update shop"),
              trailing: Icon(Icons.update),
              onTap: (){
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/updateShop');
              },
            ),

            ListTile(
              title: Text("Reset Password"),
              trailing: Icon(Icons.keyboard),
              onTap: (){
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/resetPassword');
              },
            ),

            ListTile(
              title: Text("Log Out"),
              trailing: Icon(Icons.power_settings_new),
              onTap: (){
                _logOut(context);

              },
            )
          ],
        ),

      ),

      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[


            RaisedButton.icon(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              icon: Icon(Icons.add_circle),
              label: Text("Add a product"),
              onPressed: (){
                Navigator.of(context).pushNamed('/addProduct');
              },
            ),

            RaisedButton.icon(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              icon: Icon(Icons.view_comfy),
              label: Text("View Products"),
              onPressed: (){
                Navigator.of(context).pushNamed('/viewProduct');
              },
            ),

            RaisedButton.icon(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              icon: Icon(Icons.arrow_upward),
              label: Text("Trending"),
              onPressed: (){
                Navigator.of(context).pushNamed('/parameterProduct',arguments: "trending");
              },
            ),

            RaisedButton.icon(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              icon: Icon(Icons.shopping_basket),
              label: Text("Customer bag"),
              onPressed: (){
                Navigator.of(context).pushNamed('/parameterProduct',arguments: "customerBag");
              },
            ),

          ],
        ),
      )



      ,
    );
  }

}