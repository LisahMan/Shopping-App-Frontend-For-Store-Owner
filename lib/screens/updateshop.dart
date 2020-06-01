import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:projectx_shop_app/models/shop.dart';
import 'package:toast/toast.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class UpdateShop extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UpdateShopState();
  }
}

class _UpdateShopState extends State<UpdateShop> {

  File _image;
  Directory dir;
  bool _updateImage;
  String _shopId;
  Shop shop;

  GlobalKey<FormState> _updateShopFormKey;
  GlobalKey<ScaffoldState> _updateShopScaffoldKey;

  TextEditingController _shopNameController;
  TextEditingController _districtController;
  TextEditingController _locationController;
  TextEditingController _phoneNumberController;
  TextEditingController _descriptionController;

  List<String> _days;
  List<bool> _timingCheckBox;
  List<String> _openingTime;
  List<String> _closingTime;

  bool _showTiming;
  bool _timingChanged;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _updateShopFormKey = new GlobalKey<FormState>();
    _updateShopScaffoldKey = new GlobalKey<ScaffoldState>();

    _shopNameController = new TextEditingController();
    _districtController = new TextEditingController();
    _locationController = new TextEditingController();
    _phoneNumberController = new TextEditingController();
    _descriptionController = new TextEditingController();

    _days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    _timingCheckBox = new List();
    _openingTime = new List();
    _closingTime = new List();
    _updateImage = false;
    _showTiming=false;
    _timingChanged=false;

    _baseUrl = "http://10.0.2.2:3000/";

    _getShopId();
  }

  void _getShopId() async{
    final prefs = await SharedPreferences.getInstance();
     _shopId =  prefs.getString("shop_id");
    debugPrint('shopId'+_shopId);
     _getShop();
  }

  void _getShop() async{

    String url = _baseUrl + "shop/"+_shopId;
    debugPrint(url);
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    debugPrint("shopData $data");

    if(data['message']=='Shop not found'){
      SnackBar _snackBar = SnackBar(
          content: Text("Shop not found"));
      _updateShopScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['error']!=null){
      SnackBar _snackBar = SnackBar(
          content: Text("Some error occured try again"));
      _updateShopScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else {
      var s = data['shop'];
      String shopName = s['name'];
      String district = s['district'];
      String location = s['address'];
      String phoneNumber = s['phoneNumber'];
      String description = s['description'];

      for(var t in s['timings']){
        if(t['opening']=="closed"){
          _timingCheckBox.add(false);
          _openingTime.add("00:00");
          _closingTime.add("00:00");
        }
        else{
          _timingCheckBox.add(true);
          _openingTime.add(t['opening']);
          _closingTime.add(t['closing']);
        }
      }
      setState(() {
        _showTiming=true;
      });
      _shopNameController.text = shopName;
      _districtController.text = district;
      _locationController.text = location;
      _phoneNumberController.text = phoneNumber;
      _descriptionController.text = description;


      shop = new Shop(_shopId, null, shopName, district, location, phoneNumber, null, description, null);

      if (s['shopPic'] != null) {
        String shopPic = s['shopPic'];
        String shopPicUrl = _baseUrl+ "uploads/" +
            shopPic.toString().split('\\')[1];
        final image = await DefaultCacheManager().getSingleFile(shopPicUrl);
        debugPrint("image $image");
        if (image != null) {
          setState(() {
            _image = File(image.path);
          });
        }
      }
    }


  }


  void _setShopName(String shopName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('shop_name', shopName);
  }

  void _updateShop(BuildContext context) async {

    String url = _baseUrl + "shop/"+_shopId;

    if(!_updateImage){
      debugPrint('update image false');
     List<Map<String,dynamic>> body = new List();

     if(shop.name!=_shopNameController.text.trim()){
     body.add({
       "propName" : "name",
       "value" : _shopNameController.text.trim()
     });
     }
     if(shop.district!=_districtController.text.trim()){
       body.add({
         "propName" : "district",
         "value" : _districtController.text.trim()
       });
     }
     if(shop.location!=_locationController.text.trim()) {
       body.add({
         "propName": "address",
         "value": _locationController.text.trim()
       });
     }
       if(shop.phoneNumber!=_phoneNumberController.text.trim()) {
         body.add({
         "propName" : "phoneNumber",
         "value" : _phoneNumberController.text.trim()
         });
       }
       if(shop.description!=_descriptionController.text.trim()){
         body.add({
           "propName" : "description",
           "value" : _descriptionController.text.trim()
         });
       }

      if(_timingChanged){
        debugPrint("Timing Changed");
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
        body.add({
          "propName" : "timings",
          "value" : timings
        });
      }

     var response = await http.patch(url,
         headers: {
           "Accept": "application/json",
           "Content-Type": "application/json"
         },
         body: jsonEncode(body)
     );

     var data = await jsonDecode(response.body);
     debugPrint(data.toString());
     if(data['message']=="Shop not found"){
       SnackBar _snackBar = SnackBar(
           content: Text("Shop not found"));
       _updateShopScaffoldKey.currentState.showSnackBar(_snackBar);
     }
     else if(data['error']!=null){
       SnackBar _snackBar = SnackBar(
           content: Text("Some error occured try again"));
       _updateShopScaffoldKey.currentState.showSnackBar(_snackBar);
     }else{
       if(shop.name != _shopNameController.text.trim()){
         _setShopName(_shopNameController.text.trim());
       }
       Toast.show("Shop Succesfully Updated", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
       Navigator.of(context).pop(true);
     }
    }
    else{
      debugPrint('update image true');
      var request = http.MultipartRequest("Patch", Uri.parse(url));

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

      request.fields['name'] = _shopNameController.text;
      request.fields['district'] = _districtController.text;
      request.fields['address'] = _locationController.text;
      request.fields['phoneNumber'] = _phoneNumberController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['timings'] = jsonEncode(timings);

      if(_image!=null) {
        var pic = await http.MultipartFile.fromPath('shopPic', _image.path);
        request.files.add(pic);
      }

      var response = await request.send();
      var dataString = await response.stream.bytesToString();
      var data = await jsonDecode(dataString);

      debugPrint('response $data');
      if(data['message']=="Shop not found"){
        SnackBar _snackBar = SnackBar(
            content: Text("Shop not found"));
        _updateShopScaffoldKey.currentState.showSnackBar(_snackBar);
      }
      else if(data['error']!=null){
        SnackBar _snackBar = SnackBar(
            content: Text("Some error occured try again"));
        _updateShopScaffoldKey.currentState.showSnackBar(_snackBar);
      }else{
        if(shop.name != _shopNameController.text.trim()){
          _setShopName(_shopNameController.text.trim());
        }
        Toast.show("Shop Succesfully Updated", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
        Navigator.of(context).pop(true);
      }
    }
  }

  void _getShopPic() async {
    final image = await Navigator.of(context).pushNamed('/selectProfilePic');

    if(image!=null) {
      if(_image==image){
        _updateImage=false;
      }else{
       _updateImage=true;
       setState(() {
         _image = image;
         debugPrint('image $_image');
       });
      }
    }
    else{
      _updateImage=false;
    }
  }

  Widget _buildForm(){
    return Form(
        key: _updateShopFormKey,
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
                  _getShopPic();
                }
            )
                : GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(_image),
                        fit: BoxFit.fill
                    )
                ),

              ),

              onTap: (){
                _getShopPic();
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

        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
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
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          controller: _locationController,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter your Shop Location";
            }
          },

          decoration: InputDecoration(
              labelText: "Location",
              hintText: "New Road",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextFormField(
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
        ),

        SizedBox(
          height: 10.0,
        ),


        TextFormField(
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
          height: 10,
        ),


        (_showTiming==true)? _buildTimingExpansionTile()
                     : Text("Loading"),


        SizedBox(
          height: 30.0,
        ),

        Container(
          height: 50.0,
          width: 250.0,

          child: RaisedButton(
            child: Text("Update Shop",
              style: TextStyle(fontSize: 25.0, color: Colors.white),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            color: Theme
                .of(context)
                .primaryColor,
            onPressed: () {
              if (_updateShopFormKey.currentState.validate()) {
                debugPrint("Shop Set Up");
                _updateShop(context);
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
              _timingChanged=true;
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
      initialTime: (condition==0)
          ? TimeOfDay(hour: int.parse(_openingTime[day].substring(0,1)),minute: int.parse(_openingTime[day].substring(3,4)))
          : TimeOfDay(hour: int.parse(_closingTime[day].substring(0,1)),minute: int.parse(_closingTime[day].substring(3,4))),
    );

    if(_time!=null){
      _timingChanged=true;
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
        key: _updateShopScaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Shop Update", style: TextStyle(color: Colors.white),),
        ),

        body: _buildForm()

      );
  }
}