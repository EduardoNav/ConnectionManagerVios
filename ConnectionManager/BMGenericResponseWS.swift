//
//  BMGenericResponseWS.swift
//  BienvenidoMexico
//
//  Created by Emanuel Sánchez on 3/9/17.
//  Copyright © 2017 sat. All rights reserved.
//

import UIKit

class BMGenericResponseWS: NSObject {
    
    var exito: Bool?
    var mensaje: String?
    var codigoError: Int?
    var lista:[AnyObject]?
    var resultado:AnyObject?
    
    override init(){
        super.init()
        self.exito = true
        self.mensaje = ""
        self.codigoError = 0
        self.lista = Array<AnyObject>()
        self.resultado = nil
    }
    
    init(Exito: Bool?, Mensaje: String?, CodigoError: Int?, Lista:Array<AnyObject>?, Resultado:AnyObject?){
        super.init()
        self.exito = Exito
        self.mensaje = Mensaje
        self.codigoError = CodigoError
        self.lista = Lista
        self.resultado = Resultado
    }

}
