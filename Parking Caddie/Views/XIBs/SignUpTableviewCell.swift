//
//  SignUpTableviewCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 02/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class SignUpTableviewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var saperatorView: UIView!
    @IBOutlet weak var showBtnBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showBtnTrailingContraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
