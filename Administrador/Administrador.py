#from PyQt5 import QtWidgets, uic
import sys
import typing
from PyQt5 import QtCore, QtGui, QtWidgets

from PyQt5.QtCore import QPropertyAnimation, QEasingCurve,QTimer,Qt, QRegExp
 
from conexion_mysqlconnector import Comunicacion
from PyQt5.QtWidgets import QApplication, QMainWindow, QTableWidget, QTableWidgetItem,QHeaderView, QWidget
from PyQt5.QtGui import QFont, QRegExpValidator
from PyQt5.uic import loadUi
import requests
import random
import string
from SH2 import huella
import time
import datetime
from datetime import datetime, timedelta


class Login(QMainWindow):
    def __init__(self):
        super(Login, self).__init__()
        loadUi("Login.ui",self) 
        #Configuracion de la ventana
        self.setWindowFlag(QtCore.Qt.FramelessWindowHint)
        self.setWindowOpacity(1)     
        #Tamaño de la ventana
        self.gripSize=10
        self.grip=QtWidgets.QSizeGrip(self)
        self.grip.resize(self.gripSize,self.gripSize)
        #Botones para configurar el tamaño de la ventana
        self.Btn_ML.hide()
        self.Btn_LogMax.clicked.connect(self.Max_V)
        self.Btn_LM.clicked.connect(self.Min_V)
        self.Btn_ML.clicked.connect(self.Nom_V)
        self.Btn_LEx.clicked.connect(lambda: self.close())

        #Mover la ventana
        self.frame_s.mouseMoveEvent=self.mover_V

        self.Btn_Aceptar.clicked.connect(self.VAdm)

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
                self.Btn_LogMax.hide()
                self.Btn_ML.show()
            else:
                self.showNormal()
                self.Btn_ML.hide()
                self.Btn_LogMax.show()
    #Ventana
    def Max_V(self):
        self.showMaximized()#Se maximiza la pantalla
        self.Btn_LogMax.hide()
        self.Btn_ML.show() 

    def Min_V(self):     
        self.showMinimized()

    def Nom_V(self):
        self.showNormal()
        self.Btn_ML.hide()
        self.Btn_LogMax.show()
    
    #Funcion para inicializar la pantalla principal
    def VAdm(self):
        flag=0
        ip=self.LE_IPS.text()
        BD=Comunicacion(ip)
        D=BD.MostrarDatos("Administradores")
        i=len(D)
        for dat in D:
            if self.LE_Admin.text()==dat[1] and self.LE_AContra.text()==dat[2]:
                flag=1
        
        if(flag==1):
            print(self.LE_IPS.text())
            self.hide()
            self.main_window=VentanaPrincipal(ip)
            self.main_window.show()
        else:
            self.LB_Not.setText("Usuario o contraseña incorrecto")    
            


class VentanaPrincipal(QMainWindow):
    def __init__(self,IP):
        super(VentanaPrincipal, self).__init__()
        loadUi("LS.ui",self)

        #Configuracion de la ventana
        self.setWindowFlag(QtCore.Qt.FramelessWindowHint)
        self.setWindowOpacity(1)

        #Tamaño de la ventana
        self.gripSize=10
        self.grip=QtWidgets.QSizeGrip(self)
        self.grip.resize(self.gripSize,self.gripSize)

        #Mover la ventana
        self.FR_T.mouseMoveEvent=self.mover_V

        #Creacion del objeto para la conexion con la base de datos
        self.ip=IP
        
        #Creacion del objeto para utilizar el sensor de huella digital
        self.H=huella()
        #definicion de eventos
        #Menu
        self.Btn_Menu.clicked.connect(self.MoverM)
        
        self.Btn_Verificar.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.Pg_Datos))
        self.Btn_Registrar.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.Pg_Registro))
        self.Btn_Horario.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.Pg_Horas))
        self.Btn_Ajustes.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.Pg_Mantenimiento))
        self.Btn_Ayuda.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.Pg_Ayuda))
        #Ventana consultar
        self.CB_Con.currentIndexChanged.connect(self.Mostrar_DCB)
        

        _translate = QtCore.QCoreApplication.translate

        #Definicion de eventos de las distintas pestañas del menu
        #-------------------Pestaña de consultar
        #Combo Box
        self.CB_Con.setFont(self.fuente())
        self.CB_Con.addItem("")
        self.CB_Con.addItem("")
        self.CB_Con.addItem("")
        self.CB_Con.addItem("")
        self.CB_Con.setItemText(0, "")
        self.CB_Con.setItemText(1, _translate("MainWindow", "Usuarios"))
        self.CB_Con.setItemText(2, _translate("MainWindow", "Renta"))
        self.CB_Con.setItemText(3, _translate("MainWindow", "Renovacion"))
        #Boton de refrescar
        self.Btn_RCon.clicked.connect(self.Mostrar_DCB)
        #-------------------Registrar huella
        #Boton buscar alumno para el registro de huella
        self.CB_Acc.setFont(self.fuente())
        self.CB_Acc.addItem("")
        self.CB_Acc.addItem("")
        self.CB_Acc.setItemText(0, _translate("MainWindow", "Si"))
        self.CB_Acc.setItemText(1, _translate("MainWindow", "No"))
        self.PB_RBuscar.clicked.connect(self.BuscarA)
        self.Btn_ConAH.clicked.connect(self.acceso)
        self.PB_RHuella.clicked.connect(self.RegistraHuella)
        # Configurar validador para solo aceptar números
        regex = QRegExp("[0-9]+")
        val=QRegExpValidator(regex)
        self.LE_RBAl.setValidator(val)

        #------------------------------Horarios
        self.Btn_AR.clicked.connect(self.Renta)
        self.Btn_APR.clicked.connect(self.Renovacion)
        self.Btn_RP.clicked.connect(self.PAct)
        self.Btn_RHD.clicked.connect(self.ACupo)
        
        #Mantenimiento
        self.CB_Mantenimiento.currentIndexChanged.connect(self.MRR)
        self.Btn_RNA.clicked.connect(self.AAdmin)
        self.Btn_MAceptar.clicked.connect(self.Depuracion)

        #Ayuda
        self.CB_AyudaO.currentIndexChanged.connect(self.ANavega)
        #self.CBAyudaO
        #Botones para configurar el tamaño de la ventana
        self.Btn_Mpes.hide()
        self.Btn_Maximizar.clicked.connect(self.Max_V)
        self.Btn_Minimizar.clicked.connect(self.Min_V)
        self.Btn_Mpes.clicked.connect(self.Nom_V)
        self.Btn_Cerrar.clicked.connect(lambda: self.close())
        self.Btn_NA.clicked.connect(self.Act)
        self.Btn_ND.clicked.connect(self.Desac)

    #Definicion de funciones
    #Funcion para el timer
    def Act(self):
        #Se inicializa un timer
        self.BD=Comunicacion(self.ip)
        self.timer=QTimer(self)
        self.timer.timeout.connect(self.Timer_int)
        self.timer.start(10000)
    def Desac(self):
        self.timer.stop()
    def Timer_int(self):
        N=self.Not()
        print(N)
        if (N!=0):
            C=self.BD.MostrarDatos("verificacion")
            #self.timer.stop()
            if(C[0][3]==0):

                l=6
                CP=string.ascii_letters+string.digits
                clave=''.join(random.choice(CP)for _ in range(l))
                print(clave)
                print(C[0][2])
            else:
                clave="Se ha ingresado a tu casillero"
            self.M_correo(C[0][2],clave,C[0][0],C[0][1],C[0][3])
        else:
            print("pasele")      
    def Not(self):
        C=self.BD.MostrarDatos("verificacion")
        print(C)
        g=len(C)
        return g
    
    #funciones de la barra superior
   
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

    def MoverM(self):#Funcion para desplegar el menu
        if True:
            width=self.FR_MenuD.width()
            normal=0
            if width==0:
                extender=200
            else:
                extender=normal
            self.animacion=QPropertyAnimation(self.FR_MenuD,b'minimumWidth')
            self.animacion.setDuration(300)
            self.animacion.setStartValue(width)
            self.animacion.setEndValue(extender)
            self.animacion.setEasingCurve(QtCore.QEasingCurve.InOutQuart)
            self.animacion.start()

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
    
    #Funciones Menu
    #esta funcion se puede descartar
    def Mostrar_D(self):
        datos=self.BD.MostrarDatos()
        i=len(datos)
        self.Tw_Con.setRowCount(i)
        tablerow=0

        for row in datos:
            
            D=str(row[0])
            
            self.Tw_Con.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[0])))#Se obtiene el dato y se coloca en la tabla de la interfaz
            self.Tw_Con.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)#Se centra el dato
            self.Tw_Con.setItem(tablerow,1,QtWidgets.QTableWidgetItem(row[1]))
            self.Tw_Con.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
            self.Tw_Con.setItem(tablerow,2,QtWidgets.QTableWidgetItem(row[2]))
            self.Tw_Con.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
            self.Tw_Con.setItem(tablerow,3,QtWidgets.QTableWidgetItem(row[3]))
            self.Tw_Con.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
            self.Tw_Con.setItem(tablerow,4,QtWidgets.QTableWidgetItem(str(row[4])))
            self.Tw_Con.item(tablerow,4).setTextAlignment(QtCore.Qt.AlignCenter)
            tablerow+=1
            
        #Se obtiene la fuente
        self.Tw_Con.setFont(self.fuente())
        #se adapta el tamaño al contenido
        self.Tw_Con.resizeColumnsToContents()
        self.Tw_Con.resizeRowsToContents()
        
    def Mostrar_DCB(self):#esta es la buena
        self.BD=Comunicacion(self.ip)
        Indicador=""
        #Tabla=self.CB_Con.currentText()
        v=self.CB_Con.currentIndex()
        if(v==0):
            Tabla=""
        elif(v==1):
            Tabla="usuario"
        elif(v==2):
            Tabla="renta"
        elif(v==3):
            Tabla="renta"
            Indicador="renovacion"
        
        print(v)

        self.Tw_Con.clear()
        #Tabla=str(Tabla)
        if Tabla!="":
            tablerow=0
            if Tabla=="usuario":
                datos=self.BD.MostrarDatos(Tabla)
                i=len(datos)
                self.Tw_Con.setRowCount(i)
                self.Tw_Con.setColumnCount(5)
                for row in datos:
            
                    if(row[5]!=None and row[5]!=""):
                        RH="Si" 
                    else:
                        RH="No" 
                    if row[7]==1:
                        VY="Si"
                    else:
                        VY="No" 


                    self.Tw_Con.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[0])))#Se obtiene el dato y se coloca en la tabla de la interfaz
                    self.Tw_Con.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)#Se centra el dato
                    self.Tw_Con.setItem(tablerow,1,QtWidgets.QTableWidgetItem(row[1]))
                    self.Tw_Con.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Con.setItem(tablerow,2,QtWidgets.QTableWidgetItem(row[2]))#checar en respaldo
                    self.Tw_Con.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Con.setItem(tablerow,3,QtWidgets.QTableWidgetItem(str(RH)))
                    self.Tw_Con.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Con.setItem(tablerow,4,QtWidgets.QTableWidgetItem(str(VY)))
                    self.Tw_Con.item(tablerow,4).setTextAlignment(QtCore.Qt.AlignCenter)

                    tablerow+=1
            elif (Tabla=="renta" and Indicador==""):
                datos=self.BD.MostrarDatosRenta(Tabla,1,0)
                i=len(datos)
                self.Tw_Con.setRowCount(i)
                self.Tw_Con.setColumnCount(6)
                for row in datos:

                    if (row[3]==1 and row[4]==0):

                        self.Tw_Con.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[0])))#Se obtiene el dato y se coloca en la tabla de la interfaz
                        self.Tw_Con.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)#Se centra el dato
                        self.Tw_Con.setItem(tablerow,1,QtWidgets.QTableWidgetItem(row[1]))
                        self.Tw_Con.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,2,QtWidgets.QTableWidgetItem(row[2]))
                        self.Tw_Con.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,3,QtWidgets.QTableWidgetItem(row[5]))
                        self.Tw_Con.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,4,QtWidgets.QTableWidgetItem(str(row[6])))
                        self.Tw_Con.item(tablerow,4).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,5,QtWidgets.QTableWidgetItem(str(row[7])))
                        self.Tw_Con.item(tablerow,5).setTextAlignment(QtCore.Qt.AlignCenter)

                    tablerow+=1    
            if Indicador=="renovacion":
                datos=self.BD.MostrarDatosRenta(Tabla,1,1)
                i=len(datos)
                self.Tw_Con.setRowCount(i)
                print("XD")
                print(i)
                self.Tw_Con.setColumnCount(6)
                for row in datos:
                    
                    if (row[4]==1 and row[3]==1):

                        self.Tw_Con.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[0])))#Se obtiene el dato y se coloca en la tabla de la interfaz
                        self.Tw_Con.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)#Se centra el dato
                        self.Tw_Con.setItem(tablerow,1,QtWidgets.QTableWidgetItem(row[1]))
                        self.Tw_Con.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,2,QtWidgets.QTableWidgetItem(row[2]))
                        self.Tw_Con.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,3,QtWidgets.QTableWidgetItem(row[5]))
                        self.Tw_Con.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,4,QtWidgets.QTableWidgetItem(str(row[6])))
                        self.Tw_Con.item(tablerow,4).setTextAlignment(QtCore.Qt.AlignCenter)
                        self.Tw_Con.setItem(tablerow,5,QtWidgets.QTableWidgetItem(str(row[7])))
                        self.Tw_Con.item(tablerow,5).setTextAlignment(QtCore.Qt.AlignCenter)
                        print(row[4])

                    tablerow+=1                 
            
        #Se obtiene la fuente
        self.Tw_Con.setFont(self.fuente())
        #se adapta el tamaño al contenido
        self.Tw_Con.resizeColumnsToContents()
        self.Tw_Con.resizeRowsToContents()
        self.EncabezadoT()
        self.AjustarT()
               
    #Pestaña de la huella      
    def BuscarA(self):
        self.BD=Comunicacion(self.ip)
        id_Alumno=self.LE_RBAl.text().upper()
        if id_Alumno!="":

            self.id_Alumno=int(id_Alumno)
            Tabla="usuario"
            Tabla2="renta"
            self.RecuperarU=self.BD.BuscarDatos(self.id_Alumno,Tabla)
            self.RecuperarR=self.BD.BuscarDatos(self.id_Alumno,Tabla2)
            if len(self.RecuperarU)!=0 and len(self.RecuperarR)!=0:
                self.LB_RUs.setText(self.RecuperarU[0][1])
                self.LB_FH.setText(str(self.RecuperarR[0][7])+" Hrs")
                self.LB_Restado.setText("Usuario localizado")
            else:
                self.LB_Restado.setText("No exsiste registro del usuario")
                self.LB_FH.setText("N/A")
                self.LB_RUs.setText("N/A")
        else:
            self.LB_Restado.setText("Ingrese una clave valida")
            self.LB_FH.setText("")
            self.LB_RUs.setText("")
    def RegistraHuella(self):
        if (self.LB_Restado.text()=="Usuario localizado"):
            
            F=self.H.GuardarHuella()
            self.BD.ActualizaH(self.LE_RBAl.text(),"usuario",F[0],F[1])

    def acceso(self):
        id_Alumno=self.LE_RBAl.text().upper()
        e=self.CB_Acc.currentIndex()
        D=self.BD.BuscarDatos(self.id_Alumno,"renta")
        if (self.LB_Restado.text()=="Usuario localizado"):
            if(e==0):
                self.BD.ActualizaAcc(self.id_Alumno,"renta",1,0)
                self.BD.ActualizaF(self.id_Alumno,"renta","0000-00-00 00:00:00","0000-00-00 00:00:00")
                self.BD.LiberaC(D[0][5],1,0)
            elif(e==1):
                self.BD.ActualizaAcc(self.id_Alumno,"renta",1,1)
       
      #Checar si se puede reutilizar      
    def BEliminarR(self):
        TablaE=self.CB_ETDatos.currentText()
        self.DE=TablaE
        #self.CB_ETDatos.clear()
        id_Alumno=self.LE_ERegistro.text()
        id_Alumno=int(id_Alumno)
        if TablaE!="":
            datos=self.BD.BuscarDatos(id_Alumno,TablaE)
            Usuario=self.BD.BuscarDatos(id_Alumno,TablaE)
            
            self.Tw_Edatos.setRowCount(len(datos))
            if len(datos)==0:
                self.LB_Estdo.setText("No existe")
            else:
                self.LB_Estdo.setText(" ")
                self.LB_Estdo.setText("Datos del alumno seleccionado")
                self.Tw_Edatos.setColumnCount(len(datos[0]))#V

            tablerow=0
            for row in datos:
                self.borarR=row[0]
                
                self.Tw_Edatos.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[0])))
                self.Tw_Edatos.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)
                self.Tw_Edatos.setItem(tablerow,1,QtWidgets.QTableWidgetItem(row[1]))
                self.Tw_Edatos.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
                self.Tw_Edatos.setItem(tablerow,2,QtWidgets.QTableWidgetItem(row[2]))
                self.Tw_Edatos.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
                self.Tw_Edatos.setItem(tablerow,3,QtWidgets.QTableWidgetItem(row[3]))
                self.Tw_Edatos.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
                self.Tw_Edatos.setItem(tablerow,4,QtWidgets.QTableWidgetItem(str(row[4])))
                self.Tw_Edatos.item(tablerow,4).setTextAlignment(QtCore.Qt.AlignCenter)
                tablerow+=1
            self.AjustarT() 
            #Se obtiene la fuente
            self.Tw_Edatos.setFont(self.fuente()) 

    def EliminarS(self):
        self.flagR=self.Tw_Edatos.currentRow()
        if self.flagR==0:
            self.Tw_Edatos.removeRow(0)
            self.BD.EliminarDatos(self.borarR,self.CB_ETDatos.currentText())
            self.LB_Estdo.setText("Registro eliminado")
            self.LE_ERegistro.setText("")
            self.CB_ETDatos.clear()

    #Funciones para modificar los periodos de renta y renovacion
    def Renta(self):
        self.BD=Comunicacion(self.ip) 
        datos=self.BD.MostrarDatos("periodos")   
        i=datetime.now()
        SD=timedelta(days=2)
        if self.DTE_IR.dateTime()>i:
            a=self.DTE_IR.dateTime()
            aa=a.toPyDateTime()
            c=a.date()
            cc=c.addDays(1)
            ccc=c.addDays(3)
            FP1=cc.toString(Qt.ISODate)
            FP2=ccc.toString(Qt.ISODate)
            Ipro=aa+SD
            inicio=self.DTE_IR.text()
            inicio2=str(Ipro)
            if self.DTE_FR.dateTime()>self.DTE_IR.dateTime():
                b=self.DTE_FR.dateTime()
                bb=b.toPyDateTime()
                Fpro=bb+SD
                fin=self.DTE_FR.text()
                fin2=str(Fpro)
                self.BD.PeriodoR("renta","periodos",inicio,fin)
                self.BD.PeriodoR("prorroga","periodos",inicio2,fin2)
                self.BD.PeriodoP("renta","periodos",FP1)
                self.BD.PeriodoP("prorroga","periodos",FP2)
    def Renovacion(self):
        self.BD=Comunicacion(self.ip) 
        datos=self.BD.MostrarDatos("periodos")   
        i=datetime.now()
        if self.DTE_IPR.dateTime()>i:
            RR=self.DTE_IPR.dateTime()
            R1=RR.date()
            RF=R1.addDays(1)
            FPR1=RF.toString(Qt.ISODate)
            inicio=self.DTE_IPR.text()
            if self.DTE_FPR.dateTime()>self.DTE_IPR.dateTime():
                fin=self.DTE_FPR.text()
                self.BD.PeriodoR("renovacion","periodos",inicio,fin) 
                self.BD.PeriodoP("renovacion","periodos",FPR1)       
    
    def PAct(self):
        self.Flag=1
        self.BD=Comunicacion(self.ip) 
        self.Tw_Periodos.clear() 
        datos=self.BD.MostrarDatos("periodos")
        i=len(datos)
        self.Tw_Periodos.setRowCount(i)
        self.Tw_Periodos.setColumnCount(4)
        tablerow=0
        for row in datos:
            self.borarR=row[0]
            if(row[2]==1):
                est="activo"
            else:
                est="inactivo"
                
            self.Tw_Periodos.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[1])))
            self.Tw_Periodos.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)
            self.Tw_Periodos.setItem(tablerow,1,QtWidgets.QTableWidgetItem(str(est)))
            self.Tw_Periodos.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
            self.Tw_Periodos.setItem(tablerow,2,QtWidgets.QTableWidgetItem(str(row[3])))
            self.Tw_Periodos.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
            self.Tw_Periodos.setItem(tablerow,3,QtWidgets.QTableWidgetItem(str(row[4])))
            self.Tw_Periodos.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
            tablerow+=1
        #Se obtiene la fuente
        self.Tw_Con.setFont(self.fuente())
        #se adapta el tamaño al contenido
        self.Tw_Con.resizeColumnsToContents()
        self.Tw_Con.resizeRowsToContents()
        self.EncabezadoTT(1)
        self.AjustarT()
       
    def ACupo(self):
       EP=0
       EPR=0
       EPRP=0
       self.BD=Comunicacion(self.ip) 
       datos=self.BD.MostrarDatos("periodos") 
       i=datetime.now() 
       j=datos[0][3]
       k=datos[1][3]
       L=datos[0][4] 
       M=datos[1][4] 
       N=datos[2][3]
       O=datos[2][4]      
       if (i>=j and i<L and datos[1][2]!=1):
            EP=1
       if (i>=k and i<M and datos[0][2]!=1):
           EPR=1
           self.BD.AR(1)
       if (i>=N and i<O and datos[1][2]!=1 and datos[0][2]!=1):
           EPRP=1

       self.BD.ActivaP("renta","periodos",EP)
       self.BD.ActivaP("renovacion","periodos",EPR)
       self.BD.ActivaP("prorroga","periodos",EPRP)
       cupo=self.LE_EC.text().upper()
       if cupo!="":
           self.BD.Cupo(cupo)  

#--------------------Funciones para la pestaña de manetnimiento
    def MRR(self):
        self.BD=Comunicacion(self.ip)
        d=self.BD.MostrarDatos("periodos") 
        Indicador=""
        v=self.CB_Mantenimiento.currentIndex()
        if(v==0):
            Tabla=""
            self.Tw_Mantenimiento.clear()
        elif(v==1):
            Tabla="renta"
            if d[0][2]==1 or d[1][2]==1:
              self.Btn_MAceptar.setEnabled(False)
            else:
                self.Btn_MAceptar.setEnabled(True)  
        elif(v==2):
            Tabla="renta"
            Indicador="renovacion"
            if d[1][2]==1 or d[0][2]==1:
              self.Btn_MAceptar.setEnabled(False)
            else:
                self.Btn_MAceptar.setEnabled(True)              
        if Tabla!="":
            tablerow=0
            if Indicador=="renovacion":

                datos=self.BD.MostrarDatosRenta(Tabla,0,1)
                i=len(datos)
                self.Tw_Mantenimiento.setRowCount(i)
                self.Tw_Mantenimiento.setColumnCount(6)
                for row in datos:
                    self.Tw_Mantenimiento.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[0])))#Se obtiene el dato y se coloca en la tabla de la interfaz
                    self.Tw_Mantenimiento.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)#Se centra el dato
                    self.Tw_Mantenimiento.setItem(tablerow,1,QtWidgets.QTableWidgetItem(row[1]))
                    self.Tw_Mantenimiento.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,2,QtWidgets.QTableWidgetItem(row[2]))#checar en respaldo
                    self.Tw_Mantenimiento.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,3,QtWidgets.QTableWidgetItem(row[5]))
                    self.Tw_Mantenimiento.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,4,QtWidgets.QTableWidgetItem(str(row[6])))
                    self.Tw_Mantenimiento.item(tablerow,4).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,5,QtWidgets.QTableWidgetItem(str(row[7])))
                    self.Tw_Mantenimiento.item(tablerow,5).setTextAlignment(QtCore.Qt.AlignCenter)
                    tablerow+=1
            if (Tabla=="renta" and Indicador==""):
                datos=self.BD.MostrarDatosRenta(Tabla,0,1)
                i=len(datos)
                self.Tw_Mantenimiento.setRowCount(i)
                self.Tw_Mantenimiento.setColumnCount(6)
                for row in datos:
                    self.Tw_Mantenimiento.setItem(tablerow,0,QtWidgets.QTableWidgetItem(str(row[0])))#Se obtiene el dato y se coloca en la tabla de la interfaz
                    self.Tw_Mantenimiento.item(tablerow,0).setTextAlignment(QtCore.Qt.AlignCenter)#Se centra el dato
                    self.Tw_Mantenimiento.setItem(tablerow,1,QtWidgets.QTableWidgetItem(row[1]))
                    self.Tw_Mantenimiento.item(tablerow,1).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,2,QtWidgets.QTableWidgetItem(row[2]))#checar en respaldo
                    self.Tw_Mantenimiento.item(tablerow,2).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,3,QtWidgets.QTableWidgetItem(row[5]))
                    self.Tw_Mantenimiento.item(tablerow,3).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,4,QtWidgets.QTableWidgetItem(str(row[6])))
                    self.Tw_Mantenimiento.item(tablerow,4).setTextAlignment(QtCore.Qt.AlignCenter)
                    self.Tw_Mantenimiento.setItem(tablerow,5,QtWidgets.QTableWidgetItem(str(row[7])))
                    self.Tw_Mantenimiento.item(tablerow,5).setTextAlignment(QtCore.Qt.AlignCenter)
                    tablerow+=1
        self.Tw_Mantenimiento.setFont(self.fuente())
        self.Tw_Mantenimiento.resizeColumnsToContents()
        self.Tw_Mantenimiento.resizeRowsToContents()
        self.EncabezadoT3()
        self.AjustarT()

    #Depurar base de datos
    def Depuracion(self):
        self.BD=Comunicacion(self.ip)
        Indicador=""
        v=self.CB_Mantenimiento.currentIndex()
        if(v==0):
            Tabla=""
            self.Tw_Mantenimiento.clear()
        elif(v==1):
            Tabla="renta" 
        elif(v==2):
            Tabla="renta"
            Indicador="renovacion"
        if Tabla!="":
            if Indicador=="renovacion":
                datos=self.BD.MostrarDatosRenta(Tabla,0,1)
                for D in datos:
                    print(D[5])
                    self.BD.LiberaC(D[5],0,0)
                    self.BD.DepurarDatos(D[0]) 
                self.Tw_Mantenimiento.clear()    
            if (Tabla=="renta" and Indicador==""):
                datos=self.BD.MostrarDatosRenta(Tabla,0,1) 
                for D in datos:
                    self.BD.LiberaC(D[5],0,0)
                    self.BD.DepurarDatos(D[0])
                self.Tw_Mantenimiento.clear()                                                                      
    #Añadir a una nuevo administrador
    
    def AAdmin(self):
        flag=0
        D=self.BD.MostrarDatos("Administradores")
        i=len(D)
        for dat in D:
            if self.LE_AC.text()==dat[1] and self.LE_ACC.text()==dat[2]:
                flag=1
        
        if(flag==1):
            NA=self.LE_RNA.text()
            NC=self.LE_RNAC.text()
            self.BD.RNAD(NA,NC)
            self.LB_NM.setText("Administrador registrado") 
            self.LE_AC.clear()
            self.LE_ACC.clear()
            self.LE_RNA.clear()
            self.LE_RNAC.clear()
        else:
            self.LB_NM.setText("Usuario o contraseña incorrecto") 
    
    def ANavega(self,index):
        self.stackedWidget_2.setCurrentIndex(index)

    def NotificacionE(self):
        self.LB_Estdo.setText("Consulta en: "+self.CB_ETDatos.currentText())
         
    def M_correo(self,correo,clave,id,CA,N):
        
        url='http://localhost/phpmyadmin/enviar_email.php'
        DU={'destinatario': correo,'clave': clave}
        respuesta=requests.post(url,data=DU)
        print(respuesta.text)
        R=respuesta.ok
        #respuesta="El correo electronico se ha enviado correctamente." 
        if respuesta.status_code == 200:
            print("aqui andamos")
            
            self.BD.EliminarDatosV(id,"verificacion")
            if(N==0):
                self.BD.ActualizaC(CA,"usuario",clave) 
                #self.timer.start(10000)
        
                     


    #Se define una funcion para la fuente a utilizar 
    def fuente(self):
        font = QFont("Times New Roman", 12)
        return font
    
    def AjustarT(self):
        #Se redimensionan las tablas para ajustar en la ventana
        self.Tw_Con.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.Tw_Con.verticalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.Tw_Periodos.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.Tw_Periodos.verticalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.Tw_Mantenimiento.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.Tw_Mantenimiento.verticalHeader().setSectionResizeMode(QHeaderView.Stretch)
    
    def EncabezadoT(self):
        v=self.CB_Con.currentIndex()
        if(v==0):
            CB=""
            
        elif(v==1):
            CB="usuario"
            
        elif(v==2):
            CB="renta"
            
        elif(v==3):
            CB="renovacion"
            
        j=[""]
        c=0
        #CB=self.CB_Con.currentText()
        if CB=="":
            j=[""]
        else:
            
            if CB=="usuario":
                self.Tw_Con.setColumnCount(5)
                j=["Clave Unica", "Nombre","Correo","Registro de huella","verificacion"]
                
            elif CB=="renta":
                self.Tw_Con.setColumnCount(6)
                j=["Clave Unica", "Nombre","Correo","Casillero","Hora de apartado","Hora de atencion"]
            elif CB=="renovacion":
                self.Tw_Con.setColumnCount(5)
                j=["Clave Unica", "Nombre","Correo","Casillero","Hora de atencion"]

        
        for i in range(self.Tw_Con.columnCount()):
          
          if c < len(j):
            item = QtWidgets.QTableWidgetItem(j[c])
            
            item.setTextAlignment(QtCore.Qt.AlignHCenter|QtCore.Qt.AlignVCenter|QtCore.Qt.AlignCenter)
            self.Tw_Con.setHorizontalHeaderItem(i, item)
            c=c+1

        header = self.Tw_Con.horizontalHeader()
        header.setFont(self.fuente())

    def EncabezadoTT(self,T):    
        
        if(T==1):
            CB="Periodos"
        j=[""]
        c=0
        #CB=self.CB_Con.currentText()
        if CB=="":
            j=[""]
        else:
            if CB=="Periodos":
                self.Tw_Periodos.setColumnCount(4)
                j=["Proceso", "Estado","Inicio","Fin"]
            
        for i in range(self.Tw_Periodos.columnCount()):
          
          if c < len(j):
            item = QtWidgets.QTableWidgetItem(j[c])
            
            item.setTextAlignment(QtCore.Qt.AlignHCenter|QtCore.Qt.AlignVCenter|QtCore.Qt.AlignCenter)
            self.Tw_Periodos.setHorizontalHeaderItem(i, item)
            c=c+1

        header = self.Tw_Periodos.horizontalHeader()
        header.setFont(self.fuente())

    def EncabezadoT3(self):
        v=self.CB_Mantenimiento.currentIndex()
        if(v==0):
            CB=""
            
        elif(v==1):
            CB="renta"
            
        elif(v==2):
            CB="renovacion"
            
        j=[""]
        c=0
        #CB=self.CB_Con.currentText()
        if CB=="":
            j=[""]
        else:
                
            if CB=="renta":
                self.Tw_Mantenimiento.setColumnCount(6)
                j=["Clave Unica", "Nombre","Correo","Casillero","Hora de apartado","Hora de atencion"]
            elif CB=="renovacion":
                self.Tw_Mantenimiento.setColumnCount(5)
                j=["Clave Unica", "Nombre","Correo","Casillero","Hora de atencion"]

        
        for i in range(self.Tw_Mantenimiento.columnCount()):
          
          if c < len(j):
            item = QtWidgets.QTableWidgetItem(j[c])
            
            item.setTextAlignment(QtCore.Qt.AlignHCenter|QtCore.Qt.AlignVCenter|QtCore.Qt.AlignCenter)
            self.Tw_Mantenimiento.setHorizontalHeaderItem(i, item)
            c=c+1

        header = self.Tw_Mantenimiento.horizontalHeader()
        header.setFont(self.fuente())

if __name__ == "__main__":
    app=QApplication(sys.argv)
    Log=Login()
    Log.show()
    #interfaz=VentanaPrincipal()
    #interfaz.show()
    sys.exit(app.exec_())