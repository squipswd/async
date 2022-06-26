//
//  PZNListe.swift
//  M3000
//
//  Created by Wolfgang Dusch on 27.04.22.
//  Copyright © 2022 Wolfgang Dusch. All rights reserved.
//


class PZNListe: BaseContainer
{
    static var repnode = "PZNDataSet"
    
    var pznliste = [Int]()
    var count:Int{get{return pznliste.count}}
    
    subscript(index:Int) -> Int? {
        get {
            if index < pznliste.count{
                return pznliste[index]
            }else{
                return nil
            }
        }
    }

    override func update(dict: [String: String]){
        print("ERROR")
    }
    
    func update(dictarray: [[String:String]]){
        pznliste.removeAll()
        
        for dict in dictarray{
            let pzneintrag = PZNEintrag()
            pzneintrag.update(dict: dict)
            
            pznliste.append(pzneintrag.pzn)
        }
    }
    
    func removeAll(){
        if BaseContainer.testbetrieb == false{

        }
        pznliste.removeAll()
        
    }

    /// SOAP Support
    
    func get(pznType: String, coHandler: @escaping (String?, Error?,Bool,Int) -> Void){
            let param = String(format:"<inMessage><m_nPZNType>%@</m_nPZNType></inMessage>",pznType)

            
            BaseSoap.sendRequest(function: "GetPZNList",parameter: param ,compHandler: {data,error,statuscode -> Void in
                
                self.resultState = self.xmldict.reset(data: data,repNode: PZNListe.repnode,error: error)
                
                self.update(dictarray: self.xmldict.dictarray)
                if self.result == .ResultOk{
                    let ok = true
                    print(self.pznliste.count)
                    coHandler("fertig GetPZNList",error,ok,statuscode)
                }else{
                    coHandler("fertig GetPZNList mit Fehler",error,false,statuscode)
                }
            })
        }
//    }
    
    
}
/*

<GetPZNList xmlns="http://M3000Service">
  <inMessage>
    <m_nPZNType>UNDEF or LAGER or INFO</m_nPZNType>
  </inMessage>
</GetPZNList>
*/
