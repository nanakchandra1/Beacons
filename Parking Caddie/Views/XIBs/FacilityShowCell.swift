//
//  FacilityShowCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 04/08/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class FacilityShowCell: UITableViewCell {

    @IBOutlet weak var facilityNameLbl: UILabel!
    @IBOutlet weak var facilityCharge: UILabel!
    @IBOutlet weak var availedLbl: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
