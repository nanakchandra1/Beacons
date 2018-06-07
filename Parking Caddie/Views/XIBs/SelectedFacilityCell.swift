//
//  SelectedFacilityCell.swift
//  Parking Caddie
//
//  Created by Anuj on 5/20/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class SelectedFacilityCell: UITableViewCell {

    @IBOutlet weak var facilityNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
