// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:user_app_beta/screens/rentar_page.dart';
import 'package:user_app_beta/utils/bottom_bar.dart';
import 'package:user_app_beta/screens/renovar_page.dart';
import 'package:user_app_beta/classes/estudiante.dart';
import 'package:user_app_beta/screens/ayuda_inicio.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Estudiante estudiante = Estudiante.instancia;
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
        MaterialPageRoute(builder: (context) => RenovarPage()),
      );
    }

    if (_indice == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Ayuda_Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeigth = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/lock_home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
              ),
              Container(
                color: Colors.white,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: const Text(
                        'INICIO',
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
                    )
                  ],
                ),
              ),
              SizedBox(
                width: screenWidth,
                height: screenHeigth - 91 - 57,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola ${estudiante.nombre}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clave Unica: ${estudiante.clave_unica.toString()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Correo: ${estudiante.login.correo.toString()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          estudiante.en_proceso
                              ? Column(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          estudiante.tiene_casillero
                                              ? 'Estas realizando el proceso de renovación 😊'
                                              : estudiante.locker != null
                                                  ? 'Estas realizando el proceso de renta 😊'
                                                  : 'Estas inscrit@ en el periodo de prorroga 😊',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          estudiante.tiene_casillero
                                              ? 'Este es el casillero que quieres renovar'
                                              : estudiante.locker != null
                                                  ? 'Este es el casillero que estás apartando'
                                                  : '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          estudiante.locker != null
                                              ? 'CASILLERO [${estudiante.locker?.codigo}]'
                                              : '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          estudiante.locker != null
                                              ? 'Edificio: ${estudiante.locker?.ubicacion}'
                                              : '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          estudiante.tiene_casillero
                                              ? ''
                                              : 'Fecha de apartado: ${estudiante.fecha_apartado?.day}/${estudiante.fecha_apartado?.month}/${estudiante.fecha_apartado?.year} ${estudiante.fecha_apartado?.hour}:${estudiante.fecha_apartado?.minute}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          estudiante.tiene_casillero
                                              ? 'Por favor acude a la oficina el día ${estudiante.fecha_atencion?.day}/${estudiante.fecha_atencion?.month}/${estudiante.fecha_atencion?.year} a las ${estudiante.fecha_atencion?.hour}:00 horas para terminar tu proceso de renovación'
                                              : estudiante.locker != null
                                                  ? 'Por favor acude a la oficina el día ${estudiante.fecha_atencion?.day}/${estudiante.fecha_atencion?.month}/${estudiante.fecha_atencion?.year} a las ${estudiante.fecha_atencion?.hour}:00 horas para terminar tu proceso de renta'
                                                  : 'Pon atención al buzón de tu correo, te avisaremos en caso de aun contar con casilleros sin rentar, recuerda que el periodo de prorroga es el día ${estudiante.fecha_atencion?.day}/${estudiante.fecha_atencion?.month}/${estudiante.fecha_atencion?.year}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : estudiante.tiene_casillero
                                  ? Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Actualmente tienes un Casillero 😊',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Tu CASILLERO',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Edificio: ${estudiante.locker?.ubicacion}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Lugar: ${estudiante.locker?.numero} [${estudiante.locker?.codigo}]',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Aun no tienes un casillero ' +
                                                  '😞',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                'assets/images/rentar_blanco.png',
                height: 24,
              ),
              label: 'Rentar',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/renovar_blanco.png',
                height: 24,
              ),
              label: 'Renovar',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/ayuda_blanco.png',
                height: 24,
              ),
              label: 'Ayuda',
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
