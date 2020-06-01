import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectx_shop_app/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ViewProduct extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewProductState();
  }
}

class _ViewProductState extends State<ViewProduct>{

  GlobalKey<ScaffoldState> _viewProductScaffoldKey;
  String _shopId;
  List<Product> _productList;
  List<Product> _originalProductList;
  List<Product> _searchResultList;
  Widget _appBarTitle;
  Icon _actionIcon;
  String _sortProductCondition;
  ScrollController _scrollController;
  TextEditingController _searchController;
  List<String> _sortProductList;
  List<String> _filterProductList;
  List<String> _filterProductListCopy;
  int _filterCount;
  String _baseUrl;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _viewProductScaffoldKey = new GlobalKey<ScaffoldState>();

    _appBarTitle = Text("Your Products");
    _actionIcon = Icon(Icons.search,color: Colors.white,);

    _sortProductList = ['new','old','popular','lowest to highest price','highest to lowest price'];
    _sortProductCondition = "new";

    _scrollController = new ScrollController();

    _searchController = new TextEditingController();

    _filterProductList = ['','','',''];
    _filterCount=0;

    _baseUrl = "http://10.0.2.2:3000/";

    _getShopId();

  }

  void _getShopId() async{
    final prefs = await SharedPreferences.getInstance();
    _shopId = await prefs.get('shop_id');
    _getProducts();
}

  void _getProducts() async{

    String url = _baseUrl+"shop/"+_shopId+"/product/";

    var result = await http.get(url);

    var data = jsonDecode(result.body);

    debugPrint("data $data");

    if(data['message']=='Shop doesnt exists'){
      SnackBar _snackBar = SnackBar(
          content: Text("Shop doesnt exists"));
      _viewProductScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['error'] !=null){
      SnackBar _snackBar = SnackBar(
          content: Text("Some error occured try again"));
      _viewProductScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else{
      List<Product> productList = List<Product>();
      for(var d in data['products']){
        Product product = Product(d['_id'], d['name'], d['category'], d['typeOfProduct'],d['price'], d['negotiable'], d['color'], d['size'],d['description'],DateTime.parse(d['date']), d['productImages'],d['views'],d['bagged']);
        productList.add(product);
      }

      this._originalProductList = productList;

      setState(() {
        this._productList = productList;
      });
    }
  }

  void _deleteProduct(int position) async{

    debugPrint(_productList[position].productId+"");
    String url = _baseUrl+"product/"+_productList[position].productId;
    var result = await http.delete(url);

    var data = jsonDecode(result.body);

    if(data['message']=="Product not found"){
      SnackBar _snackBar = SnackBar(
          content: Text("Product not found"));
      _viewProductScaffoldKey.currentState.showSnackBar(_snackBar);
    }
    else if(data['error']!=null){
      SnackBar _snackBar = SnackBar(
          content: Text("Some error occured try again"));
      _viewProductScaffoldKey.currentState.showSnackBar(_snackBar);
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

  void _searchProduct(){
    String searchItem = _searchController.text.trim().toLowerCase();
    _searchResultList = _originalProductList.where((x)=>x.name.toLowerCase().contains(searchItem) || x.category.toLowerCase()==searchItem || x.typeOfProduct.toLowerCase().contains(searchItem)).toList();
    if(_searchResultList.length<1){
      _searchResultList = _productList;
      Toast.show("No Products found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      debugPrint("product list : " + _productList.length.toString());
    }else{
//      _productList = searchResultList;
      _filterProduct(_searchResultList);
    }
  }

  void _filterProduct(List<Product> unfilteredList){
    if(_filterCount!=0){
      if(_filterProductList[0]!=''){
        debugPrint("Filter category");
       unfilteredList = unfilteredList.where((x)=>x.category.toLowerCase()==_filterProductList[0].toLowerCase()).toList();
      }
       if(_filterProductList[1]!=''){
         debugPrint("Filter type of product");
       unfilteredList = unfilteredList.where((x)=>x.typeOfProduct.toLowerCase().contains(_filterProductList[1].toLowerCase())).toList();
      }
       if(_filterProductList[2]!=''){
         debugPrint("Filter color");
       unfilteredList = unfilteredList.where((x)=>x.color.toLowerCase().contains(_filterProductList[2].toLowerCase())).toList();
      }
       if(_filterProductList[3]!=''){
         debugPrint("Filter size");
       unfilteredList = unfilteredList.where((x)=>x.size.toLowerCase().contains(_filterProductList[3].toLowerCase())).toList();
      }
    }
    _sortProduct(unfilteredList);
  }

  void _sortProduct(List<Product> unsortedList){
    if(_sortProductCondition=="new"){
      unsortedList.sort((b,a)=> a.date.compareTo(b.date));
    }
    else if (_sortProductCondition=="old"){
      unsortedList.sort((a,b)=> a.date.compareTo(b.date));
    }
    else if(_sortProductCondition=="popular"){
      unsortedList.sort((b,a)=>a.views.compareTo(b.views));
    }
    else if(_sortProductCondition=="lowest to highest price"){
      unsortedList.sort((a,b)=>a.price.compareTo(b.price));
    }
    else if(_sortProductCondition=="highest to lowest price"){
      unsortedList.sort((b,a)=>a.price.compareTo(b.price));
    }
    if(unsortedList.length<1){
      Toast.show("No product found", context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }else{
      _productList=unsortedList;
    }
  }



  void _sortAlertDialog(BuildContext context) async{

    AlertDialog alertDialog = AlertDialog(
      title: Text("Sort"),
      content: ListView.builder(
          itemCount: _sortProductList.length,
          itemBuilder: (context,position){
            return GestureDetector(
              child: ListTile(
                title: (_sortProductCondition.contains(_sortProductList[position]))
                    ? Text(_sortProductList[position],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)
                    : Text(_sortProductList[position]),
              ),
              onTap: (){
                setState(() {
                  _sortProductCondition= _sortProductList[position];
                });
//                _searchProduct();
                _sortProduct(_productList);
                Navigator.of(context).pop();
              },
            );

          }),

    );

    showDialog(
        context: context,
        builder: (context){
          return alertDialog;
        });
  }

  void _gotoFilter() async{
    _filterProductListCopy = List<String>.generate(_filterProductList.length,(i)=> _filterProductList[i]);
    var result = await Navigator.of(context).pushNamed('/productFilter',arguments: _filterProductListCopy);
    if(result!=null) {
      if(result=="remove"){

        _filterProductList=['','','',''];
//        _searchProduct();
        setState(() {
          _filterCount = 0;
        });
        if(_searchController.text==''){
          _sortProduct(_originalProductList);
        }
        else{
          _sortProduct(_searchResultList);
        }
      }
      else {
//          ProductArg productArg = result;
        _filterProductList=_filterProductListCopy;
        int count = 0;
        for(int i=0;i<_filterProductList.length;i++){
          if(_filterProductList[i]!=""){
            count++;
          }

        }
        setState(() {
          _filterCount=count;
        });
//        _searchProduct();
        if(_searchController.text==''){
          _filterProduct(_originalProductList);
        }
        else{
          _filterProduct(_searchResultList);
        }

      }

    }
  }

  void _gotoUpdateProduct(int position) async{
    final val = await Navigator.of(context).pushNamed('/updateProduct',arguments: _productList[position]);
    if(val!=null){
       _getProducts();
       _filterProductList=['','','',''];
       _filterCount=0;
       _sortProductCondition="new";
    }
  }

  Widget _buildColumnAllElements(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildProductGridView(),
        _buildFilterSortButtonRow()
      ],
    );
  }

  Widget _buildProductGridView(){
    return  Expanded(
      child:   GridView.builder(
        controller: _scrollController,
        itemCount: _productList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 2.0,crossAxisSpacing: 2.0),
        itemBuilder: (context,position) {
          return _buildSingleProduct(position);
        }
        )
    );
  }

  Widget _buildSingleProduct(int position){
    return GestureDetector(

      onTap: (){
        _gotoUpdateProduct(position);
      },
      onLongPress: (){
        _deleteProductAlertDialog(position);
      },
      child:  Card(
        elevation: 5.0,
        child: GridTile(
            header: Text(_productList[position].name,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold ),),
            child: Container(
              height: 300.0,
              width: 200.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(_baseUrl+"uploads/" + _productList[position].productImages[0].toString().split('\\')[1]),
                      fit: BoxFit.fill

                  )
              ),
            )) ,
      ),
    );
  }

  Widget _buildFilterSortButtonRow(){
    return  Align(
        alignment: Alignment.bottomCenter,
        child : Row(
            children: <Widget>[
              Expanded(
                  child:FlatButton(
                    color: Colors.blue,
                    child: Text("Sort"),
                    onPressed: (){
                      _sortAlertDialog(context);
                    },)
              ),

              SizedBox(
                width: 2.0,
              ),

              Stack(
                children: <Widget>[
                  Container(
                    width: 180.0,
                    height: 36.0,
                    child:  RaisedButton(
                      child: Text("Filter"),
                      onPressed: (){
                        _gotoFilter();
                      },
                    ) ,
                  )
                  ,
                  (_filterCount!=0)
                      ? Positioned(
                      top: 2.0,
                      right: 2.0,
                      child:  Container(
                        decoration:  BoxDecoration(
                            borderRadius:  BorderRadius.circular(10.0),
                            color: Colors.red),
                        width: 25.0,
                        child: Center(
                          child: Text(
                            _filterCount.toString(),
                            style:  TextStyle(color: Colors.white,fontSize: 18.0),
                          ),
                        ) ,
                      ))
                      : SizedBox(

                  )
                ],
              )
            ])
    );
  }

  Widget _appBarSearchAction(){
    return IconButton(
      icon: _actionIcon,
      onPressed: (){
        setState(() {
          if(_actionIcon.icon==Icons.search){
            _actionIcon = Icon(Icons.close);
            _appBarTitle = TextField(
              autofocus: true,
              style: TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,color: Colors.white,),
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.white)
              ),

              controller: _searchController,

              onSubmitted: (String item){
                _searchProduct();
              },
            );
          }
          else{
            _actionIcon = Icon(Icons.search,color: Colors.white,);
            _appBarTitle = Text("Search",style: TextStyle(color: Colors.white),);
            _searchController.text="";
//                  _searchProduct();
//                  _getProducts();
//                  _sortProductCondition="new";
            _productList=_originalProductList;
            _filterProduct(_productList);
          }
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _viewProductScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: _appBarTitle,
        actions: <Widget>[
          _appBarSearchAction()
        ],
      ),

      body: Center(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: (_productList==null || _productList.length==0)
                ? Text("No Product Available")
                : _buildColumnAllElements()
        ),
      )
    );
  }
}