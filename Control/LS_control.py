#Control de raspberry pi
#Autor:Vazquez hernandez Jesus Alejandro
#Proyecto:Casillero inteligente 

#Se importan la librerias
import sys
from PyQt5 import QtCore, QtGui, QtWidgets
from PyQt5.QtCore import QPropertyAnimation, QEasingCurve,QTimer
from SH2 import huella
from conexion_mysqlconnector import Comunicacion
from PyQt5.QtWidgets import QApplication, QMainWindow, QTableWidget, QTableWidgetItem,QHeaderView
from PyQt5.QtGui import QFont
from PyQt5.uic import loadUi


#Creacion del objeto para utilizar el sensor de huella digital
#HC=huella()

#HC
#while True:

#negar variable

class VentanaPrincipalC(QMainWindow):
    def __init__(self):
        super(VentanaPrincipalC, self).__init__()
        loadUi("LS_controlD.ui",self)
        #Se inicializa un timer
        self.timer2=QTimer(self)
        self.timer=QTimer(self)
        self.timer2.timeout.connect(self.Timer2)
        self.timer.timeout.connect(self.Timer_int)
        self.timer.start(5000)
        self.timer2.start(300000)
        self.Bandera=0
        #Creacion del objeto para utilizar el sensor de huella digital
        self.HC=huella()
        #Creacion del objeto para la conexion con la base de datos

        self.BDC=Comunicacion()
        #Configuracion de la ventana
        self.setWindowFlag(QtCore.Qt.FramelessWindowHint)
        self.setWindowOpacity(1)


        #Tamaño de la ventana
        self.gripSize=10
        self.grip=QtWidgets.QSizeGrip(self)
        self.grip.resize(self.gripSize,self.gripSize)

        #Mover la ventana
        self.FR_T.mouseMoveEvent=self.mover_V
        #Botones para configurar el tamaño de la ventana
        self.Btn_Mpes.hide()
        self.Btn_Maximizar.clicked.connect(self.Max_V)
        self.Btn_Minimizar.clicked.connect(self.Min_V)
        self.Btn_Mpes.clicked.connect(self.Nom_V)
        self.Btn_Cerrar.clicked.connect(lambda: self.close())
        


    def resizeEvent(self, event):
        super().resizeEvent(event)
        rect=self.rect()
        self.grip.move(rect.right()-self.gripSize,rect.bottom()-self.gripSize)

    def mousePressEvent(self, event):
        super().mousePressEvent(event)
        self.click_posicion=event.globalPos()
    
    
    def mover_V(self,event):#Funcion para mover la ventana
        if self.isMaximized()==False:
            if event.buttons()==QtCore.Qt.LeftButton:
                self.move(self.pos()+event.globalPos()-self.click_posicion)
                self.click_posicion=event.globalPos()
            if event.globalPos().y()<=10:
                self.showMaximized()
                self.Btn_Maximizar.hide()
                self.Btn_Mpes.show()
            else:
                self.showNormal()
                self.Btn_Mpes.hide()
                self.Btn_Maximizar.show()
    def Max_V(self):
        self.showMaximized()#Se maximiza la pantalla
        self.Btn_Maximizar.hide()
        self.Btn_Mpes.show() 

    def Min_V(self):     
        self.showMinimized()

    def Nom_V(self):
        self.showNormal()
        self.Btn_Mpes.hide()
        self.Btn_Maximizar.show()

    def AbrirC(self):
        self.RecuperarH=self.BDC.BuscarHuella()
        if len(self.RecuperarH)!=0:
            H=self.HC.comparaHuellas(self.RecuperarH)
            print(H)
            if(H!=' '):
                dat="renta"    
                c=self.BDC.BuscarDatos(H,dat)
                print(c)#Falta la condicional
                r=list(c[0][5])
                if(r[1]!=' '):
                    rr="".join(r[1:3])
                    print(rr)
                else:
                    rr=r[1]
                if(r[0]=='T'):
                    if(rr=='1'):
                        print("Se abre la cerrdura 1")
                    elif(rr=='2'):
                        print("Se abre la cerrdura 2")
                    elif(rr=='3'):
                        print("Se abre la cerrdura 3")
                    elif(rr=='4'):
                        print("Se abre la cerrdura 4")
                    elif(rr=='5'):
                        print("Se abre la cerrdura 5")

                
            self.timer.start(5000)
        else:
            self.LB_Restado.setText("No exsiste registro del usuario")
        
    def alerta(self,a):
        D=self.BDC.BuscarDatosC(a,"renta")
        a=1
        self.BDC.ActualizaA(D[0][0],"renta",a)
        print(D)
        self.timer.start(5000)
    def Timer_int(self):
        R=self.HC.VerificaC()
        print(R)
        if R:
            self.Bandera=1
            self.timer2.stop()
            self.timer2.start(300000)
            self.timer.stop()
            print("Huella detectada")
            self.AbrirC()


        elif(R==False):
            #Lectura de los pines de la raspberry pi 4
            #Declaracion de pines de entrada
            if(self.Bandera==0):

                P1=0
                P2=0
                P3=0
                P4=0
                P5=0
                if(P1==1):
                    self.timer.stop()
                    A="T1"
                    self.alerta(A)
                if(P2==1):
                    A="T2"
                    self.alerta(A)
                if(P3==1):
                    A="T3"
                    self.alerta(A)
                if(P4==1):
                    A="T4"
                    self.alerta(A)
                if(P5==1):
                    A="T5"
                    self.alerta(A)
    def Timer2(self):
        self.Bandera=0        
        

if __name__ == "__main__":
    app=QApplication(sys.argv)
    interfaz=VentanaPrincipalC()
    interfaz.show()
    sys.exit(app.exec_())