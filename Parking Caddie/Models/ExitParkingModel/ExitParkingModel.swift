//
//  HistoryModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 10/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class ExitParkingModel{

    var payment_success: Bool!
    var paid: String!
    var message: String!
    var category: String!
    var exit_time: String!
    var date: String!
    var location: String!
    var duration: String!
    var pending: String!
    var parking_id: String!
    
    init(_ data: JSON) {
        
        self.payment_success = data["payment_success"].boolValue
        self.paid = data["paid"].stringValue
        self.parking_id = data["parking_id"].stringValue

        self.message = data["message"].stringValue
        self.category = data["category"].stringValue
        self.exit_time = data["exit_time"].stringValue
        self.date = data["date"].stringValue 
        self.location = data["location"].stringValue
        self.duration = data["duration"].stringValue
        self.pending = data["pending"].stringValue
    }
    
    init() {
        
    }

    
}
