//
//  PromotionsModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 11/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class PromotionsModel {
    
    var message: String!
    var date_created: String!
    var coupon_code: String!
    
    init(with data: JSON) {
        
        self.message = data["message"].stringValue
        self.date_created = data["date_created"].stringValue
        self.coupon_code = data["coupon_code"].stringValue

    }
    
}
