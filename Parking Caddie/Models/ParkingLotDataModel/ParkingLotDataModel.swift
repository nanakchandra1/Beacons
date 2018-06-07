//
//  ParkingLotDataModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 11/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParkingLotDataModel{

    var c_lat: Double = 0
    var c_long: Double = 0
    var _id: String!
    var pa_location: String!
    var pa_address: String!
    var pa_name: String!
    var search = ""
    var dist: Double = 0
    
    init(_ data: JSON) {
        
        self._id = data["_id"].stringValue
        self.pa_location = data["pa_location"].stringValue
        self.pa_address = data["pa_address"].stringValue
        self.pa_name = data["pa_name"].stringValue

        let pa_area_loc = data["pa_area_loc"].dictionaryValue

        let coordinates = pa_area_loc["coordinates"]?.arrayValue
        
        if !coordinates!.isEmpty{
        
            self.c_lat = coordinates!.last!.doubleValue
            self.c_long = coordinates!.first!.doubleValue
        }
        
    }
    
    
    init() {
        
    }

}


// slot data model

class slotDataModel{
    
    var total_slot_count: Int = 0
    var booked_slot_count: Int = 0
    var _id: String!
    
    init(_ data: JSON) {
        
        self.total_slot_count = data["total_slot_count"].intValue
        self.booked_slot_count = data["booked_slot_count"].intValue
        self._id = data["_id"].stringValue
    }
    
    init() {
        
    }
    
}


// slot data model

class selectedLotDataModel{
    
    var economy: Int = 0
    var business: Int = 0
    var premium: Int = 0
    var slots: [slotModel]
    var lots: [lotModel]

    var areaEntryBeacons: [JSON]!
    
    var _id: String!
    
    init(_ data: JSON) {
        
        let reserved_slots = data["reserved_slots"].dictionaryValue

        self.economy = reserved_slots["economy"]?.int ?? 0
        self.business = reserved_slots["business"]?.int ?? 0
        self.premium = reserved_slots["premium"]?.int ?? 0
        self.areaEntryBeacons = data["areaentry"].arrayValue
        self.lots = []
        self.slots = []

        for item in  data["slots"].arrayValue{
            let slotdata = slotModel(item)
            
            self.slots.append(slotdata)
            
        }

        for item in  data["lots"].arrayValue{
            
            let lotdata = lotModel(item)

            self.lots.append(lotdata)
        }

    }
        
}


class slotModel{
    
    var parkingbeacons: [JSON]!
    var id: String!
    
    init(_ data: JSON) {
        
        self.parkingbeacons = data["parkingbeacons"].arrayValue
        
        self.id = data["_id"].stringValue
    }
    
    init() {
        
    }

}

class lotModel{
    
    var pl_entryb: [JSON]!
    
    init(_ data: JSON) {
        
        self.pl_entryb = data["pl_entryb"].arrayValue
    }
    
    init() {
        
    }
    
}

