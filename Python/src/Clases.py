from dataclasses import dataclass, field
import numpy as np
@dataclass
class Celula:
    viva: int = field(default = 0)
    def alternar(self):
        self.viva= 1- self.viva

    def calcularProximoEstado(self,cantVecinos):
        if (self.viva==1) and(2<=cantVecinos<=3):
            return True
        elif (self.viva==0) and (cantVecinos==3):
            return True
        else: return False

    def estaViva(self):
        return (self.viva==1)

    def matar(self):
        self.viva=0
    
    def revivir(self):
        self.viva=1


@dataclass
class Tablero:
    ancho:int
    alto:int
    grilla:np.ndarray = field(init = False,default =None)
    generacion: int = field(init = False, default = 0)

    def __post_init__(self):
        self.reiniciar()
    
    def reiniciar(self):
        self.grilla = np.empty((self.alto,self.ancho),dtype = object)

        for f in range(self.alto):
            for c in range(self.ancho):
                self.grilla[f,c]=Celula()
            
        self.generacion=0
    
    def celulaEn(self, fila:int,columna:int):
        return self.grilla[fila,columna]
    
    def alternarEn(self,fila:int,columna:int):
        self.grilla[fila,columna].alternar()
    
    def poblacion(self):
        total=0
        for celula in self.grilla.flat: 
            if celula.estaViva():
                total+=1
        return total
    def contarVecinosEn(self, fila: int, columna: int) -> int:
            total = 0
            for f_offset in range(-1, 2):
                for c_offset in range(-1, 2):
                    
                    vecino_f = fila + f_offset
                    vecino_c = columna + c_offset
                    
                    if f_offset == 0 and c_offset == 0:
                        continue
                    
                    if (0 <= vecino_f < self.alto) and (0 <= vecino_c < self.ancho):
                        
                    
                        if self.celulaEn(vecino_f, vecino_c).estaViva():
                            total += 1
            return total

    def evolucionar(self):
        nuevos_estados = np.empty((self.alto, self.ancho), dtype=bool)
        for f in range(self.alto):
            for c in range(self.ancho):
                celula= self.celulaEn(f,c)
                vecinos= self.contarVecinosEn(f,c)
                proximo_estado=celula.calcularProximoEstado(vecinos)
                nuevos_estados[f,c]=proximo_estado
        for f in range(self.alto):
            for c in range(self.ancho):
                celula = self.celulaEn(f, c)
                debe_vivir = nuevos_estados[f, c]
                
                if debe_vivir:
                    celula.revivir()
                else:
                    celula.matar()
        self.generacion += 1
    

