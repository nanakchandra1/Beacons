//
//  ParkingLotDataModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 11/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class NormalParkingModel {
    
    var ag_phone: String!
    var ag_name: String!
    var date: String!
    var duration: Double!
    var parking_id: String!

    var category: String!
    var charge_type: String!
    var charge: String!
    var pa_name: String!
    var beaconDetails: [BeaconDetailsModel]
    var areaexit: JSONArray!
    
    init(_ data: JSON) {
        
        let agent = data["agent"].dictionaryValue
        self.ag_phone = agent["ag_phone"]?.stringValue
        self.ag_name = agent["ag_name"]?.stringValue
        
        let parking = data["parking"].dictionaryValue
        self.date = parking["date"]?.stringValue ?? ""
        self.duration = parking["duration"]?.doubleValue ?? 0
        self.category = parking["category"]?.stringValue
        self.charge_type = parking["charge_type"]?.stringValue
        self.parking_id = parking["parking_id"]?.stringValue

        self.charge = data["charge"].stringValue

        self.areaexit = data["areaexit"].arrayValue
        self.pa_name = data["pa_name"].stringValue
        self.beaconDetails = []
        
        for item in  data["beaconDetails"].arrayValue{
            
            let lotdata = BeaconDetailsModel(withJSON: item)
            
            self.beaconDetails.append(lotdata)
            
        }

    }
    
}



