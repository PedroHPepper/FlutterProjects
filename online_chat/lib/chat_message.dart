import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  // atributos da classe:
  // Mapa dos dados de cada mensagem individual que vão ser preenchidos pela classe chat screen
  final Map<String, dynamic> data;
  // mine, que representa
  final bool mine;

  // aqui insere uma mensagem individual, juntamente com um bool que diz se ela é do usuário ou não
  ChatMessage(this.data, this.mine);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          // se a mensagem não for do usuário o ícone é mostrado do lado esquerdo
          !mine ?
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ): Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                // se for imagem, é carregado uma Image.network e se for texto, é carregado um text
                data["imgUrl"] != null ?
                    Image.network(data["imgUrl"], width: 250,)
                :
                    Text(
                      data["text"],
                      // se a mensagem for do usuário a mensagem aparece do lado direito
                      textAlign: mine ? TextAlign.end : TextAlign.start,
                      style: TextStyle(
                          fontSize: 16
                      ),
                    ),
                // informação do nome da pessoa que mandou
                Text(
                  data["sender"],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            )
          ),
          // se a mensagem for do usuário o ícone é mostrado do lado direito
          mine ?
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ): Container()
        ],
      )
    );
  }
}
