import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignUp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp>{

  GlobalKey<FormState> _signUpFormKey;
  GlobalKey<ScaffoldState> _signUpScaffoldKey;

  TextEditingController _usernameController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;
  TextEditingController _mobileNumberController;

  FocusNode _passwordNode;
  FocusNode _confirmPasswordNode;
  FocusNode _mobileNumberNode;

  String baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _signUpFormKey = new GlobalKey<FormState>();
    _signUpScaffoldKey = new GlobalKey<ScaffoldState>();

    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();
    _confirmPasswordController = new TextEditingController();
    _mobileNumberController = new TextEditingController();

    _passwordNode = new FocusNode();
    _confirmPasswordNode = new FocusNode();
    _mobileNumberNode = new FocusNode();

    baseUrl = "http://10.0.2.2:3000/";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    _mobileNumberNode.dispose();
    super.dispose();
  }

  void _setSignUpInfo(String id,String username,String mobileNumber) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("shopowner_id", id);
    prefs.setString("username",username);
    prefs.setString("mobile_number",mobileNumber);
  }


  void _postSignUpData(BuildContext context) async{
    Map<String,dynamic> body = {'username' : _usernameController.text.trim(),'password' : _passwordController.text,'mobileNumber' : _mobileNumberController.text.trim()};
    String url = baseUrl+"shopowner/signup/";

        var response = await http.post(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

        var data = jsonDecode(response.body);
        debugPrint(data.toString());

        if(data['message'].toString()=="Username already exists") {
      final _snackBar = SnackBar(content: Text("Please enter new Username",));
      _signUpScaffoldKey.currentState.showSnackBar(_snackBar);
      }
        else if(data['error']!=null){
          final _snackBar = SnackBar(content: Text("Some error occured please try again",));
          _signUpScaffoldKey.currentState.showSnackBar(_snackBar);
        }
    else{
       _setSignUpInfo(data['_id'], data['username'], data['mobileNumber']);
       Navigator.of(context).pushNamed('/shopSetup');
    }
  }

  Widget _buildForm(){
    return Form(
        key: _signUpFormKey,
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
              return "Enter your Username";
            }
          },

          decoration: InputDecoration(
              labelText: "Username",
              hintText: "Ram Sharma",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_mobileNumberNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _mobileNumberNode,
          controller: _mobileNumberController,
          keyboardType: TextInputType.phone,
          validator: (value){
            if(value.isEmpty){
              return "Please enter your Mobile Number";
            }
            else if(value.length<10){
              return "Mobile Number should be atleat 10 digits";
            }
          },

          decoration: InputDecoration(
              labelText: "Mobile Number",
              hintText: "9808273618",
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
              return "Please enter your Password";
            }
            else if(value.length<8){
              return "Password should have 8 characters";
            }
          },

          decoration: InputDecoration(
              labelText: "Password",
              hintText: "********",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_confirmPasswordNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _confirmPasswordNode,
          controller: _confirmPasswordController,
          obscureText: true,
          validator: (value){
            if(value.isEmpty){
              return "Please Confirm your Password";
            }
            else if(_passwordController.text.isNotEmpty){
              if(_passwordController.text != value){
                return "Password doesn't match";
              }
            }
          },

          decoration: InputDecoration(
              labelText: "Confirm Password",
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0),),
            child: Text("Sign Up",style: TextStyle(fontSize: 25.0,color: Colors.white),),
            color: Colors.deepPurpleAccent,
            onPressed: (){
              if(_signUpFormKey.currentState.validate()){
                _postSignUpData(context);
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
      key: _signUpScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Sign Up"),
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