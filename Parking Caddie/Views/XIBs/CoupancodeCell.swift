//
//  CoupancodeCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 03/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class CoupancodeCell: UITableViewCell {

//MARK:- Outlets
//MARK:-

    @IBOutlet weak var Bgview: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var parkinLocationLbl: UILabel!
    @IBOutlet weak var LocationNameLbl: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.LocationNameLbl.text = ""
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
