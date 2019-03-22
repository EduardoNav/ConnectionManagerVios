//
//  GenericConnection.swift
//  ConnectionManagerSwift
//
//  Created by Carlos Chavez on 16/03/16.
//  Copyright © 2016 Emanuel Sanchez. All rights reserved.
//


import Foundation

enum ConnectionType: String{
    case ConnectionTypePOST = "POST"
    case ConnectionTypeGET = "GET"
}

let HOST:String = "http://api.sindelantal.mx/"

class ESGenericConnection: NSObject {
    
    static func performGenericConnectionWithURL < T:AnyObject> (_ url: URL?, Params: Dictionary<String,String>?, Headers: Dictionary<String,String>?, Parser: T, dataParam:Data?, connectionType: ConnectionType, completitionBlock:((_ result: AnyObject?)->(Void))?, failtureBlock: ((_ error: ConnectionManagerError?)->Void)?) where T:ESGenericParserManager {
        
        
        print("Connecting to \(String(describing: url?.absoluteString))")
        
//        let reachability: Reachability = Reachability.init()!
//        let netStatus:Reachability.NetworkStatus = reachability.currentReachabilityStatus
//        
//        if(netStatus == Reachability.NetworkStatus.notReachable){
//            var connectionManagerError: ConnectionManagerError? = ConnectionManagerError()
//            connectionManagerError?.code = NSURLErrorNotConnectedToInternet
//            connectionManagerError?.message = "Connection Error"
//            
//            failtureBlock!(connectionManagerError)
//            return
//        }
        
        if(connectionType == ConnectionType.ConnectionTypeGET){
            
            ESConnectionManager.getRequestFromURL(url!, Parameters: Params, Headers: Headers, completitionBlock: { (result) -> (Void) in
                
                self.handleResponseWithParserManager(Parser, result: result!, completitionBlock: completitionBlock, failtureBlock: failtureBlock)
                
                
                }, failtureBlock: { (error) -> Void in
                    
                    failtureBlock!(error)
                    
            })
            
        }else{
            
            if(dataParam != nil){
                
                ESConnectionManager.postRequestFromURL(url!, Parameters: dataParam, Headers: Headers, completitionBlock: { (Result) -> (Void) in
                    
                    self.handleResponseWithParserManager(Parser, result: Result!, completitionBlock: completitionBlock, failtureBlock: failtureBlock)
                    
                    }, failtureBlock: { (error) -> Void in
                        failtureBlock!(error)
                })
                
            }else{
                
                ESConnectionManager.postRequestFromURL(url!, Parameters: Params! , Headers: Headers, completitionBlock: { (Result) -> (Void) in
                    
                    self.handleResponseWithParserManager(Parser, result: Result!, completitionBlock: completitionBlock, failtureBlock: failtureBlock)
                    
                    }, failtureBlock: { (error) -> Void in
                        failtureBlock!(error)
                })
            }
            
        }
        
    }
    
    static func handleResponseWithParserManager<T:AnyObject>(_ Parser:T?, result:AnyObject, completitionBlock:((AnyObject?)->(Void))?, failtureBlock: ((ConnectionManagerError?)->Void)?) where T:ESGenericParserManager{
        
        let parser:ESGenericParserManager? = Parser
        
        var connectionManagerError: ConnectionManagerError? = ConnectionManagerError()
        if(parser != nil){
            parser?.parseInfoFromData(result as? Data, completitionBlock: { (result) -> Void in
                
                completitionBlock!(result)
                
                }, failtureBlock: { (error) -> Void in
                    
                    if (error == ParserError.parserErrorNoContentToParse) {
                        connectionManagerError?.code = NSURLErrorCannotParseResponse
                        connectionManagerError?.message = "Error No Content"
                    } else if (error == ParserError.parserErrorRuntimeError){
                        connectionManagerError?.code = NSURLErrorCannotParseResponse
                        connectionManagerError?.message = "Runtime Error"
                    } else if (error == ParserError.parserIsNull){
                        connectionManagerError?.code = NSURLErrorCannotDecodeContentData
                        connectionManagerError?.message = "Error Cannot Decode Content Data"
                    }else{
                        connectionManagerError?.code = NSURLErrorUnknown
                        connectionManagerError?.message = "Error Unknown"
                    }
                    
                    failtureBlock!(connectionManagerError);
            })
        }else{
            connectionManagerError?.code = NSURLErrorUnknown
            connectionManagerError?.message = "Error Unknown"
            failtureBlock!(connectionManagerError)
            
        }
    }
}
