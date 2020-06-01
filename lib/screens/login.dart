import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';


class Login extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<Login>{

  GlobalKey<FormState> _loginFormKey;
  GlobalKey<ScaffoldState> _loginScaffoldKey;

  TextEditingController _usernameController;
  TextEditingController _passwordController;

  FocusNode _passwordNode;

  String baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loginFormKey = new GlobalKey<FormState>();
    _loginScaffoldKey = new GlobalKey<ScaffoldState>();

    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();

    _passwordNode=new FocusNode();

    baseUrl = "http://10.0.2.2:3000/";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _passwordNode.dispose();
    super.dispose();
  }
  
  void _setLoginInfo(String shopownerId,String shopId,String username,String mobileNumber,String shopName) async{
    
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('shopowner_id',shopownerId );
    prefs.setString('shop_id',shopId);
    prefs.setString('username', username);
    prefs.setString('mobile_number', mobileNumber);
    prefs.setString('shop_name', shopName);
    prefs.setBool('logged_in', true);
  }

  void _postLoginData(BuildContext context) async{

    Map<String,dynamic> body = {'username' : _usernameController.text.trim(),'password' : _passwordController.text};
    String url = baseUrl+"shopowner/login/";

    var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

    var data = jsonDecode(response.body);

    if(data['message'].toString()=="Auth failed"){
      SnackBar _snackBar = SnackBar(content: Text("Please enter your details correctly"),);
      _loginScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if (data['error']!=null){
      SnackBar _snackBar = SnackBar(content: Text("Some error occured please try again"),);
      _loginScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['shop']==null){
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('shopowner_id', data['_id']);
      prefs.setString('username', data['username']);
      prefs.setString('mobile_number', data['mobileNumber']);
      Navigator.of(context).pushNamed('/shopSetup',arguments: "login");
    }
    else{
      _setLoginInfo(data['_id'], data['shop']['_id'], data['username'], data['mobileNumber'],data['shop']['name']);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

  Widget _buildForm(){
    return Form(
        key: _loginFormKey,
        child: _buildFormElements(),
    );
  }

  Widget _buildFormElements(){
    return ListView(
      children: <Widget>[

        TextFormField(
          controller: _usernameController,
          validator: (value){
            if(value.isEmpty){
              return "Please enter Username";
            }
          },

          decoration: InputDecoration(
              labelText: "Username",
              hintText: "Ram Sharma",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_passwordNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _passwordNode,
          controller: _passwordController,
          obscureText: true,
          validator: (value){
            if(value.isEmpty){
              return "Please enter Password";
            }
          },

          decoration: InputDecoration(
              labelText: "Password",
              hintText: "********",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
        ),

        SizedBox(
          height: 30.0,
        ),

        Container(
          height: 50.0,
          width: 200.0,
          child: RaisedButton(

            child: Text("Login",style: TextStyle(color: Colors.white,fontSize: 25.0),),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
            color: Colors.red,
            onPressed: (){
              if(_loginFormKey.currentState.validate()){
                _postLoginData(context);
              }
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _loginScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login",style: TextStyle(color: Colors.white),),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildForm(),
        ),
      )
    );
  }
}