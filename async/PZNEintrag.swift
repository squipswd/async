//
//  PZNEintrag.swift
//  M3000
//
//  Created by Wolfgang Dusch on 27.04.22.
//  Copyright © 2022 Wolfgang Dusch. All rights reserved.
//


import Foundation
import CoreData
import UIKit

class PZNEintrag: BaseContainer{
    
    var initflag = true
    
    
    override init(){
        super.init()
        varTableN = [
            "m_nPZN":           _pzn
            ]
        
        
    }
    

    var _pzn = num(0)
 
    
    var pzn: Int{get { return _pzn.value}set {_pzn.value = newValue}}
    var pznStr: String{get{return String(format: "%08ld",_pzn.value)}}
    
    
}

