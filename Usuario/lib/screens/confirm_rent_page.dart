// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:user_app_beta/screens/ayuda_confirmar_renta.dart';
import 'package:user_app_beta/screens/home_page.dart';
import 'package:user_app_beta/screens/rentar_page.dart';
import 'package:user_app_beta/utils/bottom_bar.dart';
import 'package:user_app_beta/classes/estudiante.dart';
import 'package:user_app_beta/utils/mysql.dart';

class ConfirmRentPage extends StatefulWidget {
  ConfirmRentPage();

  @override
  State<ConfirmRentPage> createState() => _ConfirmRentPageState();
}

class _ConfirmRentPageState extends State<ConfirmRentPage> {
  Estudiante estudiante = Estudiante.instancia;

  String horaSeleccionada = '';
  DateTime fecha_Asignada = DateTime(0, 0, 0);
  bool casillero_aun_disponible = false;

  final Map<String, int> _hours = {
    '8:00': 0,
    '9:00': 10,
    '10:00': 0,
    '11:00': 10,
    '12:00': 10,
    '13:00': 10,
    '14:00': 10,
    '15:00': 10,
    '16:00': 10,
    '17:00': 10,
    '18:00': 0,
  };

  int _indice = 0;

  void _updateIndex(int index) {
    setState(() {
      _indice = index;
    });
    if (_indice == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RentPage()),
      );
    }
    if (_indice == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Ayuda_Confirm_Renta()),
      );
    }
    if (_indice == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      estudiante.fecha_atencion = DateTime(0, 0, 0, 0);
    }
  }

  Future<void> actualizarenBase(Estudiante estudiante) async {
    var db = Mysql();
    var conn = await db.getConnection();

    await conn.query(
        'INSERT INTO renta (Clave_unica, Nombre, Correo, Tiene_Casillero, En_proceso, Fecha_de_apartado, Fecha_de_atencion, Casillero) VALUES(?,?,?,?,?,?,?,?)',
        [
          estudiante.clave_unica,
          estudiante.nombre,
          estudiante.login.correo,
          estudiante.tiene_casillero,
          estudiante.en_proceso,
          '${estudiante.fecha_apartado}',
          '${estudiante.fecha_atencion}',
          estudiante.locker?.codigo,
        ]);

    await conn.query('UPDATE casilleros SET apartado = ? WHERE codigo = ?',
        [true, estudiante.locker?.codigo]);

    var results = await conn.query('SELECT * FROM Horas WHERE Horario = ?',
        ['${estudiante.fecha_atencion?.hour}:00']);

    var row = results.first;

    int menos = row['Cupo'] - 1;

    await conn.query('UPDATE Horas SET Cupo = ? WHERE Horario = ?',
        [menos, '${estudiante.fecha_atencion?.hour}:00']);

    await conn.close();
  }

  Future<void> leerHorarios() async {
    var db = Mysql();
    var conn = await db.getConnection();

    var results = await conn.query('SELECT * FROM Horas');

    for (var row in results) {
      String hora = row['Horario'].toString();
      int contador = row['Cupo'];
      actualizarBotones(hora, contador);
    }

    var results2 = await conn.query('SELECT * FROM periodos');
    var row2 = results2.first;

    fecha_Asignada = row2['Fecha_de_pago'] as DateTime;

    await conn.close();
  }

  void actualizarBotones(String hora, int contador) {
    _hours[hora] = contador;
  }

  Future<void> checarCasillero(Estudiante estudiante) async {
    var db = Mysql();
    var conn = await db.getConnection();

    var results = await conn.query('SELECT * FROM casilleros WHERE codigo = ?',
        [estudiante.locker?.codigo]);

    var row = results.first;

    if (row['apartado'] == 0) {
      casillero_aun_disponible = true;
    } else {
      casillero_aun_disponible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: leerHorarios(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 22,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text(
                            'Confirmar renta',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/Logo_ls1.png',
                          height: 80,
                          width: 80,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text(
                            'Ya casi terminamos ${estudiante.nombre}, solo selecciona una fecha y hora para que acudas a la oficina a terminar tu trámite de renta:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _hours.keys.map((String hour) {
                            final int count = _hours[hour] ?? 0;
                            return ElevatedButton(
                              child: Text(hour),
                              onPressed: count >= 1
                                  ? () {
                                      setState(() {
                                        horaSeleccionada = hour;
                                        List<String> horaMinuto =
                                            horaSeleccionada.split(':');
                                        estudiante.fecha_atencion = DateTime(
                                            fecha_Asignada.year,
                                            fecha_Asignada.month,
                                            fecha_Asignada.day,
                                            int.parse(horaMinuto[0]),
                                            0);
                                      });
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: count < 1
                                    ? Colors.red
                                    : horaSeleccionada == hour
                                        ? Color.fromARGB(255, 29, 46, 133)
                                        : Color.fromARGB(255, 176, 186, 231),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 3),
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 176, 186, 231),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Horario disponible',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 29, 46, 133),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Horario seleccionado',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Horario no disponible',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Verifica tu renta solicitada: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Casillero: Edificio[${estudiante.locker?.ubicacion}] Numero[${estudiante.locker?.numero}]',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hora de apartado: ${estudiante.fecha_apartado?.hour}:${estudiante.fecha_apartado?.minute}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    estudiante.fecha_atencion?.hour != 0
                                        ? 'Hora de registro: ${estudiante.fecha_atencion?.hour}:00'
                                        : 'Hora de registro: ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Text(
                                    'POR FAVOR LLEVA COMPROBANTE DE CLAVE ÚNICA',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Si TODA la información es correcta presiona FINALIZAR APARTADO',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        if (casillero_aun_disponible == true) {
                          if (estudiante.fecha_atencion?.hour != 0) {
                            estudiante.en_proceso = true;
                            actualizarenBase(estudiante);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'LISTO Se ha apartado el casillero'),
                                    content: const Text(
                                        'Presiona OK para regresar al menu de INICIO'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage()),
                                          );
                                        },
                                        child: const Text('OK'),
                                      )
                                    ],
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('HORA SIN SELECCIONAR'),
                                    content: const Text(
                                        'Selecciona una hora de atención para poder finalizar tu apartado'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      )
                                    ],
                                  );
                                });
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                      'EL CASILLERO YA NO ESTÁ DISPONIBLE'),
                                  content: const Text(
                                      'Alguien ya apartó este casillero seleccionado, por favor regresa a seleccionar otro e intenta otra vez'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    )
                                  ],
                                );
                              });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 29, 46, 133)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      child: Text('FINALIZAR APARTADO'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        '😉',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(600),
            topRight: Radius.circular(600),
          ),
        ),
        child: BottomBar(
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/regresar_blanco.png',
                height: 24,
              ),
              label: 'Regresar',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/ayuda_blanco.png',
                height: 24,
              ),
              label: 'Ayuda',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/siguiente_blanco.png',
                height: 24,
              ),
              label: 'Siguiente',
            ),
          ],
          currentIndex: _indice,
          onTap: _updateIndex,
          disableItems: false,
        ),
      ),
    );
  }
}
