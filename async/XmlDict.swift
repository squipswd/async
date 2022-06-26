//
//  XmlDict.swift
//  M3
//
//  Created by Wolfgang Dusch on 21.07.19.
//  Copyright © 2019 Wolfgang Dusch. All rights reserved.
//

import Foundation


class XmlDict: NSObject, XMLParserDelegate{
    
    var dict: [String: String] = [:]
    var dictarray:[[String: String]] = []
    
    private var elementname = ""
    private var repnode = ""
    private var startRepeat = false
    
    func reset(data: Data?,repNode: String = "",error: Error?) -> String{
        var resultState = ""
        repnode = repNode
        elementname = ""
        if repnode.count > 0{
            startRepeat = false
        }else{
            startRepeat = true
        }
        
        dict.removeAll()
        dictarray.removeAll()
        if data != nil{
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) //TEST
            resultState = "ERROR_SUCCESS"
            var parser = XMLParser(data: data!)
            parser.delegate = self
            parser.parse()
            if repNode.count > 0{
                if dictarray.count == 0{
                    repnode = ""
                    startRepeat = true
                    parser = XMLParser(data: data!)
                    parser.delegate = self
                    parser.parse()
                    resultState = dict["m_ResultState"] ?? ""
                }
            }else{
                resultState = dict["m_ResultState"] ?? ""
            }
        }else{
            if let err = error{
                
                let str = err.localizedDescription
                if let idx = str.index(of: "Could not connect to the server."){
                    resultState = "ERROR_NO_SERVER"
                }else{
                    resultState = "ERROR_OTHER"
                }
            }
        }
        return resultState
    }
  
   
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == repnode{
            startRepeat = true
        }
        if startRepeat{
            elementname = elementName
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if elementname.count > 0{
            if let olds = dict[elementname]{
                dict[elementname] = olds + string   //wegen Umlauten
            }else{
                dict[elementname] = string
            }
        }
    }
    

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == repnode{
            dictarray.append(dict)
            dict.removeAll()
        }
    }
    
    
    
    
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
