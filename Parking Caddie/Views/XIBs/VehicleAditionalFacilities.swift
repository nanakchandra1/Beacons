//
//  AditionalFacilities.swift
//  Parking Caddie
//
//  Created by Appinventiv on 02/05/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class VehicleAditionalFacilities: UITableViewCell {
    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var facilityNameLbl: UILabel!
    @IBOutlet weak var facilityCost: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
