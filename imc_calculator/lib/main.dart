import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(
    home: Home()
  ));
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController weightController = new TextEditingController();
  TextEditingController heightController = new TextEditingController();

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String infoText = "Informe seus dados!";
  void _resetField(){
    weightController.text = "";
    heightController.text = "";
    setState(() {
      infoText = "Informe seus dados!";
    });
  }
  void _calculateIMC(){
    setState(() {
      double weight = double.parse(weightController.text);
      double height = double.parse(heightController.text)/100;

      double imc = weight / (height*height);
      if(imc < 18.6){
        infoText = "Abaixo do Peso! IMC${imc.toStringAsPrecision(3)}";
      }else if(imc >= 18.6 && imc < 24.9){
        infoText = "Está no peso ideal! IMC:${imc.toStringAsPrecision(3)}";
      }else if(imc >= 24.9 && imc < 29.9){
        infoText = "Levemente acima do peso! IMC:${imc.toStringAsPrecision(3)}";
      }else if(imc >= 29.9 && imc < 34.9){
        infoText = "Obesidade Grau I! IMC:${imc.toStringAsPrecision(3)}";
      }else if(imc >= 34.9 && imc < 39.9){
        infoText = "Obesidade Grau II! IMC:${imc.toStringAsPrecision(3)}";
      }else if(imc >= 40){
        infoText = "Obesidade Grau III! IMC:${imc.toStringAsPrecision(3)}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: <Widget> [
          IconButton(icon: Icon(Icons.refresh)
              , onPressed: _resetField)
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Form(
          key: _formKey,
            //Contem toda a coluna com a figura, os formularios e botões
            child: Column(
              //Centralizador da coluna
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget> [
                //Figura do usuário
                Icon(Icons.person_outline, size: 120, color: Colors.teal),
                //Campo de peso
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "Peso (kg)",
                      labelStyle: TextStyle(color: Colors.teal)
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.teal, fontSize: 25.0),
                  controller: weightController,
                  validator: (value){
                    if(value.isEmpty){
                      return "Insira seu peso!";
                    }
                  },
                ),
                //Campo da altura
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "Altura (cm)",
                      labelStyle: TextStyle(color: Colors.teal)
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.teal, fontSize: 25.0),
                  controller: heightController,
                  validator: (value){
                    if(value.isEmpty){
                      return "Insira sua altura!";
                    }
                  },
                ),
                //Botão de calcular dentro de um container
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                      height: 50.0,
                      //botão propriamente dito
                      child: RaisedButton(
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            _calculateIMC();
                          }
                        },
                        child: Text(
                            "Calcular",
                            style: TextStyle(color: Colors.white, fontSize: 25.0)
                        ),
                        color: Colors.teal,
                      )
                  ),
                ),
                Text(infoText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.teal, fontSize: 25.0),
                )
              ],
            )
        )
      )
    );
  }
}
