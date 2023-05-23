#Autor: Vazquez Hernandez Jesus Alejandro
#Clase para la conexion a la base de datos desde una aplicacion de Python a Mysql por medio de SQL Mysqlconnector
import mysql.connector

class Comunicacion():

    def __init__(self,IP):
        self.ip=IP
        
        try:
            C=mysql.connector.connect( #Se genera una conexion a la base de datos 
                host=self.ip,#Se declara la direccion IP en donde esta alojada la base de datos
                #host='192.168.3.26',
                port=3306,#Se declara el puerto utilizado 
                user='locked',#Se declara el nombre del usuario
                password='AMREJ572502',#Se declara la contraseña
                db='ls'#Se selecciona la base de datos a consultar o modificar
            )
        except Exception as ex:#En caso de fallar la conexion
            print(ex)#Se muestra en consola el error    
        self.conexion=C

    #Funcion para acceder a la base de datos y mostrar los datos de una tabla
    def MostrarDatos(self,Dat):
        i=self.conexion.cursor()
        BD=("SELECT*FROM "+Dat)
        i.execute(BD)
        R=i.fetchall()
        return R
    def MostrarDatosRenta(self,Dat,B1,B2):
        i=self.conexion.cursor()
        BD=("SELECT*FROM "+Dat+" WHERE Tiene_Casillero =%s AND En_Proceso=%s")
        v=(B1,B2)
        i.execute(BD,v)
        R=i.fetchall()
        return R
    #Funcion para buscar un dato en la base de datos
    def BuscarDatos(self,Clave_A,Dat):
        i=self.conexion.cursor()
        #BD=("SELECT*FROM registro WHERE ClaveU={}".format(Clave_A))
        BD=("SELECT*FROM "+Dat+ " WHERE Clave_Unica=%s")#ClaveU es la columna a la que se accede
        C=(Clave_A,)
        i.execute(BD,C)
        Dato=i.fetchall()
        i.close()
        return Dato
    
    def BuscarDatosC(self,C,Dat):
        i=self.conexion.cursor()
        #BD=("SELECT*FROM registro WHERE ClaveU={}".format(Clave_A))
        BD=("SELECT*FROM "+Dat+ " WHERE Casillero=%s")
        C=(C,)
        i.execute(BD,C)
        Dato=i.fetchall()
        i.close()
        return Dato

    def EliminarDatos(self, Nom,Dat):
        i=self.conexion.cursor()
        #print(Nom)
        #print(Dat)
        BD= "DELETE FROM {} WHERE ClaveU = %s".format(Dat)
        C=(Nom,)
        i.execute(BD,C)

        self.conexion.commit()
        i.close()

    def EliminarDatosV(self, Nom,Dat):
        i=self.conexion.cursor()
        #print(Nom)
        #print(Dat)
        BD= "DELETE FROM {} WHERE id = %s".format(Dat)
        C=(Nom,)
        i.execute(BD,C)

        self.conexion.commit()
        i.close()
    
    #Funciones para la actualizacion de periodos
    def PeriodoR(self,Clav,Dat,IH,HC):
        i=self.conexion.cursor()
        BD= "UPDATE {} SET Inicio=%s, Fin=%s WHERE Proceso = %s".format(Dat)
        Proceso=(IH,HC,Clav)
        i.execute(BD,Proceso)
        self.conexion.commit()
        i.close() 

    def PeriodoP(self,Clav,Dat,FP):
        i=self.conexion.cursor()
        BD= "UPDATE {} SET Fecha_de_pago=%s WHERE Proceso = %s".format(Dat)
        Proceso=(FP,Clav)
        i.execute(BD,Proceso)
        self.conexion.commit()
        i.close() 
    
    def ActivaP(self,Clav,Dat,E):
        i=self.conexion.cursor()
        BD= "UPDATE {} SET Activo=%s WHERE Proceso = %s".format(Dat)
        Proceso=(E,Clav)
        i.execute(BD,Proceso)
        self.conexion.commit()
        i.close()

    def AR(self,N):
        i=self.conexion.cursor()
        BD="UPDATE renta SET En_Proceso=%s"
        H=(N,)
        i.execute(BD,H)
        self.conexion.commit()
        i.close()

    #Funcion para el registro de un nuevo administrador
    def RNAD(self,u,c):
        i=self.conexion.cursor()
        BD= "INSERT INTO administradores (Usuario, Contraseña) VALUES(%s,%s)"
        Proceso=(u,c,)
        i.execute(BD,Proceso)
        self.conexion.commit()
        i.close() 

    #Funcion para la depuracion de la base de datos
    def DepurarDatos(self, Nom):
        i=self.conexion.cursor()
        BD= "DELETE FROM renta WHERE Clave_unica = %s"
        C=(Nom,)
        i.execute(BD,C)
        self.conexion.commit()
        i.close() 
    def LiberaC(self,Clav,o,a):#Actualiza la huella
        i=self.conexion.cursor()
        BD= "UPDATE casilleros SET ocupado=%s, apartado=%s WHERE codigo = %s"
        Huella_C=(o,a,Clav)
        i.execute(BD,Huella_C)
        self.conexion.commit()
        i.close()           
    #Funciones para la notificacion de correros
    def ActualizaAcc(self,Clav,Dat,CR,CR2):#Actualiza la clave de recuperacion 
        i=self.conexion.cursor()
        BD= "UPDATE {} SET Tiene_Casillero=%s, En_Proceso=%s WHERE Clave_unica = %s".format(Dat)
        Huella_C=(CR,CR2,Clav)
        i.execute(BD,Huella_C)
        self.conexion.commit()
        i.close()
    
    def ActualizaC(self,Clav,Dat,CR):#Actualiza la clave de recuperacion 
        i=self.conexion.cursor()
        BD= "UPDATE {} SET Clave_R=%s WHERE Clave_unica = %s".format(Dat)
        Huella_C=(CR,Clav)
        i.execute(BD,Huella_C)
        self.conexion.commit()
        i.close()



    def ActualizaA(self,Clav,Dat,A):#Actualiza las alertas
        i=self.conexion.cursor()
        BD= "UPDATE {} SET alerta=%s WHERE Clave_unica = %s".format(Dat)
        Huella_C=(A,Clav)
        i.execute(BD,Huella_C)
        self.conexion.commit()
        i.close()
    def ActualizaF(self,Clav,Dat,I,F):#Actualiza las alertas
        i=self.conexion.cursor()
        BD= "UPDATE {} SET Fecha_de_apartado=%s, Fecha_de_atencion=%s WHERE Clave_unica = %s".format(Dat)
        Huella_C=(I,F,Clav)
        i.execute(BD,Huella_C)
        self.conexion.commit()
        i.close()    

    #Funciones para la manipulacion de huella en la base
    def ActualizaH(self,Clav,Dat,IH,HC):#Actualiza la huella
        i=self.conexion.cursor()
        BD= "UPDATE {} SET Id_huella=%s, Huella=%s WHERE Clave_unica = %s".format(Dat)
        Huella_C=(IH,HC,Clav)
        i.execute(BD,Huella_C)
        self.conexion.commit()
        i.close()
    def BuscarHuella(self):
        i=self.conexion.cursor()
        BD="SELECT*FROM usuario"
        i.execute(BD)
        R=i.fetchall()
        return R
    #Funcion para establecer el cupo
    def Cupo(self,N):
        i=self.conexion.cursor()
        BD="UPDATE horas SET Cupo=%s"
        H=(N,)
        i.execute(BD,H)
        self.conexion.commit()
        i.close()
