//
//  BMGenericResponseWSParser.swift
//  BienvenidoMexico
//
//  Created by Emanuel Sánchez on 3/9/17.
//  Copyright © 2017 sat. All rights reserved.
//

import UIKit

class BMGenericResponseWSParser: NSObject, ESGenericParserManager {
    
    override init() {
        super.init()
    }
    
    func parseInfoFromData(_ data: Data?, completitionBlock: ((_ result: AnyObject) -> Void)?, failtureBlock: ((_ error: ParserError) -> Void)?) {
        
        do{
            
            let jsonDictionary  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String,AnyObject>
            
            let response: BMGenericResponseWS = BMGenericResponseWS()
            
            if let dictionary = jsonDictionary {
                if let exito = dictionary["EsRespuestaExitosa"]{
                    response.exito = exito as? Bool
                }
                
                if let mensaje = dictionary["MensajeDelServicio"]{
                    response.mensaje = mensaje as? String
                }
                
                if let numeroError = dictionary["NumeroError"]{
                    response.codigoError = numeroError as? Int
                }
                
                if let lista = dictionary["Lista"]{
                    response.lista = lista as? Array<AnyObject>
                }
                
                if let resultado = dictionary["Resultado"]{
                    response.resultado = resultado
                }
                
                completitionBlock!(response as AnyObject)
            } else {
                print("Registro Invalido")
                failtureBlock!(ParserError.parserIsNull)
            }
            
        }catch{
            failtureBlock!(ParserError.parserErrorRuntimeError)
        }
        
    }
}
