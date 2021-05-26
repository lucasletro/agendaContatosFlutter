import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColmn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";


class ContactHelper { //essa classe não vai poder ter varias instancias ao longo do seu codigo- padrão singleton(quer ter apenas um objeto da sua classe).

  static final ContactHelper _instance = ContactHelper.internal();                 //ContactHelper.internal = construtor interno

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    } else{
      _db = await initDb();
      return _db;
    }
  }
//FUNÇAO PARA INICIAR O BANCO DE DADOS.
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();   //local do meu banco de daods.
    final path = join(databasesPath, "contactsnew.db");  //arquivo que vai estar armazenado eu banco de dados.
    print(path);
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {  //abrir banco de dados
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {     //salvar contato.
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {        //oter informaçoes de um contato.
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn ],
      where: "$idColumn = ?",
      whereArgs: [id]);
    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    }else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {   //deletar um contato.
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]); //deletar um contato da minha tabela de contatos onde o id da coluna é igual ao id que passei.
  }

  Future<int> updateContact(Contact contact) async {    //atualizar um contato.
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List>getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }
  
  Future<int> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }

}

class Contact {              //essa classe vai definir tudo que eu contato vai armazenar.

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map){                             //Aqui eu peguei os dados de um mapa e passei pro meu contato. pegar do banco de dados.
    id = map[idColumn];
    name = map[nameColumn];
    email =  map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {                                  //Aqui eu vou pegar o meu contato e transformar em um mapa.salvar no banco de dados.
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}