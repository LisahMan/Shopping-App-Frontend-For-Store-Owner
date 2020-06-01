import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';


class ResetPassword extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ResetPasswordState();
  }
}

class _ResetPasswordState extends State<ResetPassword>{

  GlobalKey<FormState> _resetPasswordFormKey;
  GlobalKey<ScaffoldState> _resetPasswordScaffoldKey;
  String _shopownerId;
  TextEditingController _currentPasswordController;
  TextEditingController _newPasswordController;
  TextEditingController _confirmNewPasswordController;
  String _baseUrl;
  FocusNode _newPasswordNode;
  FocusNode _confirmNewPasswordNode;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _resetPasswordFormKey = new GlobalKey<FormState>();
    _resetPasswordScaffoldKey = new GlobalKey<ScaffoldState>();
    _currentPasswordController = new TextEditingController();
    _newPasswordController = new TextEditingController();
    _confirmNewPasswordController = new TextEditingController();
    _baseUrl="http://10.0.2.2:3000/";
    _newPasswordNode = new FocusNode();
    _confirmNewPasswordNode = new FocusNode();
    _getShopownerId();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _newPasswordNode.dispose();
    _confirmNewPasswordNode.dispose();
    super.dispose();
  }

  void _getShopownerId() async{
    final prefs = await SharedPreferences.getInstance();
    _shopownerId = prefs.getString('shopowner_id');
  }

  void _resetPassword(BuildContext context) async{
    String url = _baseUrl+"shopowner/resetpassword";
    Map<String,dynamic> body = {
      'shopownerId' : _shopownerId,
      'currentPassword' : _currentPasswordController.text.trim(),
      'newPassword' : _newPasswordController.text.trim()
    };

    var response = await http.patch(url,
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

    var data = jsonDecode(response.body);

    if(data['message'] == 'Shopowner doesnt exists'){
      SnackBar _snackBar = SnackBar(content: Text("Shopowner doesnt exists"),);
      _resetPasswordScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['message']=='Current password is incorrect'){
      SnackBar _snackBar = SnackBar(content: Text("Current password is incorrect"),);
      _resetPasswordScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['error']!=null){
      SnackBar _snackBar = SnackBar(content: Text("Some error occured try again"),);
      _resetPasswordScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else{
      Toast.show("Password Changed", context ,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
      Navigator.of(context).pop();
    }
  }

  Widget _buildForm(){
    return Form(
      key: _resetPasswordFormKey,
      child: _buildFormElements(),
    );
  }

  Widget _buildFormElements(){
    return ListView(
      children: <Widget>[
        TextFormField(
          controller: _currentPasswordController,
          obscureText: true,
          validator: (value){
            if(value.isEmpty){
              return "Please enter current password";
            }
          },

          decoration: InputDecoration(
            labelText: "Current Password",
            hintText: "********",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
            )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_newPasswordNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          controller: _newPasswordController,
          focusNode: _newPasswordNode,
          obscureText: true,

          validator: (value){
            if(value.isEmpty){
              return "Please enter your new Password";
            }
            else if(value.length<8){
              return "Password should have 8 characters";
            }
          },

          decoration: InputDecoration(
            labelText: "New Password",
            hintText: "*********",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
            )
          ),

          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_confirmNewPasswordNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          controller: _confirmNewPasswordController,
          focusNode: _confirmNewPasswordNode,
          obscureText: true,
          validator: (value){
            if(value.isEmpty){
              return "Please re-enter your new password";
            }
            else if(_newPasswordController.text.isNotEmpty){
              if(_newPasswordController.text!=value){
                return "Password doesn't match";
              }
            }
          },
          
          decoration: InputDecoration(
            labelText: "Confirm new password",
            hintText: "********",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
            ),
          ),
        ),

        SizedBox(
          height: 20.0,
        ),

        Container(
          width: 300.0,
          child: RaisedButton(
            child: Text("Update"),
            onPressed: (){
              if(_resetPasswordFormKey.currentState.validate()){
                _resetPassword(context);
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
      key: _resetPasswordScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Reset Password"),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _buildForm(),
        ),
      )
    );
  }
}