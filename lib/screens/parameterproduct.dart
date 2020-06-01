import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_shop_app/models/product.dart';
import 'package:toast/toast.dart';

class ParameterProduct extends StatefulWidget{
  final String _parameter;
  ParameterProduct(this._parameter);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ParameterProductState(_parameter);
  }
}

class _ParameterProductState extends State<ParameterProduct>{

  final String _parameter;
  _ParameterProductState(this._parameter);
  String _shopId;
  String _category;
  List<Product> _originalProductList;
  List<Product> _productList;
  ScrollController _scrollController;
  String _baseUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _category = "";
    _scrollController = new ScrollController();
    _baseUrl = "http://10.0.2.2:3000/";
    _getShopId();
  }

  void _getShopId() async{
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString('shop_id');
    _getParameterProducts();
  }

  void _getParameterProducts() async {
    String url;
    if(_parameter=="trending"){
       url = _baseUrl+"productview/shop/"+_shopId+"/trending";
    }
    else if(_parameter=="customerBag"){
      url= _baseUrl+"bag/shop/"+_shopId;
    }

    var response = await http.get(url);

    var data = await jsonDecode(response.body);

    if(data['error']!=null){
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['message']=="No trending products"){
      Toast.show("No trending products",context,duration : Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['message']=="No bagged products"){
      Toast.show("No bagged products",context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
     List<Product> productList = new List();
     var result;
     if(_parameter=="trending"){
       result = data['trendingProducts'];
     }
     else if(_parameter=="customerBag"){
       result = data['baggedProducts'];
     }

     for(var d in result){
       var p = d['product'];
       Product product = new Product(p['_id'],p['name'],p['category'],p['typeOfProduct'],p['price'],p['negotiable'],p['color'],p['size'],p['description'],DateTime.parse(p['date']),p['productImages'],p['views'],d['count']);
       productList.add(product);
     }
     _originalProductList = productList;
     setState(() {
       _productList=productList;
     });
    }
  }

  void _filterProduct(List<Product> unfilteredList){
    unfilteredList = unfilteredList.where((x)=>x.category.toLowerCase()==_category.toLowerCase()).toList();
    if(unfilteredList.length<1){
      Toast.show("No product found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{
      setState(() {
        _productList=unfilteredList;
      });
    }
  }

  void _deleteProduct(int position) async{

    debugPrint(_productList[position].productId+"");
    String url = _baseUrl+"product/"+_productList[position].productId;
    var result = await http.delete(url);

    var data = jsonDecode(result.body);

    if(data['message']=="Product not found"){
      Toast.show("Product not found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else if(data['error']!=null){
      Toast.show("Some error occured try again", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
    else{

      Toast.show("Product Deleted", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);

      setState(() {
        _productList.removeAt(position);
      });

    }
  }

  void _deleteProductAlertDialog(int position) async{
    AlertDialog _alertDialog = AlertDialog(
      title: Text("Delete Product"),
      content: Text("Do you want to delete?"),
      actions: <Widget>[

        RaisedButton(
          child: Text("Delete",style: TextStyle(color: Colors.white),),
          onPressed: (){
            _deleteProduct(position);
            Navigator.of(context).pop();
          },
        ),

        FlatButton(
          child: Text("Cancel"),
          onPressed: (){
            Navigator.of(context).pop();
          },
        )
      ],

    );

    showDialog(context: context,builder: (context){
      return _alertDialog;
    });
  }

  void _gotoUpdateProduct(Product product) async{
    final val = await Navigator.of(context).pushNamed('/updateProduct',arguments: product);
    if(val!=null){
      _getParameterProducts();
    }
  }

  Widget _buildColumnAllElements(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
      _buildCategoryRow(),

      SizedBox(
        height: 10.0,
      ),

      (_productList!=null && _productList.length!=0)
          ? _buildProductGridView()
          : Expanded(
          child:Text("No "+ _category+ " Products")
      )
      ],
    );
  }

  Widget _buildCategoryRow(){
    return Row(
      children: <Widget>[

        Expanded(
            child : Container(
              width: 85.0,
              height: 25.0,
              child: RaisedButton(
                color: (_category=="")
                    ?Colors.blueGrey
                    :Colors.grey,
                child: Text("All",style: TextStyle(fontSize: 13.0),),
                onPressed: (){
                  if(_category!="") {
                    _category = "";
                    setState(() {
                      _productList=_originalProductList;
                    });
                  }
                  _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                },
              ),
            )
        ),


        SizedBox(
          width: 5.0,
        ),

        Expanded(
            child : Container(
              width: 85.0,
              height: 25.0,
              child: RaisedButton(
                color: (_category=="female")
                    ?Colors.blueGrey
                    :Colors.grey,
                child: Text("Female",style: TextStyle(fontSize: 13.0),),

                onPressed: (){
                  if(_category!="female") {
                    _category = "female";
                    _filterProduct(_originalProductList);
                  }
                  _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                },
              ),
            )
        ),


        SizedBox(
          width: 5.0,
        ),

        Expanded(
            child: Container(
              width: 85.0,
              height: 25.0,
              child: RaisedButton(
                color: (_category=="male")
                    ?Colors.blueGrey
                    :Colors.grey,
                child: Text("Male",style: TextStyle(fontSize: 13.0),),
                onPressed: (){
                  if(_category!="male") {
                    _category = "male";
                    _filterProduct(_originalProductList);
                  }
                  _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                },
              ),
            )
        ),


        SizedBox(
          width: 5.0,
        ),

        Expanded(
            child: Container(
              width: 85.0,
              height: 25.0,
              child: RaisedButton(
                color: (_category=="unisex")
                    ?Colors.blueGrey
                    :Colors.grey,
                child: Text("Unisex",style: TextStyle(fontSize: 13.0),),
                onPressed: (){
                  if(_category!="unisex") {
                    _category = "unisex";
                    _filterProduct(_originalProductList);
                  }
                  _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                },
              ),
            )
        ),

        SizedBox(
          width: 5.0,
        ),

        Expanded(
            child: Container(
              width: 85.0,
              height: 25.0,
              child: RaisedButton(
                color: (_category=="kids")
                    ?Colors.blueGrey
                    :Colors.grey,
                child: Text("Kids",style: TextStyle(fontSize: 13.0),),
                onPressed: (){
                  if(_category!="kids") {
                    _category = "kids";
                    _filterProduct(_originalProductList);
                  }
                  _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                },
              ),
            )
        ),
      ],
    );
  }

  Widget _buildProductGridView(){
    return Expanded(
      child: GridView.builder(
          controller: _scrollController,
          itemCount: _productList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 2.0,crossAxisSpacing: 2.0,childAspectRatio: MediaQuery.of(context).size.height / 1000),
          itemBuilder: (context,position){
            return _buildSingleProduct(position);
          }),
    );
  }

  Widget _buildSingleProduct(int position){
    return GestureDetector(
      onTap: (){
        _gotoUpdateProduct(_productList[position]);
      },
      onLongPress: (){
        _deleteProductAlertDialog(position);
      },
      child:  Card(
        elevation: 5.0,
        child: GridTile(
            header: Column(
              children: <Widget>[
                Text(_productList[position].name,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold ),),

                Visibility(
                  visible: (_parameter=="popular" || _parameter=="customerBag"),
                  child: SizedBox(
                    height: 5.0,
                  ),
                ),

                Visibility(
                  visible: (_parameter=="popular"),
                  child: Text("Views " + _productList[position].views.toString(),style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold ),),
                ),

                Visibility(
                  visible: (_parameter=="customerBag"),
                  child: Text("Bagged " + _productList[position].bagged.toString(),style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold ),),
                )


              ],
            ) ,

            child: Column(
              children: <Widget>[
                Container(
                  height: 200.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(_baseUrl+"uploads/"+_productList[position].productImages[0].toString().split("\\")[1]),
                          fit: BoxFit.fill

                      )
                  ),
                ),


              ],
            )

        ) ,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: (_parameter=="trending")
               ? Text("Trending products")
               : Text("Bagged products"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildColumnAllElements(),
        ),
      )
    );
  }

}