// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:user_app_beta/screens/ayuda_renta.dart';
import 'package:user_app_beta/screens/confirm_rent_page.dart';
import 'package:user_app_beta/utils/bottom_bar.dart';
import 'package:user_app_beta/screens/home_page.dart';
import 'package:user_app_beta/classes/casillero.dart';
import 'package:user_app_beta/classes/estudiante.dart';
import 'package:user_app_beta/utils/mysql.dart';

class RentPage extends StatefulWidget {
  RentPage();
  bool deshabilitarBotones = false;

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  Estudiante estudiante = Estudiante.instancia;

  int _indice = 0;
  String lastCasillero = '';
  bool renta_activa = true;
  DateTime inicio = DateTime(0, 0, 0, 0);
  DateTime fin = DateTime(0, 0, 0, 0);
  bool deshabilitarBotones = false;

  String locker_selected = '';
  String hora_selected = '';
  bool ya_se_leyo_base = false;

  Map<String, int> estadoCasilleros = {
    'T1': 3,
    'T2': 3,
    'T3': 3,
    'T4': 3,
    'T5': 3,
    'T6': 3,
  };

  void _updateIndex(int index) {
    setState(() {
      _indice = index;
    });
    if (_indice == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    if (_indice == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Ayuda_Renta()),
      );
    }
    if (_indice == 2) {
      if (deshabilitarBotones == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfirmRentPage()),
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Aun no seleccionas NADA'),
                content: const Text(
                    'Selecciona un casillero para seguir con el APARTADO'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cerrar'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 29, 46, 133)),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  )
                ],
              );
            });
      }
    }
  }

  Future<void> casilleroPressed(String casillero) async {
    setState(() {
      if (estadoCasilleros[casillero] != 1) {
        estadoCasilleros[lastCasillero] = 0;
        lastCasillero = casillero;

        apartarCasillero(casillero);
      }
    });
  }

  void apartarCasillero(String casillero) {
    showDialog(
        context: context,
        builder: (BuildContextcontext) {
          return AlertDialog(
            title: Text(
              'Confirmación',
            ),
            content: Text(
              '¿Estas seguro que quieres apartar este casillero?',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancelar',
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 29, 46, 133)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    estadoCasilleros[casillero] = 2;
                  });

                  Casillero asignar_locker = Casillero('', 0, '');

                  asignar_locker.codigo = lastCasillero;
                  String numString = lastCasillero.substring(1);
                  asignar_locker.numero = int.parse(numString);
                  asignar_locker.ubicacion =
                      'T'; //Aqui fataria pasarle el parametro del edificio donde se está rentando

                  estudiante.fecha_apartado = DateTime.now();

                  estudiante.locker =
                      asignar_locker; //LLENAMOS LOS PARAMETROS DE LOCKER PARA EL ESTUDIANTE

                  setState(() {
                    hora_selected =
                        '${estudiante.fecha_apartado?.hour}:${estudiante.fecha_apartado?.minute}';
                    locker_selected = '${estudiante.locker?.codigo}';
                  });

                  deshabilitarBotones = true;
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Confirmar',
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 29, 46, 133)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          );
        });
  }

  Future<void> leerMatrizSeleccion() async {
    if (ya_se_leyo_base == false) {
      var db = Mysql();

      var conn = await db.getConnection();

      var results = await conn.query('SELECT * FROM casilleros');

      for (var row in results) {
        String code = row['codigo'].toString();
        bool ocupado = row['ocupado'] == 1 ? true : false;
        bool apartado = row['apartado'] == 1 ? true : false;
        actualizarMatriz(code, ocupado, apartado);
      }

      var results2 = await conn
          .query('SELECT * FROM periodos WHERE Proceso = ?', ['renta']);

      var row = results2.first;

      renta_activa = row['Activo'] == 1 ? true : false;

      inicio = row['Inicio'] as DateTime;
      fin = row['Fin'] as DateTime;

      print('inicio: ' + inicio.toString());
      print('actual :' + DateTime.now().toString());
      print('fin: ' + fin.toString());

      ya_se_leyo_base = true;

      await conn.close();
    }
  }

  void actualizarMatriz(String code, bool ocupado, bool apartado) {
    if (ocupado == true || apartado == true) {
      estadoCasilleros[code] = 1;
    } else if (ocupado == false && apartado == false) {
      estadoCasilleros[code] = 0;
    }
  }

  Future<void> actualizarenbase() async {
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

    await conn.close();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigth = MediaQuery.of(context).size.height;
    return Scaffold(
      body: FutureBuilder(
          future: leerMatrizSeleccion(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 22,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            'Renta tu casillero',
                            style: TextStyle(
                              fontSize: 24,
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
                    SizedBox(height: 20),
                    !renta_activa
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
                                        ? "El periodo de RENTA NO ha iniciado aún 😞, el siguiente periodo de renta está programado para el ${inicio.day}/${inicio.month}/${inicio.year} a las ${inicio.hour}:${inicio.minute}0 hrs"
                                        : DateTime.now()
                                                .subtract(Duration(hours: 6))
                                                .isAfter(fin)
                                            ? 'El periodo de RENTA YA terminó 😞, el último periodo de renta programdo terminó el ${fin.day}/${fin.month}/${fin.year} a las ${fin.hour}:${fin.minute}0 hrs'
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
                                      child: const Text(
                                        "Estas Realizando un Proceso, Ya NO Puedes Rentar 🙃",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : estudiante.tiene_casillero
                                ? Column(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth / 4,
                                              vertical: screenHeigth / 4),
                                          child: const Text(
                                            "Ya TIENES un CASILLERO YA NO puedes RENTAR otro 🙃",
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Hora de apartado: ' +
                                                  hora_selected,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: deshabilitarBotones
                                                      ? null
                                                      : () {
                                                          casilleroPressed(
                                                              'T1');
                                                        },
                                                  child: Text('T1'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (estadoCasilleros[
                                                                'T1'] ==
                                                            0) {
                                                          return Colors.grey;
                                                        } else if (estadoCasilleros[
                                                                'T1'] ==
                                                            1) {
                                                          return Colors.red;
                                                        } else if (estadoCasilleros[
                                                                'T1'] ==
                                                            2) {
                                                          return Colors.yellow;
                                                        } else {
                                                          return Colors.grey;
                                                        }
                                                      },
                                                    ),
                                                    fixedSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                Size(50, 50)),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                ElevatedButton(
                                                  onPressed: deshabilitarBotones
                                                      ? null
                                                      : () async {
                                                          await casilleroPressed(
                                                              'T2');
                                                        },
                                                  child: Text('T2'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (estadoCasilleros[
                                                                'T2'] ==
                                                            0) {
                                                          return Colors.grey;
                                                        } else if (estadoCasilleros[
                                                                'T2'] ==
                                                            1) {
                                                          return Colors.red;
                                                        } else if (estadoCasilleros[
                                                                'T2'] ==
                                                            2) {
                                                          return Colors.yellow;
                                                        } else {
                                                          return Colors.grey;
                                                        }
                                                      },
                                                    ),
                                                    fixedSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                Size(50, 50)),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                ElevatedButton(
                                                  onPressed: deshabilitarBotones
                                                      ? null
                                                      : () => casilleroPressed(
                                                          'T3'),
                                                  child: Text('T3'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (estadoCasilleros[
                                                                'T3'] ==
                                                            0) {
                                                          return Colors.grey;
                                                        } else if (estadoCasilleros[
                                                                'T3'] ==
                                                            1) {
                                                          return Colors.red;
                                                        } else if (estadoCasilleros[
                                                                'T3'] ==
                                                            2) {
                                                          return Colors.yellow;
                                                        } else {
                                                          return Colors.grey;
                                                        }
                                                      },
                                                    ),
                                                    fixedSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                Size(50, 50)),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                ElevatedButton(
                                                  onPressed: deshabilitarBotones
                                                      ? null
                                                      : () => casilleroPressed(
                                                          'T4'),
                                                  child: Text('T4'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (estadoCasilleros[
                                                                'T4'] ==
                                                            0) {
                                                          return Colors.grey;
                                                        } else if (estadoCasilleros[
                                                                'T4'] ==
                                                            1) {
                                                          return Colors.red;
                                                        } else if (estadoCasilleros[
                                                                'T4'] ==
                                                            2) {
                                                          return Colors.yellow;
                                                        } else {
                                                          return Colors.grey;
                                                        }
                                                      },
                                                    ),
                                                    fixedSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                Size(50, 50)),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            ),
                                            SizedBox(width: 5),
                                            Column(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: deshabilitarBotones
                                                      ? null
                                                      : () => casilleroPressed(
                                                          'T5'),
                                                  child: Text('T5'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (estadoCasilleros[
                                                                'T5'] ==
                                                            0) {
                                                          return Colors.grey;
                                                        } else if (estadoCasilleros[
                                                                'T5'] ==
                                                            1) {
                                                          return Colors.red;
                                                        } else if (estadoCasilleros[
                                                                'T5'] ==
                                                            2) {
                                                          return Colors.yellow;
                                                        } else {
                                                          return Colors.grey;
                                                        }
                                                      },
                                                    ),
                                                    fixedSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                Size(50, 105)),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                ElevatedButton(
                                                  onPressed: deshabilitarBotones
                                                      ? null
                                                      : () => casilleroPressed(
                                                          'T6'),
                                                  child: Text('T6'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (estadoCasilleros[
                                                                'T6'] ==
                                                            0) {
                                                          return Colors.grey;
                                                        } else if (estadoCasilleros[
                                                                'T6'] ==
                                                            1) {
                                                          return Colors.red;
                                                        } else if (estadoCasilleros[
                                                                'T6'] ==
                                                            2) {
                                                          return Colors.yellow;
                                                        } else {
                                                          return Colors.grey;
                                                        }
                                                      },
                                                    ),
                                                    fixedSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                                Size(50, 105)),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 80),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Ocupado',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Disponible',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      'Casillero Seleccionado: ' +
                                                          locker_selected,
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.yellow,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Seleccionado',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '¿Ya no encontraste casilleros disponibles?, puedes apuntarte para el periodo de prorroga y rentar un casillero en caso de que algunos no finalicen su renta',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          '¿Estás seguro de inscribirte al periodo de prorroga?'),
                                                      content: const Text(
                                                          'Solo confirma si ya no encontraste casilleros disponibles, se te enviará correo si tendrás oportunidad de rentar un casillero.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Cancelar'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            estudiante
                                                                    .en_proceso =
                                                                true;
                                                            estudiante
                                                                    .fecha_apartado =
                                                                DateTime.now();

                                                            await actualizarenbase();
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          HomePage()),
                                                            );
                                                          },
                                                          child: const Text(
                                                              'Confirmar'),
                                                        )
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Text(
                                                'INCRIBIRME AL PERIODO DE PRORROGA'),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Color.fromARGB(
                                                          255, 29, 46, 133)),
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ],
                                  ),
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
