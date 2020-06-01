import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:projectx_shop_app/models/product.dart';
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:collection/collection.dart';

class UpdateProduct extends StatefulWidget{

  final Product _product;

  UpdateProduct(this._product);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UpdateProductState(this._product);
  }
}

class _UpdateProductState extends State<UpdateProduct>{


  final Product _product;
  _UpdateProductState(this._product);

  Directory dir;

  GlobalKey<FormState> _updateProductFormKey;
  GlobalKey<ScaffoldState> _updateProductScaffoldKey;

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

  bool _imageUpdate;

  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _updateProductFormKey = new GlobalKey<FormState>();
    _updateProductScaffoldKey = new GlobalKey<ScaffoldState>();

    _imageList = new List();

    _nameController = new TextEditingController();
    _typeOfProductController = new TextEditingController();
    _priceController = new TextEditingController();
    _colorController = new TextEditingController();
    _sizeController = new TextEditingController();
    _descriptionController = new TextEditingController();

    _negotiable = false;

    _categories = ['Female','Male','Unisex','Boy','Girl','Infant'];
    _categorySelected = "Female";

    _imageUpdate = false;

    _baseUrl = "http://10.0.2.2:3000/";

    _setProduct();

  }

  void _setProduct() async{
    _nameController.text = _product.name;
    _categorySelected = _product.category;
    _typeOfProductController.text = _product.typeOfProduct;
    _priceController.text = _product.price.toString();

    setState(() {
      _negotiable = _product.negotiable;
    });

    _colorController.text = _product.color;
    _sizeController.text = _product.size;
    _descriptionController.text = _product.description;

    for(int i=0;i<_product.productImages.length;i++){
      String url = _baseUrl+"uploads/" + _product.productImages[i].toString().split('\\')[1];
      final image = await DefaultCacheManager().getSingleFile(url);
      File file = File(image.path);
      _imageList.add(file);
    }

    debugPrint("imgnet $_imageList");
  }

  void _getProductImage() async{

    if(_imageList!=null) {
      _imageListCopy = List<File>.generate(
          _imageList.length, (i) => _imageList[i]);
    }
    final imageList = await Navigator.of(context).pushNamed('/addProductImage',arguments: _imageListCopy);

    debugPrint("gotBack $imageList");

    if (imageList != null) {
      if(ListEquality().equals(_imageList, imageList)){
        _imageUpdate=false;
      }
      else{
        _imageUpdate=true;
        _imageList = imageList;
      }

    }else{
      _imageUpdate=false;
    }

    debugPrint("ImageList $_imageList");

  }

  void _updateProduct() async{
//    final prefs = await SharedPreferences.getInstance();
//    String shopId = prefs.getString('shop_id');
    String url = _baseUrl+"product/" + _product.productId;

    List<Map<String,dynamic>> body = new List();


    if(!_imageUpdate) {
      debugPrint("image update false");
      if (_nameController.text.trim() != _product.name) {
        body.add({"propName": "name",
          "value": _nameController.text.trim()
        });
      }
      if (_categorySelected != _product.category) {
        body.add({"propName": "category",
          "value": _categorySelected
        });
      }

      if (_typeOfProductController.text.trim() != _product.typeOfProduct) {
        body.add({"propName": "typeOfProduct",
          "value": _typeOfProductController.text.trim()
        });
      }

      if (_priceController.text.trim() != _product.price.toString()) {
        body.add({"propName": "price",
          "value": _priceController.text.trim()
        });
      }

      if (_negotiable != _product.negotiable) {
        body.add({"propName": "negotiable",
          "value": _negotiable
        });

        if (_colorController.text.trim() != _product.color) {
          body.add({"propName": "color",
            "value": _colorController.text.trim()
          });
        }

        if (_sizeController.text.trim() != _product.size) {
          body.add({"propName": "size",
            "value": _sizeController.text.trim()
          });
        }

        if (_descriptionController.text.trim() != _product.description) {
          body.add({"propName": "description",
            "value": _descriptionController.text.trim()
          });
        }
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
      if(data['message']=="Product not found"){
        SnackBar _snackBar = SnackBar(
            content: Text("Product not found"));
        _updateProductScaffoldKey.currentState.showSnackBar(_snackBar);
      }
      else if(data['error']!=null){
        SnackBar _snackBar = SnackBar(
            content: Text("Some error occured try again"));
        _updateProductScaffoldKey.currentState.showSnackBar(_snackBar);
      }else{
        Toast.show("Product Succesfully Updated", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
        Navigator.of(context).pop(true);
      }

    }else{
      debugPrint("image update true");
      var request = http.MultipartRequest("PATCH",Uri.parse(url));
      request.fields['name'] = _nameController.text.trim();
      request.fields['category'] = _categorySelected;
      request.fields['typeOfProduct'] = _typeOfProductController.text.trim();
      request.fields['price'] = _priceController.text.trim();
      request.fields['negotiable'] = _negotiable.toString();
      request.fields['color'] = _colorController.text.trim();
      request.fields['size'] = _sizeController.text.trim();
      request.fields['description'] = _descriptionController.text.trim();
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


      if(data['message']=="Product not found"){
        SnackBar _snackBar = SnackBar(
            content: Text("Some error occured try again"));
        _updateProductScaffoldKey.currentState.showSnackBar(_snackBar);
      }
      else if(data['error']!=null){
        SnackBar _snackBar = SnackBar(
            content: Text("Some error occured try again"));
        _updateProductScaffoldKey.currentState.showSnackBar(_snackBar);
      }else{
        Toast.show("Product Succesfully Updated", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
        Navigator.of(context).pop(true);
      }
    }
  }

  Widget _buildForm(){
    return Form(
        key: _updateProductFormKey,
        child: _buildFormElements()
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
        ),

        SizedBox(
          height: 10.0,
        ),

        Row(

          children: <Widget>[

            Expanded(
              child: TextFormField(
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
        ),

        SizedBox(
          height: 10,
        ),

        TextFormField(
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
        ),

        SizedBox(
          height: 10,
        ),

        TextFormField(
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
              child: Text("Update product",style: TextStyle(fontSize: 20.0 , color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              color: Theme.of(context).primaryColor,
              onPressed: (){

                if(_imageList==null){
                  SnackBar _snackBar = SnackBar(content: Text("Please select photos for the product"));
                  _updateProductScaffoldKey.currentState.showSnackBar(_snackBar);
                }else if(_imageList.length==0){
                  SnackBar _snackBar = SnackBar(content: Text("Please select photos for the product"));
                  _updateProductScaffoldKey.currentState.showSnackBar(_snackBar);
                }
                if(_updateProductFormKey.currentState.validate()){
                  _updateProduct();

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
        key: _updateProductScaffoldKey,
        appBar: AppBar(
          title: Text("Update Product"),
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
