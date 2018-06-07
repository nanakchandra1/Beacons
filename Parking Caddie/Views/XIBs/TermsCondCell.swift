//
//  Terms&CondCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 02/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class TermsCondCell: UITableViewCell {

    @IBOutlet weak var checkBtn: UIButton!
    
    @IBOutlet weak var terms_CondLbl: TTTAttributedLabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.checkBtn.layer.borderWidth = 2
        self.checkBtn.layer.borderColor = UIColor.gray.cgColor
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
