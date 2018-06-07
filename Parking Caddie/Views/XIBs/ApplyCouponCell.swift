//
//  ApplyCouponCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 06/07/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class ApplyCouponCell: UITableViewCell {
    
    @IBOutlet weak var havePromocodeBtn: UIButton!
    @IBOutlet weak var promocodeTextField: UITextField!
    @IBOutlet weak var applyCodeBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyCodeBtn.layer.cornerRadius = 3
        self.bgView.layer.cornerRadius = 3
        self.promocodeTextField.layer.borderColor = UIColor.appBlue.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
