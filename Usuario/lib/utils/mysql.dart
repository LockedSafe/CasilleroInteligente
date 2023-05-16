import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = '192.168.3.17',
      user = 'locked',
      password = 'AMREJ572502',
      db = 'ls';

  static int port = 3306;

  Mysql();

  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
        host: host, port: port, user: user, password: password, db: db);

    try {
      var conn = await MySqlConnection.connect(settings);
      return conn;
    } catch (e) {
      print('Error al conectar con la base de datos: $e');
      throw Exception('No se pudo conectar a la base de datos');
    }
  }
}
