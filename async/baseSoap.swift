//
//  baseSoap.swift
//  M3
//
//  Created by Wolfgang Dusch on 25.07.19.
//  Copyright © 2019 Wolfgang Dusch. All rights reserved.
//

import Foundation
import UIKit
import os

class BaseSoap{
 
    static var ip = "172.29.6.141" // 192.168.0.72"
    static var s3000 = false

    static func sendRequest(function: String,parameter: String = "",appstatip: String? = nil ,timeout: Int = 60,compHandler: @escaping (Data?, Error?,Int) -> Void){
        
//        os_log("SOAP sendRequest: %@", log: Log.soap,type: .error , function as CVarArg)

        let is_SoapMessage2 = String(format: "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\"><soap12:Header><M3000SoapVersionHeader xmlns=\"http://M3000Service\"><Major>2</Major><Minor>4</Minor><Build>1</Build><Revision>1</Revision></M3000SoapVersionHeader></soap12:Header><soap12:Body><%@ xmlns=\"http://M3000Service\">%@</%@></soap12:Body></soap12:Envelope>",function,parameter,function)
        
        var ipi = ip
        if let ai = appstatip{
            ipi = ai
        }
        var is_URL = String(format: "http://%@/M3000Service2/M3000service.asmx", ipi)
        if s3000{
            is_URL = String(format: "http://%@/sirius/M3000service", ipi)
        }

        
        let request = NSMutableURLRequest(url: NSURL(string: is_URL)! as URL)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(timeout)
        let session = URLSession(configuration: config)
        
        let action = String(format: "; action=\"http://M3000Service/%@\"", function)
        request.addValue("application/soap+xml; charset=utf-8" + action, forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
       
        request.httpBody = is_SoapMessage2.data(using: .utf8)
        request.addValue(String(is_SoapMessage2.count), forHTTPHeaderField: "Content-Length")
        request.addValue("100-continue", forHTTPHeaderField: "Expect")

        let rq2 = String(data: request.httpBody!, encoding: .utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let response = response{
                let statuscode = BaseSoap.decodeResponse(response)
                if statuscode == 200{
                    if let dat = data{
                        if let strData = NSString(data: dat, encoding: String.Encoding.utf8.rawValue){
                            let r1 = strData.range(of: "<soap:Body>")
                            if r1.length == 11{
                                let r2 = strData.range(of: "</soap:Body>")
                                if r2.length == 12{
                                    let r3 = NSMakeRange(r1.location + r1.length, r2.location - (r1.location + (r2.length-1)))
                                    let ss = strData.substring(with: r3)
                                    print(ss)
                                    let ds = ss.data(using: .utf8)
                                    compHandler(ds,error,statuscode)
                                }
                            }else{
                                let responseA = String(format: "<%@Response", function)
                                let responseE = String(format: "</%@Response>", function)
                                let r1 = strData.range(of: responseA)
                                if r1.length > 0{
                                    let r2 = strData.range(of: responseE)
                                    if r2.length > 0{
                                        let r3 = NSMakeRange(r1.location, (r2.location + r2.length) - r1.location )
                                        let ss = strData.substring(with: r3)
                                        print(ss)
                                        let ds = ss.data(using: .utf8)
                                        compHandler(ds,error,statuscode)
                                    }
                                }else{
                                    print("Error: No Data ")
                                    compHandler(nil,error,201 )
                                }
                            }
                        }
                    }else{
                        print("Error: No Data ")
                        compHandler(nil,error,201 )
                    }
                }else{
                    print("Error: Status " + String(statuscode),"  ",function)
                    compHandler(nil,error,statuscode )
                }
            }
            if error != nil
            {
                print("E R R O R: " + error.debugDescription)
                compHandler(nil,error,0)
            }
        })
        task.resume()
    }

    static func decodeResponse(_ response: URLResponse)-> Int{
        var result = 200
        if let resp = response as? HTTPURLResponse{
            result = resp.statusCode
        }
        return result
    }
    
}

