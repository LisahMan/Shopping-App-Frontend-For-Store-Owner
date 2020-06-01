import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectx_shop_app/screens/signup.dart';
import 'package:projectx_shop_app/screens/shopsetup.dart';
import 'package:projectx_shop_app/screens/login.dart';
import 'package:projectx_shop_app/screens/start.dart';
import 'package:projectx_shop_app/screens/home.dart';
import 'package:projectx_shop_app/screens/loading.dart';
import 'package:projectx_shop_app/screens/selectprofilepic.dart';
import 'package:projectx_shop_app/screens/addproduct.dart';
import 'package:projectx_shop_app/screens/addproductimage.dart';
import 'package:projectx_shop_app/screens/viewproduct.dart';
import 'package:projectx_shop_app/screens/updateproduct.dart';
import 'package:projectx_shop_app/screens/updateshop.dart';
import 'package:projectx_shop_app/screens/resetpassword.dart';
import 'package:projectx_shop_app/screens/parameterproduct.dart';
import 'package:projectx_shop_app/screens/productfilter.dart';


void main()=>runApp(MainScreen());

class MainScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen>{

  Widget screen = Loading() ;

  void _setScreen() async{
    final prefs = await SharedPreferences.getInstance();

    if(prefs.getBool('logged_in')!=null){
      if(prefs.getBool('logged_in')){
        setState(() {
          screen = Home();
        });
      }
      else{
        setState(() {
          screen = Start();
        });

      }
    }
    else{
      setState(() {
        screen = Start();
      });

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setScreen();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "ProjectXShop",
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        primaryColorLight: Colors.deepPurpleAccent,
      ),

      routes: <String,WidgetBuilder>{

        '/start' : (context) => Start(),
        '/signUp': (context) => SignUp(),
        '/shopSetup': (context) => ShopSetup(),
        '/login': (context) => Login(),
        '/selectProfilePic': (context) => SelectProfilePic(),
        '/home': (context) => Home(),
        '/addProduct': (context) => AddProduct(),
//        '/addProductImage': (context) => AddProductImage(),
        '/viewProduct': (context)=> ViewProduct(),
        '/updateShop': (context) => UpdateShop(),
        '/resetPassword': (context) => ResetPassword(),
      },

      onGenerateRoute: (settings){
        if(settings.name=='/addProductImage'){
          final List<File> imageList = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return AddProductImage(imageList);
            }
          );
        }
        else if(settings.name == '/updateProduct') {
          final product = settings.arguments;
          return MaterialPageRoute(
              builder: (context){
                return UpdateProduct(product);
              });

        }
        else if(settings.name == '/parameterProduct'){
          final parameter = settings.arguments;
          return MaterialPageRoute(
            builder: (context){
              return ParameterProduct(parameter);
            }
          );
        }
        else if(settings.name == '/productFilter'){
          final List<String> args = settings.arguments;
          return MaterialPageRoute(
              builder: (context){
                return ProductFilter(args);
              }
          );
        }

      },

      home: screen,

    );
  }
}