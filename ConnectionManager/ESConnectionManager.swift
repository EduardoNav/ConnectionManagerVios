//
//  ESConnectionManager.swift
//  ConnectionManagerSwift
//
//  Created by Emanuel Sanchez on 16/03/16.
//  Copyright © 2016 Emanuel Sanchez. All rights reserved.
//

import Foundation

struct ConnectionManagerError {
    var code: Int?
    var message: String?
}

class ESConnectionManager:NSObject {
    
    override init() {
        super.init();
    }
    
    static func getRequestFromURL(_ url: URL, Parameters: Dictionary<String,String>?, Headers: Dictionary<String, String>?, completitionBlock:((_ result:AnyObject?)->(Void))?, failtureBlock: ((_ error:ConnectionManagerError?)->Void)?){
        
        var url_:URL = url
        
        if(Parameters != nil){
            
            let strExtraParams: String = self.buildExtraParametersWithParameters(Parameters)
            
            var strURL: String = url.absoluteString
            
            strURL = strURL + "?\(strExtraParams)"
            
            url_ = URL.init(string: strURL)!
            
            print(strURL)
        }
        
        var request: NSMutableURLRequest = NSMutableURLRequest.init(url: url_)
        
        if(Headers != nil){
            request = self.configureHeaders(Headers as Dictionary<String, AnyObject>?, Request: request)
        }
        
        request.httpMethod = ConnectionType.ConnectionTypeGET.rawValue
        
        self.performRequest(request as URLRequest, completitionBlock: completitionBlock, failtureBlock: failtureBlock)
        
    }
    
    static func postRequestFromURL(_ url: URL, Parameters: Dictionary<String,String>?, Headers: Dictionary<String, String>?, completitionBlock:((_ result: AnyObject?)->(Void))?, failtureBlock: ((_ error:ConnectionManagerError?)->Void)?){
        
        var request: NSMutableURLRequest = NSMutableURLRequest.init(url: url)
        
        if(Headers != nil){
            
            request = self.configureHeaders(Headers as Dictionary<String, AnyObject>?, Request: request)
            
        }
        
        if(Parameters != nil){
            
            let strExtraParams: String = self.buildExtraParametersWithParameters(Parameters)
            
            let data: Data = strExtraParams.data(using: String.Encoding.utf8)!
            data.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) -> Void in
                request.httpBody = Data(bytes: bytes, count: data.count)
            })
                
//                Data(bytes:
//                ((
//                    strExtraParams.data(using: String.Encoding.utf8
//                        ) as Data?
//                    )?.with.assumingMemoryBound(to: UInt8.self))!
//                       
//                , count: (strExtraParams.data(using: String.Encoding.utf8)?.count)!)
        }
        
        
        request.httpMethod = ConnectionType.ConnectionTypePOST.rawValue
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        self.performRequest(request as URLRequest, completitionBlock: completitionBlock, failtureBlock: failtureBlock)
        
    }
    
    static func postRequestFromURL(_ url: URL, Parameters: Data? , Headers: Dictionary<String, String>?, completitionBlock:@escaping ((_ result:AnyObject?)->(Void)), failtureBlock: ((_ error:ConnectionManagerError?)->Void)?){
        
        var request: NSMutableURLRequest = NSMutableURLRequest.init(url: url)
        
        if(Headers != nil){
            request = self.configureHeaders(Headers as Dictionary<String, AnyObject>?, Request: request)
        }
        
        request.httpMethod = ConnectionType.ConnectionTypePOST.rawValue
        
        request.httpBody = Parameters
        
        self.performRequest(request as URLRequest, completitionBlock: completitionBlock, failtureBlock: failtureBlock)
        
    }
    
    static func buildExtraParametersWithParameters(_ parameters: Dictionary<String, String>?)->String{
        
        let allKeys = ((parameters! as NSDictionary).allKeys)
        
        var strPostParams: String = ""
        
        var boolFirstTime: Bool = true
        
        for key in allKeys{
            
            if (boolFirstTime){
                boolFirstTime = false
            }else{
                strPostParams = strPostParams + "&";
            }
            
            strPostParams = strPostParams + "\(key as! String)=\((parameters?[key as! String])! as String)"
        }
        
        
        return strPostParams.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    static func configureHeaders(_ Headers: Dictionary<String, AnyObject>?, Request:NSMutableURLRequest)->NSMutableURLRequest{
        
        let allKeys = ((Headers! as NSDictionary)).allKeys
        
        for key in allKeys{
            Request.setValue((Headers![key as! String] as! String?), forHTTPHeaderField: key as! String)
            
        }
        
        return Request
        
    }
    
    static func performRequest(_ request:URLRequest, completitionBlock:((_ result:AnyObject?)->(Void))?, failtureBlock: ((_ error:ConnectionManagerError?)->Void)? ){
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        sessionConfig.timeoutIntervalForResource = 30
        sessionConfig.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        sessionConfig.urlCache = nil
        let session = URLSession(configuration: sessionConfig)
        
        URLCache.shared.removeAllCachedResponses()
        
        let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, connectionError:Error?) in
            
            var connectionManagerError: ConnectionManagerError? = ConnectionManagerError()
            
            guard connectionError == nil else{
                let error: NSError? = connectionError as NSError?
                
                connectionManagerError?.code = error!.code
                connectionManagerError?.message = error!.localizedDescription
                
                print((connectionManagerError!.code)!)
                print((connectionManagerError!.message)!)
                
                failtureBlock!(connectionManagerError)
                
                return
            }
            
            DispatchQueue.main.async(execute: {
            
                var intErrorCode: Int?
                if let httURLResponse = response as? HTTPURLResponse {
                    intErrorCode = httURLResponse.statusCode
                    
                    if(intErrorCode! >= 200 && intErrorCode! < 300){
                        
                        completitionBlock!(data as AnyObject?)
                        
                    }else {
                        connectionManagerError?.code = intErrorCode
                        
                        if let dataMessage = data {
                            do{
                                let jsonDictionary  = try JSONSerialization.jsonObject(with: dataMessage, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String,AnyObject>
                                connectionManagerError?.message = jsonDictionary?["Message"] as? String
                                
                                if connectionManagerError?.message == nil{
                                    connectionManagerError?.message = jsonDictionary?.description
                                }
                                
                            }catch{
                                
                                let stringMessage = String(data: dataMessage, encoding: .utf8)
                                connectionManagerError?.message = stringMessage
                            }
                        }else{
                            if(intErrorCode! >= 400 || intErrorCode! == 500){
                                connectionManagerError?.message = "Client Error"
                            }else if(intErrorCode! >= 500 || intErrorCode! == 600){
                                connectionManagerError?.message = "Service Error"
                            }else{
                                connectionManagerError?.message = "Unknown Error"
                            }
                        }
                        failtureBlock!(connectionManagerError)
                    }
                    
                }else{
                    connectionManagerError?.code = 0
                    connectionManagerError?.message = "Runtime Error"
                    
                    guard failtureBlock == nil else{
                        return
                    }
                    
                    failtureBlock!(connectionManagerError)
                }
            }
            )
        }
        
        task.resume()
        
    }
    
    
    
}
