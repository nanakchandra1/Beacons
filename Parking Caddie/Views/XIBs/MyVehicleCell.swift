//
//  MyVehicleCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 03/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class MyVehicleCell: UITableViewCell {
    
//MARK:- Outlets
//MARK:-
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var bgview: UIView!
    
    @IBOutlet weak var vehicleNameLbl: UILabel!
    @IBOutlet weak var vehicleNameTextField: UITextField!
    @IBOutlet weak var plateTextField: UITextField!
    
    @IBOutlet weak var plateNoLbl: UILabel!
    @IBOutlet weak var addRemoveBtn: UIButton!
    @IBOutlet weak var addRemoveTopConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
