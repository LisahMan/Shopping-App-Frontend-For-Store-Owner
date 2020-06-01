import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:toast/toast.dart';

class AddProductImage extends StatefulWidget{
  AddProductImage(this._imageList);
  final List<File> _imageList;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddProductImageState(_imageList);
  }
}

class _AddProductImageState extends State<AddProductImage>{
  _AddProductImageState(this._imageList);
  List<File> _imageList;

  GlobalKey<ScaffoldState> _addProductImageScaffoldKey;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(_imageList==null){
      _imageList = new List();
    }
    _addProductImageScaffoldKey = new GlobalKey<ScaffoldState>();
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
            _imageList.add(image);
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

        _buildImageGridView(),

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
              child: Text("Camera",style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              color: Colors.red,
              onPressed: (){
                _getImageCamera();
              },
            ),
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
              child: Text("Gallery",style: TextStyle(color: Colors.white),),
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

  Widget _buildImageGridView(){
    return Container(
      child: (_imageList==null)
          ? Text("No Image Selected")
          : SizedBox(
        height: 375.0,
        child:    GridView.builder(
          itemCount: _imageList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 10.0,crossAxisSpacing: 10.0),
          itemBuilder: (context,position){
            return _buildSingleImage(position);
          },
        ),
      ),
    );
  }

  Widget _buildSingleImage(position){
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: FileImage(_imageList[position]),
              fit: BoxFit.fill
          ),
        ),

        child: Stack(
          children: <Widget>[
            Positioned(
                right: 0.0,
                top: 0.0,
                child: IconButton(
                    icon: Icon(Icons.delete,color: Colors.white70,),
                    onPressed: (){

                      setState(() {
                        _imageList.removeAt(position);

                      });
                    })),
          ],
        )
    );
  }

  Widget _buildDoneButton(BuildContext context){
    return  Container(
      width: 250.0,
      height: 50.0,

      child: RaisedButton(
          child: Text("Done",style: TextStyle(color: Colors.white),),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Theme.of(context).primaryColor,
          onPressed: (){
            if(_imageList==null){
              SnackBar _snackBar = SnackBar(content: Text("Please select a picture for your product"));
              _addProductImageScaffoldKey.currentState.showSnackBar(_snackBar);
            }
            else if(_imageList.length==0){
              SnackBar _snackBar = SnackBar(content: Text("Please select a picture for your product"));
              _addProductImageScaffoldKey.currentState.showSnackBar(_snackBar);
            }
            else if(_imageList.length>5){
              SnackBar _snackBar = SnackBar(content: Text("Maximum number of pictures is 5"));
              _addProductImageScaffoldKey.currentState.showSnackBar(_snackBar);
            }
            else {
              Navigator.of(context).pop(_imageList);
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

//    List<File> imageList = ModalRoute.of(context).settings.arguments;
//    debugPrint("ImageListSize $imageList");
//    if(imageList!=null){
//      if(imageList.length!=0) {
//        this._imageList = imageList;
//      }
//    }
    return Scaffold(
        key: _addProductImageScaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text("Select Product Images",style: TextStyle(color: Colors.white),),
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