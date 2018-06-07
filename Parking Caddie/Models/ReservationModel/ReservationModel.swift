//
//  ReservationModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 10/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReservationModel{
    
    var location: String!
    var amount: String!
    var duration: String!
    var category: String!
    var payment_mode: String!
    var type: String!
    var reservation_date: String!
    var reserved_until: String!
    var parking_date: String!
    var exit_time: String!
    var ag_name: String!
    var ag_phone: String!
    var ag_email: String!
    var facilities = [JSON]()
    var is_agent = false
    var reservation_no: String!
    
    init(_ data: JSON) {
        
        self.reservation_no = data["reservation_no"].stringValue

        self.location = data["location"].stringValue
        self.amount = data["reservation_amount"].string ?? "0"
        self.duration = data["duration"].string ?? "0"
        self.category = data["category"].stringValue
        self.payment_mode = data["payment_mode"].string ?? "N/A"
        self.type = data["type"].stringValue
        self.reservation_date = data["reservation_date"].stringValue
        self.reserved_until = data["reserved_until"].stringValue
        self.parking_date = data["date"].stringValue
        self.exit_time = data["exit_time"].stringValue
        
        let agent_detail = data["ultimate_valet_agent_details"].dictionaryValue
        
        if !agent_detail.isEmpty{
            
            self.is_agent = true
        }else{
            
            self.is_agent = false
            
        }
        self.ag_name = agent_detail["ag_name"]?.stringValue
        self.ag_phone = agent_detail["ag_phone"]?.stringValue
        self.ag_email = agent_detail["ag_email"]?.stringValue
        
        self.facilities = data["facilities"].arrayValue
        
        
    }
    
    
    init() {
        
    }
    
    
}
