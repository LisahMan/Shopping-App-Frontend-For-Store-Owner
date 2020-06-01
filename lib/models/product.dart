class Product{

  String _productId;
  String _name;
  String _category;
  String _typeOfProduct;
  int _price;
  bool _negotiable;
  String _color;
  String _size;
  String _description;
  DateTime _date;
  int _views;
  int _bagged;
  List<dynamic> _productImages;

  Product(this._productId,this._name,this._category,this._typeOfProduct,this._price,this._negotiable,this._color,this._size,this._description,this._date,this._productImages,this._views,this._bagged);

  String get productId => this._productId;
  String get name => this._name;
  String get category => this._category;
  String get typeOfProduct => this._typeOfProduct;
  int get price => this._price;
  bool get negotiable => this._negotiable;
  String get color => this._color;
  String get size => this._size;
  String get description => this._description;
  DateTime get date => this._date;
  List<dynamic> get productImages => this._productImages;
  int get views=>this._views;
  int get bagged=>this._bagged;

  set productId(String productId){
    this._productId = productId;
  }

  set name(String name){
    this._name = name;
  }

  set category(String category){
    this._category = category;
  }

  set typeOfProduct(String typeOfProduct){
    this._typeOfProduct = typeOfProduct;
  }

  set price(int price){
    this._price = price;
  }

  set negotiable(bool negotiable){
    this._negotiable = negotiable;
  }

  set color(String color){
    this._color = color;
  }

  set size(String size){
    this._size = size;
  }

  set description(String description){
    this._description = description;
  }

  set date(DateTime date){
    this._date = date;
  }

  set productImages(List<dynamic> productImages){
    this._productImages = productImages;
  }

  set views(int views){
    this._views=views;
  }

  set bagged(int bagged){
    this._bagged=bagged;
  }
}