class Shop{
  String _shopId;
  String _shopOwnerId;
  String _name;
  String _district;
  String _location;
  String _phoneNumber;
  String _shopPic;
  String _description;
  String _date;

  Shop(this._shopId,this._shopOwnerId,this._name,this._district,this._location,this._phoneNumber,this._shopPic,this._description,this._date);

  String get shopId=> this._shopId;
  String get shopOwnerId=> this._shopOwnerId;
  String get name=> this._name;
  String get district=> this._district;
  String get location=> this._location;
  String get phoneNumber=> this._phoneNumber;
  String get shopPic=> this._shopPic;
  String get description=> this._description;
  String get date => this._date;

  void set shopId(String shopId){
    this._shopId=shopId;
  }

  void set shopOwnerId(String shopOwnerId){
    this._shopOwnerId = shopOwnerId;
  }

  void set name(String name){
    this._name = name;
  }

  void set district(String district){
    this._district = district;
  }

  void set location(String location){
    this._location = location;
  }

  void set phoneNumber(String phoneNumber){
    this._phoneNumber = phoneNumber;
  }

  void set shopPic(String shopPic){
    this._shopPic = shopPic;
  }

  void set description(String description){
    this._description = description;
  }

  void set date(String date){
    this._date = date;
  }


}