import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {

  // logica
  final Map _gifData; // dados do gif que estou mostrando

  GifPage(this._gifData); //passo os dados do gifData para o construtor GifPage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gifData['title']),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: (){
              Share.share(_gifData['images']['fixed_height']['url']);
            }
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(_gifData['images']['fixed_height']['url']),
      ),
    );
  }
}