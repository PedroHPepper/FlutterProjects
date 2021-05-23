import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_chat/text_composer.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // representa o atributo em que o usuário vai ser inserido
  FirebaseUser _currentUser;
  bool _isLoadinImage = false;

  @override
  void initState() {
    // Inicia o estado com um setState quando o estado da autenticação for mudada.
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  //Resgata o usuário do firebase, caso o usuário não esteja logado. Se já estiver, ele retorna o currentUser
  Future<FirebaseUser> _getUser()async{
    if(_currentUser != null) return _currentUser;
    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    }catch(error){
      return null;
    }
  }

  //Função de enviar a mensagem
  void _sendMessage({String text, File imgFile})async{
    //resgata o usuário
    final FirebaseUser user = await _getUser();
    //se der pau, aparece essa frase de erro
    if(user == null){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Não foi possível fazer o login. Tente novamente!"),
        backgroundColor: Colors.red,
        )
      );
    }

    //mapa que estrutura os dados da mensagem
    Map<String, dynamic> data = {
      "uid": user.uid,
      "sender": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time" : Timestamp.now()
    };

    //se o usuário enviou uma imagem, aqui é feito o storage no banco
    if(imgFile != null){
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
        user.uid + DateTime.now().microsecondsSinceEpoch.toString()
      ).putFile(imgFile);

      //reinicia o estado dizendo que está carregando a imagem
      setState(() {
        _isLoadinImage = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;
      //reinicia o estado dizendo que deixou de carregar a imagem
      setState(() {
        _isLoadinImage = false;
      });
    }

    //se for mensagem de texto, é atribuído ele à mensagem
    if(text != null) data["text"] = text;

    //insere a mensagem no banco de dados
    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            _currentUser != null ? "Olá, ${_currentUser.displayName}" : "Chat App"
        ),
        elevation: 0,
        actions: <Widget>[
          _currentUser != null ? IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
              _scaffoldKey.currentState.showSnackBar(
                  SnackBar(content: Text("Você saiu com sucesso!"),
                  )
              );
            }
          ) : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //stream verifica quando as informações vão sendo mudadas no banco de dados
              stream: Firestore.instance.collection("messages").orderBy("time").snapshots(),
              //insere o contexto juntamente com o snapshot no builder
              builder: (context, snapshot){
                //se tiver carregando, aparece um círculo de progresso
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  //se estiver pronto, lista as mensagens retornando um chat message
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index){
                        // insere um item dos dados pelo indice juntamente com uma verificação se
                        // a mensagem pertence ao usuário ou não
                        return ChatMessage(
                            documents[index].data,
                            documents[index].data["uid"] == _currentUser?.uid
                        );
                        /*return ListTile(
                          title: Text(documents[index].data["text"]),
                        );*/
                      }
                    );
                }
              },
            ),
          ),
          //se a imagem tiver carregando vai aparecer uma barrinha de carregamento acima da barra de escrever
          _isLoadinImage ? LinearProgressIndicator() : Container(),

          // Aqui é invocado a classe text composer definindo a função send message que ela necessita no construtor
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
