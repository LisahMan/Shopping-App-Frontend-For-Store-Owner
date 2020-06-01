import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class AddProduct extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddProductState();
  }
}

class _AddProductState extends State<AddProduct>{

  GlobalKey<FormState> _addProductFormKey;
  GlobalKey<ScaffoldState> _addProductScaffoldKey;

  List<File> _imageList;
  List<File> _imageListCopy;

  TextEditingController _nameController;
  TextEditingController _typeOfProductController;
  TextEditingController _priceController;
  TextEditingController _colorController;
  TextEditingController _sizeController;
  TextEditingController _descriptionController;

  bool _negotiable;

  List<String> _categories;
  String _categorySelected;

  FocusNode _typeOfProductNode;
  FocusNode _priceNode;
  FocusNode _colorNode;
  FocusNode _sizeNode;
  FocusNode _descriptionNode;

  String baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _addProductFormKey = new GlobalKey<FormState>();
    _addProductScaffoldKey = new GlobalKey<ScaffoldState>();

    _nameController = new TextEditingController();
    _typeOfProductController = new TextEditingController();
    _priceController = new TextEditingController();
    _colorController = new TextEditingController();
    _sizeController = new TextEditingController();
    _descriptionController = new TextEditingController();

    _negotiable = false;

    _categories = ['Female','Male','Unisex','Boy','Girl','Infant'];
    _categorySelected = "Female";

    _typeOfProductNode = new FocusNode();
    _priceNode = new FocusNode();
    _sizeNode = new FocusNode();
    _colorNode = new FocusNode();
    _descriptionNode = new FocusNode();

    baseUrl = "http://10.0.2.2:3000/";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _typeOfProductNode.dispose();
    _priceNode.dispose();
    _sizeNode.dispose();
    _colorNode.dispose();
    _descriptionNode.dispose();
    super.dispose();
  }

  void _getProductImage() async{

    if(_imageList!=null) {
      _imageListCopy = List<File>.generate(
          _imageList.length, (i) => _imageList[i]);
    }
    final imageList = await Navigator.of(context).pushNamed('/addProductImage',arguments: _imageListCopy);

       debugPrint("gotBack $imageList");

         if (imageList != null) {
           _imageList = imageList;
         }

      debugPrint("ImageList $_imageList");

  }

  void _addProduct() async{

    final prefs = await SharedPreferences.getInstance();
    String shopId = prefs.getString('shop_id');

    String url = baseUrl+"product/";

    var request = http.MultipartRequest("POST",Uri.parse(url));
    request.fields['shopId'] = shopId;
    request.fields['name'] = _nameController.text.trim();
    request.fields['category'] = _categorySelected;
    request.fields['typeOfProduct'] = _typeOfProductController.text.trim();
    request.fields['price'] = _priceController.text.trim();
    request.fields['negotiable'] = _negotiable.toString();
    request.fields['color'] = _colorController.text.trim();
    request.fields['size'] = _sizeController.text.trim();
    request.fields['description'] = _descriptionController.text.trim();
    request.fields['date'] = DateTime.now().toIso8601String();

    if(_imageList!=null) {
      for (int i = 0; i < _imageList.length; i++) {
        var pic = await http.MultipartFile.fromPath(
            'productImages', _imageList[i].path);
        request.files.add(pic);
      }
    }

    var response = await request.send();
    var dataString = await response.stream.bytesToString();
    var data = await jsonDecode(dataString);

    debugPrint('response $data');

    if(data['error']==null){
      Toast.show("Product Succesfully Added", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      Navigator.of(context).pop();
    }
    else{
      Toast.show("Error", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
  }

  Widget _buildForm(){
    return Form(
        key: _addProductFormKey,
        child: _buildFormElements(),
    );
  }

  Widget _buildFormElements(){
    return ListView(
      children: <Widget>[

        TextFormField(
          controller: _nameController,
          validator: (value){
            if(value.isEmpty){
              return "Please enter the product name";
            }
          },

          decoration: InputDecoration(
              labelText: "Product Name",
              hintText: "Polo Tshirt",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_typeOfProductNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        Row(
          children: <Widget>[

            Text("Category",style: TextStyle(fontSize: 20.0),),

            SizedBox(
              width: 20.0,
            ),

            DropdownButton(
              items: _categories.map((String categoriesString){
                return DropdownMenuItem<String>(
                  value: categoriesString,
                  child: Text(categoriesString),
                );
              }).toList(),

              value: _categorySelected,
              onChanged: (newCategorySelected){
                setState(() {
                  _categorySelected=newCategorySelected;
                  debugPrint("$_categorySelected");

                });
              },


            )
          ],

        ),



        SizedBox(
          height: 10.0,
        ),

        TextFormField(
          focusNode: _typeOfProductNode,
          controller: _typeOfProductController,
          validator: (value){
            if(value.isEmpty){
              return "Please enter type of product";
            }
          },

          decoration: InputDecoration(
              labelText: "Type of Product",
              hintText: "T-Shirt",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_priceNode),
        ),

        SizedBox(
          height: 10.0,
        ),

        Row(

          children: <Widget>[

            Expanded(
              child: TextFormField(
                focusNode: _priceNode,
                controller: _priceController,
                validator: (value){
                  if(value.isEmpty){
                    return "Please enter the price of the product";
                  }
                },

                decoration: InputDecoration(
                    labelText: "Price",
                    hintText: "1000",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )
                ),
                onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_colorNode),
              ),
            ),

            SizedBox(
              width: 20.0,
            ),

            Text("Negotiable",style: TextStyle(fontSize: 20.0),),


            Checkbox(
                value: _negotiable,
                onChanged: (newValue){
                  setState(() {
                    _negotiable = newValue;
                    debugPrint("negotiable $_negotiable");
                  });
                }),

          ],
        ),

        SizedBox(
          height: 10,
        ),

        TextFormField(
          focusNode: _colorNode,
          controller: _colorController,
          validator: (value){
            if(value.isEmpty){
              return "Please enter product color";
            }
          },
          decoration: InputDecoration(
              labelText: "Color",
              hintText: "Red,Blue,Yellow",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_sizeNode),
        ),

        SizedBox(
          height: 10,
        ),

        TextFormField(
          focusNode: _sizeNode,
          controller: _sizeController,
          validator: (value){
            if(value.isEmpty){
              return "Please enter product size";
            }
          },
          decoration: InputDecoration(
              labelText: "Size",
              hintText: "S,M,L,XL,XLL",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
              )
          ),
          onFieldSubmitted: (v)=>FocusScope.of(context).requestFocus(_descriptionNode),
        ),

        SizedBox(
          height: 10,
        ),

        TextFormField(
          focusNode: _descriptionNode,
          controller: _descriptionController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          validator: (value){
            if(value.isEmpty){
              return "Please enter product description";
            }
          },

          decoration: InputDecoration(
              labelText: "Description",
              hintText: "Softest cotton tshirt",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              )
          ),
        ),


        SizedBox(
          height: 10.0,
        ),

        Container(
          width: 100.0,
          height: 50.0,
          child: FlatButton.icon(
              color: Colors.white70,
              icon: Icon(Icons.add_a_photo,size: 20.0,),
              label: Text("Add Photos",style: TextStyle(fontSize: 20.0),),
              onPressed: (){
                _getProductImage();
              }),
        ),


        SizedBox(
          height: 15.0,
        ),

        Divider(
          height: 2.0,
          color: Colors.grey,
        ),

        SizedBox(
          height: 15.0,
        ),

        Container(
          width: 100.0,
          height: 50.0,
          child: RaisedButton(
              child: Text("Add product",style: TextStyle(fontSize: 20.0 , color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              color: Theme.of(context).primaryColor,
              onPressed: (){

                if(_imageList==null){
                  SnackBar _snackBar = SnackBar(content: Text("Please select photos for the product"));
                  _addProductScaffoldKey.currentState.showSnackBar(_snackBar);
                }else if(_imageList.length==0){
                  SnackBar _snackBar = SnackBar(content: Text("Please select photos for the product"));
                  _addProductScaffoldKey.currentState.showSnackBar(_snackBar);
                }
                if(_addProductFormKey.currentState.validate()){
                  _addProduct();

                }
              }

          ),
        )

      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _addProductScaffoldKey,
      appBar: AppBar(
        title: Text("Add a Product"),
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


//class CustomAlertDialog extends StatefulWidget{
//
//  String _alertTitle;
//  List<String> _itemName;
//  List<bool> _itemSelected;
//
//
//  CustomAlertDialog(String alertTitle,List<String> itemName,List<bool> itemSelected){
//  this._alertTitle = alertTitle;
//  this._itemName = itemName;
//  this._itemSelected = itemSelected;
//
//  }
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _CustomAlertDialogState(this._alertTitle,this._itemName,this._itemSelected);
//  }
//}
//
//class _CustomAlertDialogState extends State<CustomAlertDialog>{
//
//  String _alertTitle;
//  List<String> _itemName;
//  List<bool> _itemSelected;
//
//
//
//  _CustomAlertDialogState(String alertTitle,List<String> itemName,List<bool> itemSelected){
//   this._alertTitle = alertTitle;
//   this._itemName = itemName;
//   this._itemSelected = itemSelected;
//
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return AlertDialog(
//      title: Text(_alertTitle),
//      content: ListView.builder(
//          scrollDirection: Axis.vertical,
//          shrinkWrap: true,
//          itemCount: _itemName.length,
//          itemBuilder: (context,position){
//            return CheckboxListTile(
//              title: Text(_itemName[position]),
//              value: _itemSelected[position],
//              selected: _itemSelected[position],
//              onChanged: (newValue){
//                setState(() {
//                  _itemSelected[position] = newValue;
//                });
//
//              },
//            );
//          }
//
//      ),
//
//      actions: <Widget>[
//
//        RaisedButton(
//          child: Text("Ok",style: TextStyle(color: Colors.white),),
//          onPressed: (){
//           Navigator.of(context).pop(_itemSelected);
//          },
//
//        ),
//
//        FlatButton(
//          child: Text("Cancel"),
//          onPressed: (){
//            Navigator.of(context).pop();
//          },
//        )
//      ],
//    );
//  }
//}