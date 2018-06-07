//
//  CodeDetailCell.swift
//  SixthDegree
//
//  Created by Anuj Garg on 29/12/15.
//  Copyright © 2015 Appinventiv. All rights reserved.
//

import UIKit

class CodeDetailCell: UITableViewCell {
    
    
    
     //MARK:-IBOutlet
    //:-
    @IBOutlet weak var codeTextLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.codeTextLabel.layer.cornerRadius = 4.0
        self.codeTextLabel.clipsToBounds = true
        self.selectionStyle = .none
        self.checkImageView.image = UIImage(named: "uncheck")
        
       
    }

    
    // MARK:- setSelected Method
    //:-
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   }
