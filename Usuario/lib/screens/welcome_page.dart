// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:user_app_beta/classes/casillero.dart';

import 'package:user_app_beta/classes/estudiante.dart';

import 'package:user_app_beta/screens/home_page.dart';

import 'package:user_app_beta/utils/mysql.dart';
import 'package:flutter/services.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Estudiante estudiante = Estudiante.instancia;

  bool registrando_ahora = false;
  bool ingresando_ahora = false;
  bool verificando_ahora = false;
  bool _correct_login = false;
  bool _isPasswordVisible = false;

  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _claveController = TextEditingController();
  final _verificadorController = TextEditingController();

  bool showError = false;

  Future<void> leerBaseDatos(Estudiante estudiante) async {
    var db = Mysql();

    var conn = await db.getConnection();

    var results = await conn.query(
        'SELECT * FROM usuario WHERE Clave_unica = ?',
        [estudiante.clave_unica]);

    if (results.isNotEmpty) {
      var row = results.first;
      estudiante.nombre = row['Nombre'].toString();
      estudiante.login.correo = row['Correo'].toString();
    }

    try {
      var results2 = await conn.query(
          'SELECT * FROM renta WHERE Clave_unica = ?',
          [estudiante.clave_unica]);

      if (results2.isNotEmpty) {
        var row2 = results2.first;
        estudiante.tiene_casillero =
            row2['Tiene_Casillero'] == 1 ? true : false;

        estudiante.en_proceso = row2['En_Proceso'] == 1 ? true : false;
        print('en proceso: ' + estudiante.en_proceso.toString());

        estudiante.fecha_atencion = row2['Fecha_de_atencion'] as DateTime;
        estudiante.fecha_apartado = row2['Fecha_de_apartado'] as DateTime;

        /* String horaAtencion = row2['Hora_de_atencion'].toString();
        List<String> horaMinutos = horaAtencion.split(':');
        var tiempo_convert = TimeOfDay(
            hour: int.parse(horaMinutos[0]), minute: int.parse(horaMinutos[1]));
        estudiante.hora_atencion = tiempo_convert;

        String horaApartado = row2['Hora_de_apartado'].toString();
        horaMinutos = horaApartado.split(':');
        tiempo_convert = TimeOfDay(
            hour: int.parse(horaMinutos[0]), minute: int.parse(horaMinutos[1]));
        estudiante.hora_apartado = tiempo_convert;
        */

        if ((estudiante.tiene_casillero == true ||
                estudiante.en_proceso == true) &&
            row2['Casillero'] != null) {
          if (row2.isNotEmpty) {
            String code = row2['Casillero'].toString();

            String letter = code.substring(0, 1);

            int num = int.parse(code.substring(1));

            Casillero locker_asign = Casillero(letter, num, code);
            estudiante.locker = locker_asign;
          }
        }
      }
    } on Exception catch (e) {
      print(e);
      estudiante.tiene_casillero = false;
      estudiante.en_proceso = false;
    }

    await conn.close();
  }

  Future<void> verificarInicioSesion(Estudiante estudiante) async {
    var db = Mysql();
    var conn = await db.getConnection();

    var results = await conn.query(
        'SELECT * FROM usuario WHERE Clave_unica = ?',
        [estudiante.clave_unica]);

    if (results.isNotEmpty) {
      var row = results.first;

      if (row['verificacion'] != 0) {
        if (estudiante.login.password == row['Password']) {
          print(estudiante.login.verificador.toString());
          print(row['Clave_R'].toString());
          _correct_login = true;
        }
      } else {
        if (estudiante.login.verificador == row['Clave_R']) {
          if (estudiante.login.password == row['Password']) {
            _correct_login = true;

            await conn.query(
                'UPDATE usuario SET verificacion = ? WHERE Clave_unica = ?',
                [true, estudiante.clave_unica]);
          } else {
            _correct_login = false;
          }
        } else {
          _correct_login = false;
        }
      }

      await conn.close();
    }
  }

  Future<void> agregarNuevoUsuario(Estudiante estudiante) async {
    var db = Mysql();
    var conn = await db.getConnection();

    await conn.query(
        'INSERT INTO usuario (Clave_unica, Nombre, Correo, Password) VALUES (?,?,?,?)',
        [
          estudiante.clave_unica,
          estudiante.nombre,
          estudiante.login.correo,
          estudiante.login.password,
        ]);

    await conn.close();
  }

  Future<void> recuperarCuenta(Estudiante estudiante) async {
    var db = Mysql();
    var conn = await db.getConnection();

    var results = await conn.query(
        'SELECT * FROM usuario WHERE Clave_unica = ?',
        [estudiante.clave_unica]);

    var row = results.first;

    if (estudiante.login.verificador == row['Clave_R']) {
      await conn.query(
          'UPDATE usuario SET Nombre = ?, Correo = ?, Password = ? WHERE Clave_unica = ?',
          [
            estudiante.nombre,
            estudiante.login.correo,
            estudiante.login.password,
            estudiante.clave_unica
          ]);
    }

    await conn.close();
  }

  void showRegistro() {
    setState(() {
      registrando_ahora = true;
    });
  }

  void showIngreso() {
    setState(() {
      ingresando_ahora = true;
    });
  }

  void showVerificacion() {
    setState(() {
      verificando_ahora = true;
    });
  }

  void hideRegistro() {
    setState(() {
      _nombreController.text = '';
      _correoController.text = '';
      _passwordController.text = '';
      _claveController.text = '';
      _verificadorController.text = '';
      registrando_ahora = false;
      ingresando_ahora = false;
      verificando_ahora = false;
    });
  }

  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();

    _passwordController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.darken),
            image: AssetImage('assets/images/Locks_bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/Logo_ls1blanco.png',
                  height: 80,
                  width: 80,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'BIENVENID@',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            verificando_ahora
                ? Column(children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Clave Unica (sin la "a" y sin "0")',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: _claveController,
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Nombre',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: _nombreController,
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Correo',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: _correoController,
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Clave de verificación',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: _verificadorController,
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Restablece Contraseña',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        estudiante.clave_unica =
                            int.parse(_claveController.text);
                        estudiante.nombre = _nombreController.text;
                        estudiante.login.correo = _correoController.text;
                        estudiante.login.password = _passwordController.text;
                        estudiante.login.verificador =
                            _verificadorController.text;

                        await recuperarCuenta(estudiante);

                        hideRegistro();
                      },
                      child: Text('Recuperar cuenta'),
                    ),
                  ])
                : registrando_ahora
                    ? GestureDetector(
                        onTap: () {
                          // cerrar el teclado al tocar fuera de las textbars
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Clave Unica (sin la "a" y sin "0")',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: _claveController,
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Nombre',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: _nombreController,
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Correo (institucional)',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: _correoController,
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Crear Contraseña',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Color.fromARGB(255, 29, 46, 133),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                            ),
                            const SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (_claveController.text.isNotEmpty &&
                                    _nombreController.text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty) {
                                  estudiante.clave_unica =
                                      int.parse(_claveController.text);

                                  estudiante.nombre = _nombreController.text;

                                  estudiante.login.correo =
                                      _correoController.text;

                                  estudiante.login.password =
                                      _passwordController.text;

                                  if (estudiante.login.correo
                                          .endsWith('@alumnos.uaslp.mx') &&
                                      estudiante.login.correo.startsWith('a')) {
                                    try {
                                      await agregarNuevoUsuario(estudiante);
                                      // ignore: use_build_context_synchronously
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('REGISTRO'),
                                              content: const Text(
                                                  'Listo solo ingresa al buzón de tu correo ingresado para obtener tu clave de verificación, la necesitarás cuando inicies sesión por primera vez'),
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
                                      hideRegistro();
                                    } on MySqlException catch (e) {
                                      print(e);
                                      if (e.errorNumber == 1062) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('ERROR'),
                                                content: const Text(
                                                    'Ya está registrada la clave unica ingresada, ¿Deseas hacer una verificación para recuperar tu cuenta?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      hideRegistro();
                                                      showVerificacion();
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('Cerrar'),
                                                  ),
                                                ],
                                              );
                                            });
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('ERROR'),
                                                content: const Text(
                                                    'No se pudo conectar con el servidor'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Cerrar'),
                                                  )
                                                ],
                                              );
                                            });
                                      }
                                    }
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('ERROR'),
                                            content: const Text(
                                                'El correo introducido debe iniciar con a y terminar en @alumnos.uaslp.mx'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cerrar'),
                                              )
                                            ],
                                          );
                                        });
                                  }
                                } else {
                                  hideRegistro();
                                }
                              },
                              child: Text(
                                'REGISTRAR',
                                textAlign: TextAlign.center,
                              ),
                              style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all<Size>(
                                    Size(130, 50)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 211, 214, 231),
                                ),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ingresando_ahora
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  hintText:
                                      'Clave Unica (sin la "a" y sin "0")',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                controller: _claveController,
                              ),
                              SizedBox(height: 5),
                              SizedBox(height: 5),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Contraseña',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                controller: _passwordController,
                                obscureText: true,
                              ),
                              SizedBox(height: 9),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText:
                                      'Clave de verificación (Nuevo Usuario)',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                controller: _verificadorController,
                              ),
                              SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (_claveController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty) {
                                    estudiante.clave_unica =
                                        int.parse(_claveController.text);

                                    estudiante.login.password =
                                        _passwordController.text;

                                    estudiante.login.verificador =
                                        _verificadorController.text;

                                    try {
                                      await verificarInicioSesion(estudiante);
                                    } on Exception catch (e) {
                                      print(e);
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('ERROR'),
                                              content: const Text(
                                                  'No se pudo conectar con el servidor'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cerrar'),
                                                )
                                              ],
                                            );
                                          });
                                    }

                                    if (_correct_login == true) {
                                      hideRegistro();

                                      await leerBaseDatos(estudiante);
                                      print(estudiante.en_proceso.toString());

                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                      );
                                    } else {
                                      setState(() {
                                        showError = true;
                                      });
                                    }
                                  } else {
                                    hideRegistro();
                                  }
                                },
                                child: Text(
                                  'INGRESAR',
                                  textAlign: TextAlign.center,
                                ),
                                style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all<Size>(
                                      Size(132, 50)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 211, 214, 231),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              showError
                                  ? AlertDialog(
                                      title: Text('Error'),
                                      content: Text(
                                          'Algunos de los campos son incorrectos'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              showError = false;
                                            });
                                          },
                                          child: Text('OK'),
                                        )
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => showIngreso(),
                                child: Text(
                                  'INICIAR SESION',
                                  textAlign: TextAlign.center,
                                ),
                                style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all<Size>(
                                      Size(132, 50)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 211, 214, 231),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 200),
                              ElevatedButton(
                                onPressed: () => showRegistro(),
                                child: Text(
                                  'REGISTRATE',
                                  textAlign: TextAlign.center,
                                ),
                                style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all<Size>(
                                      Size(132, 50)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 211, 214, 231),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '¿Aun no tienes cuenta?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
          ],
        ),
      ),
    );
  }
}
