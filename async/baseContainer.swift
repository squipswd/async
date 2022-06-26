//
//  baseContainer.swift
//  M3
//
//  Created by Wolfgang Dusch on 22.07.19.
//  Copyright © 2019 Wolfgang Dusch. All rights reserved.
//

import UIKit
import CoreData

class str{
    var value:String = ""
    init(_ value: String){
        self.value = value
    }
}
class num{
    var value:Int = 0
    init(_ value: Int){
        self.value = value
    }
}
class num64{
    var value:Int64 = 0
    init(_ value: Int64){
        self.value = value
    }
}
class BaseContainer
{
//    static var database:DataBase?
    static var connectionOk = false
    static var testbetrieb = false
    static var testRecord = false // true zum aufzeichnen der TestDB

    static  var appDelegate:AppDelegate!
    
    static var activityIndicator:UIActivityIndicatorView?


    enum Result{
        case ResultUndef
        case ResultOk
        case ResultErrorIntern
        case ResultErrorServerTimeout
        case ResultErrorOther
        case ResultArticleIncomplete
        case ResultStoragePlaceIncomplete
        case ResultNoData
        case ResultNoServer
        case ResultWWSConfig
        case ResultWWSShutdown
        case ResultInventoryUnderrun
        case ResultErrorNotWarehoused
        case ResultErrorParameter
        case ResultErrorSecurDecode
        case ResultValueMeantimeChanged
        case ResultErrorAccessDenied
        case ResultErrorCheckSetOrderWWS
    }
    let xmldict = XmlDict()
    
    var varTableN:[String:num] = [:]
    var varTableN64:[String:num64] = [:]
    var varTableS:[String:str] = [:]
    var varTableBinary:[String:str] = [:]

    var objectID:NSManagedObjectID?

    
    private var _resultState = str("")
    
    var resultState: String {get {return _resultState.value}set {_resultState.value = newValue}}

    var result:Result {
        get
        {
            switch _resultState.value {
            case "ERROR_WWS_INTERN":
                return .ResultErrorIntern
            case "ERROR_M3000SERVICE_INTERN":
                return .ResultErrorIntern
            case "ERROR_SUCCESS":
                return .ResultOk
            case "ERROR_ARTICLE_INFO_DATA_INCOMPLETE":
                return .ResultArticleIncomplete
            case "ERROR_STORAGE_PLACE_DATA_INCOMPLETE":
                return .ResultStoragePlaceIncomplete
            case "ERROR_NO_DATA":
                return .ResultNoData
            case "ERROR_NO_SERVER":
                return .ResultNoServer
            case "ERROR_OTHER":
                return .ResultErrorOther
            case "ERROR_WWS_CONFIG":
                return .ResultWWSConfig
            case "ERROR_WWS_SHUTDOWN":
                return .ResultWWSShutdown
            case "ERROR_INVENTORY_UNDERRUN":
                return .ResultInventoryUnderrun
            case "ERROR_ARTICLE_NOT_WAREHOUSED":
                return .ResultErrorNotWarehoused
            case "ERROR_PARAMETER":
                return .ResultErrorParameter
            case "ERROR_SECUR_DECODE":
                return .ResultErrorSecurDecode
            case "ERROR_VALUE_MEANTIME_CHANGED":
                return .ResultValueMeantimeChanged
            case "ERROR_ACCESS_DENIED":
                return .ResultErrorAccessDenied
            case "ERROR_CHECK_SETORDERS_WWS":
                return .ResultErrorCheckSetOrderWWS
            default:
                return .ResultUndef
            }
        }
    }
    
    
    
    static func resultText(result:Result) -> String
    {
        switch result {

        case .ResultErrorIntern:
            return "ERROR_M3000SERVICE_INTERN"
        case .ResultOk:
            return "ERROR_SUCCESS"
        case .ResultStoragePlaceIncomplete:
            return "ERROR_STORAGE_PLACE_DATA_INCOMPLETE"
        case .ResultArticleIncomplete:
            return "ERROR_ARTICLE_INFO_DATA_INCOMPLETE"
        case  .ResultNoData:
            return "ERROR_NO_DATA"
        case  .ResultNoServer:
            return "ERROR_NO_SERVER"
        case .ResultErrorOther:
            return "ERROR_OTHER"
        case .ResultWWSConfig:
            return  "ERROR_WWS_CONFIG"

        case .ResultWWSShutdown:
            return "ERROR_WWS_SHUTDOWN"

        case .ResultInventoryUnderrun:
            return "ERROR_INVENTORY_UNDERRUN"
            
        case .ResultErrorNotWarehoused:
            return "ERROR_ARTICLE_NOT_WAREHOUSED"
        case .ResultErrorParameter:
            return "ERROR_PARAMETER"
        case .ResultErrorSecurDecode:
            return "ERROR_SECUR_DECODE"
        case .ResultValueMeantimeChanged:
            return "ERROR_VALUE_MEANTIME_CHANGED"
        case .ResultErrorAccessDenied:
            return "ERROR_ACCESS_DENIED"
            
        case .ResultErrorCheckSetOrderWWS:
            return "ERROR_CHECK_SETORDERS_WWS"
          
        default:
            return "????"
        }
    }
    
    static func resultTextDialog(result:Result) -> String
    {
        switch result {

        case .ResultErrorIntern:
            return "Interner Fehler im WWS-Server"
        case .ResultOk:
            return "Erfolgreich"
        case .ResultArticleIncomplete:
            return "Unvollständige Daten"
        case .ResultStoragePlaceIncomplete:
            return "Unvollständige Daten"
        case  .ResultNoData:
            return "Keine Daten"
        case  .ResultNoServer:
            return "Server nicht verfügbar"
        case .ResultErrorOther:
            return "Anderer Fehler"
        case .ResultWWSConfig:
            return  "Konfigurationsfehler"
        case .ResultWWSShutdown:
            return "A3000-Dienst läuft nicht"
        case .ResultInventoryUnderrun:
            return "Übervorrat erschöpft"
        case .ResultErrorNotWarehoused:
            return "Kein Lagerartikel"
        case .ResultErrorParameter:
            return "Fehler in Parametern"
        case .ResultErrorSecurDecode:
            return "Fehler im Data Matrix Code"
        case .ResultValueMeantimeChanged:
            return "Artikel hat sich zwischenzeitlich verändert"
        case .ResultErrorAccessDenied:
            return "Bediener hat kein Recht für Bestandsänderung"
        case .ResultErrorCheckSetOrderWWS:
            return "Fehler beim Kontrollesen der Wareneingangs-Positionen"

        default:
            return "Unbekannter Fehler"
        }
    }
  /*
    func getLiefTypString(typ: SupplierEintrag.typen)-> String{
        var typstr = "KEINE_FESTLEGUNG"
        switch typ {
            case .direkt:
            typstr = "DIREKTLIEFERANTEN"
            break
            case .gh:
                typstr = "GROSSHAENDLER"
            break
            case .hersteller:
                typstr = "HERSTELLER"
            break
            default:
            break
        }
        return typstr
    }
    
*/
    func update(dict: [String: String]){
        resultState = ""
        for (key,value) in dict{
            
            if varTableS[key] != nil{
                varTableS[key]?.value = value
            }else{
                if varTableN[key] != nil{
                    var val = value
                    if value == "true"{
                        val = "1"
                    }
                    if value == "false"{
                        val = "0"
                    }
                    varTableN[key]?.value = Int(val) ?? 0
                }else{
                        if varTableN64[key] != nil{
                            varTableN64[key]?.value = Int64(value) ?? 0
                        }else{
                            if key == "m_ResultState"{
                                resultState = value
                            }
                        }
                }
            }
        }
    }

    func verfallToText(verfallStr: String,verfall: Bool = false)-> String{
        var text = ""
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        var datum = BaseContainer.textToDate(str: verfallStr)
        let ti = datum?.timeIntervalSince1970
        if ti?.isLess(than: 0.0) == false{
            if verfall{
                df.dateFormat = "MM/YY"
            }else{
                df.dateFormat = "MM/yyyy"
            }
            return df.string(from: datum!)
        }
        return text
    }

    static func textToDate(str: String?)-> Date?{
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = TimeZone.current
        let datum = df.date(from: str ?? "")
        return datum
    }

    
    
    func  _datumStr(datum: Date) -> String{
            let df = DateFormatter()
            df.timeStyle = .short
            df.dateStyle = .short
            return df.string(from: datum)
    }
    static func _datumGHM(datum: Date,notime: Bool = false)-> String{
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let zeit = df.string(from: datum)
        var datumS = datum.startOfDay()
        let heuteS = Date().startOfDay()
        var datumstr = "heute"
        if datumS != heuteS{
            datumS += TimeInterval(60.0*60.0*24.0)
            if datumS == heuteS{
                datumstr = "gestern"
            }else{
                datumS = datum.startOfDay()
                datumS -= TimeInterval(60.0*60.0*24.0)
                if datumS == heuteS{
                    datumstr = "morgen"
                }
                else{
                    df.dateFormat = "dd.MM.yy"
                    datumstr = df.string(from: datum)
                }
            }
        }
        if notime{
            return datumstr
        }else{
            return datumstr + ", " + zeit
        }
    }
    
    static func preisToString(preis: Int)-> String{
        var text = ""
        text = String(format: "%0.2f €",Double(preis) / 100.0 )
    
        if let ki = text.firstIndex(of: "."){
            let kie = text.index(ki,offsetBy: 1)
            text.replaceSubrange(ki..<kie , with: ",")
        }
        return text
    }
    
    static func dateConvert(datestr: String,date: Date? = nil)-> (text: String,datum: Date?){
        var newdate = ""
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        df.timeZone = TimeZone.current
        var dat:Date?
        if let datum = df.date(from: datestr){
            dat = datum
        }else{
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  //.SSSS"
            if let datum = df.date(from: datestr){
                dat = datum
            }
        }
        if date != nil{
            dat = date
        }
        if dat == nil {
            return ("*Datum ungültig*",nil)   //Ungültiges VerfallDatum
        }
        df.dateFormat = "dd.MM.yyyy HH:mm:ss"
        newdate = df.string(from: dat!)
        return (newdate,dat)
    }


    static func controlIndicator(view: UIView?,on: Bool = true,dark: Bool = true){
        if view != nil{
            DispatchQueue.main.async {
                if self.activityIndicator == nil{
                    self.activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
                }
                if self.activityIndicator!.isAnimating{
                    self.activityIndicator!.stopAnimating()
                    for vv in view!.subviews{
                        if let v = vv as? UIActivityIndicatorView{
                            v.removeFromSuperview()
                            break
                        }
                    }
                }else{
                    if on{
                        if dark{
                            self.activityIndicator?.color = UIColor.white
                        }else{
                            self.activityIndicator?.color = UIColor.black
                        }
                        self.activityIndicator!.center = view!.center
                        self.activityIndicator!.hidesWhenStopped = true
                        self.activityIndicator!.startAnimating()
                        view!.addSubview(self.activityIndicator!)
                    }else{
  //                      self.activityIndicator = nil
                    }
                }
                if !on{
//                    self.activityIndicator = nil
                }
            }
        }
    }
    
}

extension   Date
{
    func startOfDay()   -> Date{
        return Calendar.current.startOfDay(for: self)
    }
}


