import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';


class ShopSetup extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShopSetupState();
  }
}

class _ShopSetupState extends State<ShopSetup> {

  File _image;
//  String args;

  GlobalKey<FormState> _shopSetupFormKey;
  GlobalKey<ScaffoldState> _shopSetupScaffoldKey;

  TextEditingController _shopNameController;
  TextEditingController _districtController;
  TextEditingController _locationController;
  TextEditingController _phoneNumberController;
  TextEditingController _descriptionController;

  FocusNode _districtNode;
  FocusNode _locationNode;
  FocusNode _phoneNumberNode;
  FocusNode _descriptionNode;

  List<String> _days;
  List<bool> _timingCheckBox;
  List<String> _openingTime;
  List<String> _closingTime;

  String baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _shopSetupFormKey = new GlobalKey<FormState>();
    _shopSetupScaffoldKey = new GlobalKey<ScaffoldState>();

    _shopNameController = new TextEditingController();
    _districtController = new TextEditingController();
    _locationController = new TextEditingController();
    _phoneNumberController = new TextEditingController();
    _descriptionController = new TextEditingController();

    _districtNode=new FocusNode();
    _descriptionNode=new FocusNode();
    _locationNode = new FocusNode();
    _phoneNumberNode = new FocusNode();

    _days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    _timingCheckBox = [false,false,false,false,false,false,false];
    _openingTime = ["00:00","00:00","00:00","00:00","00:00","00:00","00:00"];
    _closingTime = ["00:00","00:00","00:00","00:00","00:00","00:00","00:00"];

    baseUrl = "http://10.0.2.2:3000/";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _districtNode.dispose();
    _descriptionNode.dispose();
    _locationNode.dispose();
    _phoneNumberNode.dispose();
    super.dispose();
  }

  void _setShopSetupInfo(String id, String shopName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('shop_id', id);
    prefs.setString('shop_name', shopName);
    prefs.setBool("logged_in", true);
  }

  void _postShopSetupData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String shopownerId = prefs.getString('shopowner_id');
    debugPrint('shopownerId'+shopownerId);
    String url = baseUrl+"shop/";

    List<Map<String,String>> timings = new List();

    for(int i=0;i<7;i++){
      if(_timingCheckBox[i]){
        timings.add({
          "day" : _days[i],
          "opening" : _openingTime[i],
          "closing" : _closingTime[i]
        });
      }
      else{
        timings.add({
          "day" : _days[i],
          "opening" : "closed",
          "closing" : "closed"
        });
      }
    }


    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields['shopownerId'] = shopownerId;
    request.fields['name'] = _shopNameController.text.trim();
    request.fields['district'] = _districtController.text.trim();
    request.fields['address'] = _locationController.text.trim();
    request.fields['phoneNumber'] = _phoneNumberController.text.trim();
    request.fields['description'] = _descriptionController.text.trim();
    request.fields['date'] = DateTime.now().toIso8601String();
    request.fields['timings'] = jsonEncode(timings);

    if(_image!=null) {
      var pic = await http.MultipartFile.fromPath('shopPic', _image.path);
      request.files.add(pic);
    }

    var response = await request.send();
    var dataString = await response.stream.bytesToString();
    debugPrint(dataString);
    var data = await jsonDecode(dataString);

    debugPrint('response $data');

    if (data['message']=="Shopowner already has a shop") {
      SnackBar _snackBar = SnackBar(
          content: Text("Shopowner already has a shop"));
      _shopSetupScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['error']!=null){
      SnackBar _snackBar = SnackBar(
          content: Text("Some error occured try again"));
      _shopSetupScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else {
      _setShopSetupInfo(data['shop']['_id'], data['shop']['name']);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

    void _getShopProfilePic() async {
      final image = await Navigator.of(context).pushNamed('/selectProfilePic');

      if(image!=null) {
        setState(() {
          _image = image;
          debugPrint('image $_image');
        });
      }
    }

//    void _deleteUser() async{
//
//    final prefs = await SharedPreferences.getInstance();
//    String userId = prefs.getString('shopowner_id');
//    String url = "http://10.0.2.2:8000/shopowner/"+userId+"/";
//    var result = await http.delete(url);
//  }

//    Future<bool> _onWillPopScope() async{
//    debugPrint(args);
//    if(args.contains("signup")){
////      _deleteUser();
//    }
//    return true;
//}

  Widget _buildForm(){
    return Form(
        key: _shopSetupFormKey,
        child: _buildFormElements(),
    );
  }

  Widget _buildFormElements(){
    return ListView(
      children: <Widget>[

        Container(
            height: 150.0,
            width: 250.0,

            child: (_image == null)
                ? IconButton(
                icon: Icon(Icons.camera_alt, size: 50.0,),
                onPressed: () {
                  _getShopProfilePic();
                }
            )
                : GestureDetector(
              child: Image.file(_image),
              onTap: (){
                _getShopProfilePic();
              },
            )

        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          controller: _shopNameController,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter your Shop Name";
            }
          },

          decoration: InputDecoration(
            labelText: "Shop Name",
            hintText: "Ram Store",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_districtNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _districtNode,
          controller: _districtController,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter your Shop District";
            }
          },

          decoration: InputDecoration(
              labelText: "District",
              hintText: "Kathmandu",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_locationNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _locationNode,
          controller: _locationController,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter your Shop Location";
            }
          },

          decoration: InputDecoration(
              labelText: "Address",
              hintText: "New Road",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_phoneNumberNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _phoneNumberNode,
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter your Shop Phone Number";
            }
          },

          decoration: InputDecoration(
              labelText: "Phone Number",
              hintText: "4543456",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_descriptionNode),
        ),

        SizedBox(
          height: 10.0,
        ),


        TextFormField(
          focusNode: _descriptionNode,
          controller: _descriptionController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter your Shop Description";
            }
          },

          decoration: InputDecoration(
              labelText: "Description",
              hintText: "Write Something about your shop",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
        ),

        SizedBox(
          height : 10
        ),

        _buildTimingExpansionTile(),

        SizedBox(
          height: 30.0,
        ),

        Container(
          height: 50.0,
          width: 250.0,

          child: RaisedButton(
            child: Text("Setup Shop",
              style: TextStyle(fontSize: 25.0, color: Colors.white),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            color: Theme
                .of(context)
                .primaryColor,
            onPressed: () {
              if (_shopSetupFormKey.currentState.validate()) {
                debugPrint("Shop Set Up");
                _postShopSetupData(context);
              }
            },
          ),
        )


      ],
    );
  }

  Widget _buildTimingExpansionTile(){
    return ExpansionTile(
      title: Text("Timings"),
      children: _buildTileElements()
    );
  }

  List<Widget> _buildTileElements(){
    List<Widget> widgets = new List();
    for(int i=0;i<7;i++){
      widgets.add(Row(
        children: <Widget>[

          Checkbox(
            value: _timingCheckBox[i],
            onChanged: (newValue){
              setState(() {
                _timingCheckBox[i] = newValue;
              });
            },
          ),

          SizedBox(
            width: 10.0,
          ),

          Text(_days[i]),

          SizedBox(
            width: 10.0,
          ),

          Text("Opening"),

          SizedBox(
            width: 10.0,
          ),

          GestureDetector(
            child: Text(_openingTime[i]),
            onTap: (){
              _selectTime(i,0);
            },
          ),

          SizedBox(
            width: 10.0,
          ),

          Text("Closing"),

          SizedBox(
            width: 10.0,
          ),

          GestureDetector(
            child: Text(_closingTime[i]),
            onTap: (){
              _selectTime(i,1);
            },
          ),
        ],
      ));
    }
    return widgets;
  }

  void _selectTime(int day,int condition) async{
       TimeOfDay _time =  await showTimePicker(
       context: context,
       initialTime: TimeOfDay(hour: 08,minute: 0),
   );

    if(_time!=null){
      if(condition==0){
        setState(() {
          _openingTime[day] =  _time.toString().substring(10,15);
        });

      }
      else{
        setState(() {
          _closingTime[day] = _time.toString().substring(10,15);
        });
      }
    }
  }


    @override
    Widget build(BuildContext context) {

    // TODO: implement build
      return Scaffold(
          key: _shopSetupScaffoldKey,
          appBar: AppBar(
            centerTitle: true,
            title: Text("Shop Setup", style: TextStyle(color: Colors.white),),
          ),

          body: _buildForm()

        );
    }
  }
