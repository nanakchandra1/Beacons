//
//  ParkinLotnameCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 03/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class ParkinLotnameCell: UITableViewCell {
//MARK:- Outlets
//MARK:-
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var parkinLotNameLbl: UILabel!
    @IBOutlet weak var couponCodeLbl: UILabel!
    
//MARK:- awakeFromNib Method
//MARK:-

    override func awakeFromNib() {
        super.awakeFromNib()
        self.parkinLotNameLbl.text = ""
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
