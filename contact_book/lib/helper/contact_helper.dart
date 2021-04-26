import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//aqui é o nome da tabela de contatos do banco de dados
final String contactTable = "contactTable";
//aqui são as strings com o nome de cada coluna do banco de dados
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper{
  //instancia singleton em que a classe instancia ela mesma.
  //mesmo se instanciar essa classe duas vezes, os dois objetos serão os mesmos com as mesmas definições
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;

  ContactHelper.internal();

  //Variável principal do banco de dados
  Database _db;
  //faz o GET do banco de dados. Se não estiver iniciado, o método já inicia o db
  Future<Database> get db async{
    if(_db == null){
      _db = await initDb();
    }
    return _db;
  }

  //Método que inicia o db. Ele é chamado pelo metodo acima
  Future<Database> initDb() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contact.db");
    
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion)async{
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  //Salva um contato
  Future<Contact> saveContact(Contact contact) async{
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }
  //Acha um contato no banco de dados utilizando uma id. Se não achar, retorna null
  Future<Contact> getContact(int id) async{
    Database dbContact = await db;

    //a forma em que o dart ta trabalhando nesse caso pra modelar dados é usando mapas.
    //aqui se faz uma lista de mapas contendo todas as colunas dos itens, filtrando aqueles que tiverem a id
    List<Map> maps = await dbContact.query(contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id]
    );

    //aqui retorna um mapa de um item da tabela de contatos, que contem a id em questão
    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    }else{
      return null;
    }
  }

  //deleta o contato
  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable,
        where: "$idColumn = ?",
        whereArgs: [id]
    );
  }

  //Atualiza o contato
  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contactTable,
        contact.toMap(),
        where: "$idColumn = ?",
        whereArgs: [contact.id]
    );
  }

  //resgata uma lista de todos os contatos
  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> contactList = List();
    for(Map map in listMap){
      contactList.add(Contact.fromMap(map));
    }
    return contactList;
  }

  //retorna a quantidade de contatos da tabela
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //fecha o banco de dados
  closeDatabase() async{
    Database dbContact = await db;
    dbContact.close();
  }
}

//classe de contato
class Contact{
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();
  //****organizado o objeto usando mapeamento, pois o sqflite usa assim
  //aqui é criado um mapa no formato de contato usando um mapa do tipo genérico
  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  //retorna o objeto mapeado
  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  //retorna uma cadeia de string com os dados do contato
  @override
  String toString(){
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}