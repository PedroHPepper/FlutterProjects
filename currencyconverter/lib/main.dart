import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=b2e01e80";

void main() async {


  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar;
  double euro;

  void _realChanged(String text){
    if(text.isEmpty) {
      _resetField();
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text){
    if(text.isEmpty) {
      _resetField();
      return;
    }
    double dollar = double.parse(text);
    realController.text = (this.dollar*dollar).toStringAsFixed(2);
    euroController.text = ((this.dollar*dollar)/euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _resetField();
      return;
    }
    double euro = double.parse(text);
    realController.text = (this.euro*euro).toStringAsFixed(2);
    dollarController.text = ((this.euro*euro)/dollar).toStringAsFixed(2);
  }

  void _resetField(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      //Barra de cima do app
      appBar: AppBar(
        title: Text("Conversor de Moeda"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget> [
          IconButton(icon: Icon(Icons.refresh)
              , onPressed: _resetField)
        ],
      ),
      //Corpo com requisição assíncrona
      body: FutureBuilder<Map>(
        //faz a requisição na função
        future: getData(),
        //constrói o corpo da tela, que muda de estado para o outro
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            //se não houver resposta ou estiver esperando aparece "carregando dados na tela"
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              //se houver erro, dá uma tela de erro
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao carregar os dados",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }//se não houver erro, mostra a tela padrão do app
              else{
                //pega o desultado dos dados no snapshot e recupera os valores em dolar e euro
                dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                //retorna uma tela scrollavel
                return SingleChildScrollView(
                  //coluna principal do app
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    //lista de filhos
                    children: <Widget>[
                      //ícone em cifrão
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber,),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$", dollarController, _dollarChanged),
                      Divider(),
                      buildTextField("Euros", "€\$", dollarController, _euroChanged),
                    ],
                  )
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
 return TextField(
   controller: c,
   decoration: InputDecoration(
       labelText: label,
       labelStyle: TextStyle(color: Colors.amber),
       border: OutlineInputBorder(),
       prefixText: prefix
   ),
   style: TextStyle(color: Colors.amber, fontSize: 25.0),
   onChanged: f,
   keyboardType: TextInputType.number,
 );
}
