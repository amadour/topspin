//
//  ViewController.swift
//  TopSpin
//
//  Created by Amadour Griffais on 23/04/2019.
//  Copyright © 2019 Amadour Griffais. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var topSpinButton: UIButton?
    
    @IBAction func toggle(sender: Any?) {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.topSpinButton?.isSelected.toggle()
                        self.view.layoutIfNeeded()
        })
    }
    
}

