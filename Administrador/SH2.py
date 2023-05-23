#Sensor de huella digital

from pyfingerprint.pyfingerprint import PyFingerprint
from pyfingerprint.pyfingerprint import FINGERPRINT_CHARBUFFER1
from pyfingerprint.pyfingerprint import FINGERPRINT_CHARBUFFER2
from cryptography.fernet import Fernet
import base64
import serial
import time 
#uart = serial.Serial()
finger=PyFingerprint("COM6",57600, 0xFFFFFFFF, 0x00000000)

class huella():
    def GuardarHuella(self):
        try:
            
        
            if(finger.verifyPassword()==False):
                raise ValueError('Pasword incorrecto')
        
        except Exception as e:
            print('The fingerprint sensor could not be initialized!')
            print('Exception message: ' + str(e))
            exit(1)
        
        #espera a que el usuario coloque 
        while(finger.readImage()==False):
            pass
        
        #Se captura la huella y se comienza la manipulacion de esta
        finger.convertImage(0x01)
        HBY=finger.downloadCharacteristics(0x01)
        
        clave =Fernet.generate_key()
        claveC=clave.decode('utf-8')
        CR=str(claveC)
        fernet = Fernet(clave)
        
        HC=fernet.encrypt(bytes(HBY))
        HCH=HC.decode('utf-8')
        HR=str(HCH)

        
        D=[CR,HR]
        
        return D
    
    def VerificaC(self):
        HuellaC=False
        for i in range(10):
            if (finger.readImage()!=False):
                HuellaC=True
                break
            time.sleep(.1)
        
        return HuellaC
    
    def comparaHuellas(self,HC):
        try:
            
        
            if(finger.verifyPassword()==False):
                raise ValueError('Pasword incorrecto')
        
        except Exception as e:
            print('The fingerprint sensor could not be initialized!')
            print('Exception message: ' + str(e))
            exit(1)
        
        while(finger.readImage()==False):
            pass
        finger.convertImage(FINGERPRINT_CHARBUFFER2)

        i=0
        flag=-1

        for huella in HC:
            if(huella[6]!=' ' and huella[6] is not None):
                
                C=huella[5]#El valor dentro del corchete representa la columna
                CC=C.encode('utf-8')
                H=huella[6]
                HH=H.encode('utf-8')
                fernet=Fernet(CC)
                HD=fernet.decrypt(HH)
                HDD=list(HD)
                finger.uploadCharacteristics(FINGERPRINT_CHARBUFFER1,HDD)
                C=finger.compareCharacteristics()
                if(C>0):
                    flag=i
                
            i+=1
        #print(flag)
        #print(HC[flag][0])
        if (flag==-1):
            r=' '
        else:
            r=HC[flag][0]
        return(r)


        #Si
       # i=0
        #flag=0
        #finger.convertImage(FINGERPRINT_CHARBUFFER2)
        #PH=0x01

        #for huella in HC:
         #   H=str(huella[2])
          #  HDD=eval(H)
           # finger.uploadCharacteristics(FINGERPRINT_CHARBUFFER1,HDD)
            #C=finger.compareCharacteristics()
            #if(C>0):
             #   flag=i
            #i+=1
          
        #print(flag)
        #print(HC[flag][0])