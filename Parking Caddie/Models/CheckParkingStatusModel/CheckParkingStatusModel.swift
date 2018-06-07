//
//  HistoryModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 10/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class CheckParkingStatusModel{

    var pa_name: String!
    var date: String!
    var duration: Double!
    var charge_type: String!
    var charge: String!
    var beaconDetails: [BeaconDetailsModel]
    var exitTerminal: [ExitTerminalModel]
    var is_request_pickup: Bool!
    var request_for_custom_location: Bool!

    init(_ data: JSON) {
        
        self.pa_name = data["pa_name"].stringValue
        
        let parking = data["parking"].dictionaryValue

        self.date = parking["date"]?.stringValue
        
        self.duration = parking["duration"]?.doubleValue
        
        self.charge_type = parking["charge_type"]?.stringValue
        
        self.charge = data["charge"].stringValue
        
        self.is_request_pickup = parking["is_request_pickup"]?.boolValue
        
        self.request_for_custom_location = parking["request_for_custom_location"]?.boolValue

        self.beaconDetails = []
        
        self.exitTerminal = []

        for item in  data["pickup"].arrayValue{
            
            let terminal = ExitTerminalModel(withJSON: item)
            
            self.exitTerminal.append(terminal)
            
        }
        
        for item in  data["beaconDetails"].arrayValue{
            
            let lotdata = BeaconDetailsModel(withJSON: item)
            
            self.beaconDetails.append(lotdata)
            
        }
    }
}


class ExitTerminalModel{

    var _id: String!
    
    var ploc_name: String!

    init(withJSON data: JSON) {
        
        self._id = data["_id"].stringValue
        
        self.ploc_name = data["ploc_name"].stringValue

    }
}
