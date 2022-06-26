//
//  ViewController.swift
//  async
//
//  Created by Wolfgang Dusch on 22.06.22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
 
    @IBAction func actionButton(_ sender: Any) {
        
        BaseContainer.appDelegate.pznliste.get(pznType: "LAGER", coHandler: {text,error,ok,result in
            print(ok)
            
            
        })
        
        
    }
    
}

