//
//  CheckBox.swift
//  Guiacom
//
//  Created by José Cassimiro on 08/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit

class CheckBox: UIButton {

    let checkedImage = UIImage(named: "checked_checkbox")! as UIImage
    let uncheckedImage = UIImage(named: "unchecked_checkbox")! as UIImage

    var isChecked:Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, forState: .Normal)
            } else {
                self.setImage(uncheckedImage, forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(CheckBox.premiumCheckbox(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = false
    }
    
    func premiumCheckbox(sender:UIButton){
        if sender == self {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }
}
