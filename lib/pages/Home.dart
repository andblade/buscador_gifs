import 'dart:convert';
import 'package:buscador_gifs/pages/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  // logica
  // quando a requisição se faz atravez da intenet se torna asyncronna

  String _pesquisa;
  int _offSet = 0;

  Future<Map> _getGifs() async {
     http.Response resposta;

      if(_pesquisa == null || _pesquisa == '')
        resposta = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=je9XykIovOpi92mdzbXXHro8DhLtMw4y&limit=20&rating=g');
      else
        resposta = await http.get('https://api.giphy.com/v1/gifs/search?api_key=je9XykIovOpi92mdzbXXHro8DhLtMw4y&q=$_pesquisa&limit=19&offset=$_offSet&rating=g&lang=pt');

      // o retorno da requisição é em json (ler documentação da API)
      return json.decode(resposta.body);
  }

  // teste pra ver se a logica deu certo
  @override
  void initState() {
    super.initState();

    _getGifs().then((map) => print(map));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui!",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize:18),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _pesquisa = text;
                  _offSet = 0; // começa do zero o carregamento dos gif
                });
              },
            ),
          ),
        
          Expanded( // expande toda a tela quando nao tem altura definida
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){ 
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    // animação de carregmento
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );

                  default:
                    if (snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot);
                }
              },
            ),
          ),
        ],

      ),
    );
  }

  int _getCount(List data){
    if(_pesquisa == null) return data.length;
    else return data.length + 1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index){
        if (_pesquisa == null || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300.0,
              fit: BoxFit.cover
            ),
            onTap: (){
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => GifPage(snapshot.data['data'][index]))
              );
            },
            onLongPress: (){
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color:Colors.white, size: 70),
                  Text("Carregar mais...", style: TextStyle(color: Colors.white, fontSize: 22),)
                ],
              ),
              onTap: (){
                setState(() {
                  _offSet += 19;
                });
              },
            ),
          );
        }
      }
    );
  }
  
}