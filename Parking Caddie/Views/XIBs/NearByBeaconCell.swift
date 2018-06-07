//
//  NearByBeaconCell.swift
//  Parking Caddie
//
//  Created by Anuj on 5/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class NearByBeaconCell: UITableViewCell {

    @IBOutlet weak var lotNameLbl: UILabel!
    @IBOutlet weak var beaconIdLbl: UILabel!
    @IBOutlet weak var beconTypeLbl: UILabel!
    @IBOutlet weak var beaconCatagoryLbl: UILabel!

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
