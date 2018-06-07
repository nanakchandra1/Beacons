//
//  ProfilePicCell.swift
//  Parking Caddie
//
//  Created by Appinventiv on 03/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class ProfilePicCell: UITableViewCell {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profilePicEditBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profilePicWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var profilePicHightContraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImage.layer.borderWidth = 2
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CommonClass.delay(0.01) {
            self.setupSubviews()
        }
        
    }
    
    func setupSubviews() {
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
