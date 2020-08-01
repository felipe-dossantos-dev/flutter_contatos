import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "id";
final String nameColumn = "name";
final String emailColumn = "email";
final String phoneColumn = "phone";
final String imageColumn = "image";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db
            .execute("CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY,"
                "$nameColumn TEXT,"
                "$emailColumn TEXT,"
                "$phoneColumn TEXT,"
                "$imageColumn TEXT)");
      },
    );
  }

  saveContact(Contact contact) async {
    Database contactDatabase = await db;
    contact.id = await contactDatabase.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database contactDatabase = await db;
    List<Map> maps = await contactDatabase.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps[0]);
    }
    return null;
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image
    };
    if (id != null) map[idColumn] = id;
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, email: $email, phone: $phone, image: $image)";
  }
}
