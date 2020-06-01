import 'package:flutter/material.dart';

class Start extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        body: Padding(
            padding: EdgeInsets.only(top: 200.0),
            child: Center(
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[

                      Text("Shop App",style: TextStyle(fontSize: 30.0,color: Colors.white),),

                      SizedBox(
                        height: 50.0,
                      ),

                      Container(
                        width: 300.0,
                        height: 50.0,
                        child: RaisedButton(
                          child: Text("Login",style: TextStyle(fontSize: 25.0,color: Colors.white),),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                          color: Colors.redAccent,
                          onPressed: (){
                            Navigator.of(context).pushNamed('/login');
                          },
                        ),
                      ),

                      SizedBox(
                        height: 15.0,
                      ),

                      Container(
                          width: 300.0,
                          height: 50.0,
                          child: RaisedButton(
                            child: Text("Sign Up",style: TextStyle(fontSize: 25.0,color: Colors.white),),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                            color: Theme.of(context).primaryColorLight,
                            onPressed: (){
                              Navigator.of(context).pushNamed('/signUp');
                            },
                          )
                      )


                    ],
                  )
              ),
            ),

        )
    );
  }
}