//
//  SavedCardsModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 08/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class SavedCardsModel{

    var last4: String!
    var customerId: String!
    var maskedNumber: String!
    var cardType: String!
    var imageUrl: String!
    var token: String!
    var uniqueNumberIdentifier: String!
    var default_type:Bool!
    
    init(with data: JSON) {
        
        self.last4 = data["last4"].stringValue
        self.customerId = data["customerId"].stringValue
        self.maskedNumber = data["maskedNumber"].stringValue
        self.cardType = data["cardType"].stringValue
        self.imageUrl = data["imageUrl"].stringValue
        self.token = data["token"].stringValue
        self.uniqueNumberIdentifier = data["uniqueNumberIdentifier"].stringValue
        self.default_type = data["default"].boolValue

    }
}
