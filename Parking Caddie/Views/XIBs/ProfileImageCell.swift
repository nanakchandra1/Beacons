//
//  ProfileImageCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 02/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class ProfileImageCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editImageBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.width / 2
        self.profileImage.clipsToBounds = true
    
        self.profileImage.contentMode = .scaleAspectFill
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
