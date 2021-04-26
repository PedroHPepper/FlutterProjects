import 'dart:io';

import 'package:contact_book/helper/contact_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
enum OrderOptions {orderaz, orderza}

class ContactPage extends StatefulWidget {
  final Contact contact;

  //parametro this.contact é opcional. Por isso as chaves
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //aqui são os controladores dos textos dos inputs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  //variável que vai conter os dados dos contatos
  Contact _editedContact;
  //se o user editou ou não
  bool _userEdited = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //se eu não passar nenhum contato pra classe, ele cria uma instancia pra _editedContact,
    //se não ele recebe o contact da classe acima
    if(widget.contact == null){
      _editedContact = Contact();
    }else{
      //se houver um contato ele é inserido na variavel edited controller
      _editedContact = Contact.fromMap(widget.contact.toMap());
      //depois é atribuído as informações nos controladores dos inputs textfield
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedContact.name == null || _editedContact.name.isEmpty){
              FocusScope.of(context).requestFocus(_nameFocus);
              return;
            }
            if(_editedContact.phone == null || _editedContact.phone.isEmpty){
              FocusScope.of(context).requestFocus(_phoneFocus);
              return;
            }
            Navigator.pop(context, _editedContact);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null ?
                          FileImage(File(_editedContact.img)) : AssetImage("images/person.png"),
                          fit: BoxFit.cover
                      )
                  ),
                ),
                onTap: (){
                  //espera chamar a camera e vc tirar a foto, e daí sim com o then pega a foto
                  ImagePicker().getImage(source: ImageSource.camera).then((file) {
                    if(file == null){
                      return;
                    }
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
      onWillPop: _requestPop
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar Alterações?"),
            content: Text("Se sair, as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(onPressed: (){
                Navigator.pop(context);
              },
                  child: Text("Cancelar")
              ),
              FlatButton(onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              },
                  child: Text("SIM")
              )
            ],
          );
        }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

}
