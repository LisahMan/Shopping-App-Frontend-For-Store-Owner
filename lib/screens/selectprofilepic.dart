import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:toast/toast.dart';

class SelectProfilePic extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SelectProfilePicState();
  }
}

class _SelectProfilePicState extends State<SelectProfilePic>{

  File _image;
  bool _sendVisibility;

  @override
  void initState() {
    // TODO: implement initState
    _sendVisibility = false;

    super.initState();
  }

  void _getImageCamera() async{
    
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    _imageSelected(image);
}

void _getImageGallery() async{

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _imageSelected(image);
}

void _imageSelected(File image) async{
  if(image!=null){
    String basename = extension(image.path);
    if(basename==".jpeg" || basename==".jpg" || basename==".png"){
      int size = await image.length();
      debugPrint("imagesize : $size" );
      if(size<=1024*1024*5){
        setState(() {
          _image = image;
          _sendVisibility = true;
        });
      }
      else{
        Toast.show("Please select an image of size 5 MB or less",this.context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
      }

    }
    else{
      Toast.show("Please select jpeg or png image",this.context,duration: Toast.LENGTH_SHORT,gravity: Toast.BOTTOM);
    }
  }
}

  Widget _buildListViewAllElements(BuildContext context){
    return ListView(
      children: <Widget>[
        
        _buildOptionButtonRow(),

      SizedBox(
        height: 20.0,
      ),

      _buildShowImage(),
        
        SizedBox(
          height: 20.0
      ),
        
        _buildDoneButton(context)
      ],
    );
  }

  Widget _buildOptionButtonRow(){
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            width: 150.0,
            height: 40.0,

            child: RaisedButton(
                child: Text("Camera",style: TextStyle(fontSize: 25.0,color: Colors.white),),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                color: Colors.red,
                onPressed: (){
                  _getImageCamera();
                }),
          ),
        ),

        SizedBox(
          width: 5.0,
        ),

        Expanded(
          child: Container(
            width: 150.0,
            height: 40.0,

            child: RaisedButton(
              child: Text("Gallery",style: TextStyle(fontSize: 25.0,color: Colors.white),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              color: Colors.blue,
              onPressed: (){
                _getImageGallery();
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildShowImage(){
    return (_image==null)
        ? Text("No Image Selected",style: TextStyle(fontSize: 25.0),)
        : Container(
      width: 500.0,
      height: 300.0,
      child: Image.file(_image),

    );
  }

  Widget _buildDoneButton(BuildContext context){
    return  Visibility(
      visible: (_sendVisibility)
          ? true
          : false,

      child: Container(
        width: 200.0,
        height: 50.0,

        child: RaisedButton(
            child: Text("Set Shop Picture",style: TextStyle(fontSize: 25.0,color: Colors.white),),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
            color: Theme.of(context).primaryColor,
            onPressed: (){
              Navigator.pop(context,_image);
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Select Shop Picture"),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _buildListViewAllElements(context),
        ),
      )
    );
  }
}