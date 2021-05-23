import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, File imgFile}) sendMessage;
  TextComposer(this.sendMessage);


  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  // controlador que permite que outros widgets acessem o texto
  final TextEditingController _controller = TextEditingController();
  // se tem texto ou não
  bool _isComposing = false;

  //função que reseta o texto da mensagem
  void _reset(){
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          // icone que manda uma mensagem com imagem
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: ()async{
              File imgFile;
              final picker = ImagePicker();

              final pickedFile = await picker.getImage(source: ImageSource.camera);
              if(pickedFile != null){
                imgFile = File(pickedFile.path);
              }else{
                return;
              }
              widget.sendMessage(imgFile: imgFile);
            },
          ),
          // aqui se insere o texto, caso o usuário queira enviar mensagem de texto
          Expanded(
            child: TextField(
              // controlador que o texto é inserido
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: "Enviar uma mensagem."),
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                widget.sendMessage(text: text);
                _reset();
              },
            ),
          ),
          // botão que envia a mensagem, invocando a função send message
          IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing?(){
                widget.sendMessage(text: _controller.text);
                _reset();
              }:null
          )
        ],
      ),
    );
  }
}
