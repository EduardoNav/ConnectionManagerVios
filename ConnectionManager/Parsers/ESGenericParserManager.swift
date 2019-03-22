//
//  ESGenericParserManager.swift
//  ConnectionManagerSwift
//
//  Created by Carlos Chavez on 16/03/16.
//  Copyright © 2016 Emanuel Sanchez. All rights reserved.
//

import Foundation

enum ParserError:Int{
    case parserErrorNoContentToParse = 5001
    case parserErrorRuntimeError = 5002
    case parserIsNull = 5003
    case parserErrorUnknown = 5004
    case nullInKey = 5005
}

protocol ESGenericParserManager {
    
    func parseInfoFromData(_ data: Data?, completitionBlock:((_ result: AnyObject)->Void)?, failtureBlock:((_ error:ParserError)->Void)? )
    
}
