import 'package:flutter/material.dart';
import 'package:user_app_beta/classes/casillero.dart';
import 'package:user_app_beta/classes/inicio_sesion.dart';

class Estudiante {
  int clave_unica;
  String nombre;
  bool tiene_casillero;
  bool en_proceso;
  DateTime? fecha_atencion;
  DateTime? fecha_apartado;

  Casillero? locker;
  InicioSesion login = InicioSesion('', '', '');

  static Estudiante? _instancia;

  Estudiante._internal(
    this.clave_unica,
    this.nombre,
    this.tiene_casillero,
    this.en_proceso,
    this.fecha_atencion,
    this.fecha_apartado,
  );

  factory Estudiante() {
    return _instancia ??= Estudiante._internal(
      0,
      '',
      false,
      false,
      DateTime(0, 0, 0, 0, 0),
      DateTime(0, 0, 0, 0, 0),
    );
  }

  static Estudiante get instancia {
    return _instancia ??= Estudiante._internal(
      0,
      '',
      false,
      false,
      DateTime(0, 0, 0, 0, 0),
      DateTime(0, 0, 0, 0, 0),
    );
  }
}
