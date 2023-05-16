// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:user_app_beta/classes/estudiante.dart';
import 'package:user_app_beta/screens/home_page.dart';
import 'package:user_app_beta/utils/bottom_bar.dart';
import 'package:user_app_beta/utils/mysql.dart';
import 'package:user_app_beta/screens/ayuda_renovacion.dart';

class RenovarPage extends StatefulWidget {
  const RenovarPage({super.key});

  @override
  State<RenovarPage> createState() => _RenovarPageState();
}

class _RenovarPageState extends State<RenovarPage> {
  Estudiante estudiante = Estudiante.instancia;

  String horaSeleccionada = '';
  DateTime fecha_Asignada = DateTime(0, 0, 0);

  bool renovacion_activa = true;

  DateTime inicio = DateTime(0, 0, 0, 0);
  DateTime fin = DateTime(0, 0, 0, 0);

  final Map<String, int> _hours = {
    '8:00': 10,
    '9:00': 10,
    '10:00': 10,
    '11:00': 10,
    '12:00': 10,
    '13:00': 10,
    '14:00': 10,
    '15:00': 10,
    '16:00': 10,
    '17:00': 10,
    '18:00': 10,
  };

  int _indice = 0;

  void _updateIndex(int index) {
    setState(() {
      _indice = index;
    });
    if (_indice == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      horaSeleccionada = '0';
    }
    if (_indice == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Ayuda_Renovar()),
      );
    }
    if (_indice == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      horaSeleccionada = '0';
    }
  }

  Future<void> verificarEstado() async {
    var db = Mysql();

    var conn = await db.getConnection();

    var results = await conn
        .query('SELECT * FROM periodos WHERE Proceso = ?', ['renovacion']);

    var row = results.first;

    renovacion_activa = row['Activo'] == 1 ? true : false;

    inicio = row['Inicio'] as DateTime;
    fin = row['Fin'] as DateTime;
    fecha_Asignada = row['Fecha_de_pago'] as DateTime;

    var results2 = await conn.query('SELECT * FROM Horas');

    for (var row in results2) {
      String hora = row['Horario'].toString();
      int contador = row['Cupo'];
      actualizarBotones(hora, contador);
    }

    await conn.close();
  }

  void actualizarBotones(String hora, int contador) {
    _hours[hora] = contador;
  }

  Future<void> actualizarenBase(Estudiante estudiante) async {
    var db = Mysql();
    var conn = await db.getConnection();

    await conn.query('UPDATE renta SET Fecha_de_atencion = ?, En_Proceso = ?', [
      '${estudiante.fecha_atencion}',
      estudiante.en_proceso,
    ]);

    var results = await conn.query('SELECT * FROM Horas WHERE Horario = ?',
        ['${estudiante.fecha_atencion?.hour}:00']);

    var row = results.first;

    int menos = row['Cupo'] - 1;

    await conn.query('UPDATE Horas SET Cupo = ? WHERE Horario = ?',
        [menos, '${estudiante.fecha_atencion?.hour}:00']);

    await conn.close();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigth = MediaQuery.of(context).size.height;
    return Scaffold(
      body: FutureBuilder(
          future: verificarEstado(),
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
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.all(6.0),
                            child: Text(
                              'Confirmación de renovación',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
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
                    SizedBox(height: 20),
                    !renovacion_activa
                        ? Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth / 4,
                                      vertical: screenHeigth / 6),
                                  child: Text(
                                    DateTime.now()
                                            .subtract(Duration(hours: 6))
                                            .isBefore(inicio)
                                        ? "El periodo de RENOVACIÓN NO ha iniciado aún 😞, el siguiente periodo de renovación está programado para el ${inicio.day}/${inicio.month}/${inicio.year} a las ${inicio.hour}:${inicio.minute}0 hrs"
                                        : DateTime.now()
                                                .subtract(Duration(hours: 6))
                                                .isAfter(fin)
                                            ? 'El periodo de RENOVACIÓN YA terminó 😞, el último periodo de renovación programdo terminó el ${fin.day}/${fin.month}/${fin.year} a las ${fin.hour}:${fin.minute}0 hrs'
                                            : '',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : estudiante.en_proceso
                            ? Column(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth / 4,
                                          vertical: screenHeigth / 4),
                                      child: Text(
                                        "Estas Realizando un Proceso, NO puedes Renovar 🙃",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : !estudiante.tiene_casillero
                                ? Column(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth / 4,
                                              vertical: screenHeigth / 4),
                                          child: Column(
                                            children: const [
                                              Text(
                                                "NO Puedes RENOVAR si no tienes un casillero🙃",
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Text(
                                          'Puedes renovar tu casillero actual solo tienes que seleccionar una hora para asistir a la oficina a realizar el pago y así completar tu renovación:',
                                          textAlign: TextAlign.center,
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
                                        children:
                                            _hours.keys.map((String hour) {
                                          final int count = _hours[hour] ?? 0;
                                          return ElevatedButton(
                                            child: Text(hour),
                                            onPressed: count >= 1
                                                ? () {
                                                    setState(() {
                                                      horaSeleccionada = hour;
                                                      List<String> horaMinuto =
                                                          horaSeleccionada
                                                              .split(':');
                                                      estudiante.fecha_atencion =
                                                          DateTime(
                                                              fecha_Asignada
                                                                  .year,
                                                              fecha_Asignada
                                                                  .month,
                                                              fecha_Asignada
                                                                  .day,
                                                              int.parse(
                                                                  horaMinuto[
                                                                      0]),
                                                              0);
                                                    });
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  horaSeleccionada == hour
                                                      ? Color.fromARGB(
                                                          255, 29, 46, 133)
                                                      : Color.fromARGB(
                                                          255, 184, 193, 238),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color.fromARGB(
                                                  255, 176, 186, 231),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color.fromARGB(
                                                  255, 29, 46, 133),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Por favor verifica que toda tu información sea correcta ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'TU CASILLERO ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Edificio: ${estudiante.locker?.ubicacion}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Numero de casillero: ${estudiante.locker?.numero.toString()} (${estudiante.locker?.codigo})',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  horaSeleccionada != '0'
                                                      ? 'Hora seleccionada: ${estudiante.fecha_atencion?.hour}:00'
                                                      : 'Hora seleccionda:',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  'POR FAVOR LLEVA COMPROBANTE DE CLAVE ÚNICA',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Center(
                                              child: Text(
                                                'Si TODA la información es correcta presiona SOLICITAR RENOVACION',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (horaSeleccionada != '0') {
                                            estudiante.en_proceso = true;
                                            actualizarenBase(estudiante);
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'LISTO Se ha solicitado tu renovación'),
                                                    content: const Text(
                                                        'Presiona OK para regresar al menu de INICIO'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
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
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'HORA SIN SELECCIONAR'),
                                                    content: const Text(
                                                        'Selecciona una hora de atención para poder finalizar la solicitud de renovación'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('OK'),
                                                      )
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                        child: Text('SOLICITAR RENOVACION'),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 29, 46, 133)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
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
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
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
