import 'package:flutter/material.dart';
import 'package:user_app_beta/screens/confirm_rent_page.dart';
import 'package:user_app_beta/screens/rentar_page.dart';
import 'package:user_app_beta/utils/bottom_bar.dart';

class Ayuda_Confirm_Renta extends StatelessWidget {
  const Ayuda_Confirm_Renta({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int _indice = 0;

    void _updateIndex(int index) {
      if (_indice == 0 || _indice == 1 || _indice == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfirmRentPage()),
        );
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: screenWidth,
              child: Image.asset(
                'assets/images/ayuda_confirmar_renta.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
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
