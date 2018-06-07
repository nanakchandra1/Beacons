//
//  ParkingLotDataModel.swift
//  Parking Caddie
//
//  Created by Appinventiv on 11/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class SelectedParkingLotDetailModel {
    
    var _id: String!
    var pa_charge_grid: [ChargeGridModel]
    var facilities: [FacilitiesModel]
    var beaconDetails: [BeaconDetailsModel]
    var pa_image: String!
    var pa_name: String!
    var pa_address: String!
    var pa_location: String!
    var pa_open_time: String!
    var pa_close_time: String!
    var pa_charge_type: String!
    var business: String!
    var economy: String!
    var premium: String!
    var outdoor: String!
    var ultimatevalet: String!
    
    init(_ data: JSON) {
        
        self._id = data["_id"].stringValue
        self.pa_location = data["pa_location"].stringValue
        self.pa_address = data["pa_address"].stringValue
        self.pa_name = data["pa_name"].stringValue
        
        self.pa_image = data["pa_image"].stringValue
        self.pa_open_time = data["pa_open_time"].stringValue
        self.pa_close_time = data["pa_close_time"].stringValue

        self.pa_charge_type = data["pa_charge_type"].stringValue
        self.pa_name = data["pa_name"].stringValue

        self.pa_charge_grid = []
        self.facilities = []
        self.beaconDetails = []

        let pa_charge = data["pa_charge"].dictionaryValue
        self.economy = pa_charge["economy"]?.stringValue
        self.business = pa_charge["business"]?.stringValue
        self.premium = pa_charge["premium"]?.stringValue
        self.outdoor = pa_charge["outdoor"]?.stringValue
        self.ultimatevalet = pa_charge["ultimatevalet"]?.stringValue

        
        for item in  data["pa_charge_grid"].arrayValue{
            
            let slotdata = ChargeGridModel(withJSON: item)
            
            self.pa_charge_grid.append(slotdata)
            
        }
        
        for item in  data["beaconDetails"].arrayValue{
            
            let lotdata = BeaconDetailsModel(withJSON: item)
            
            self.beaconDetails.append(lotdata)
        }

        for item in  data["facilities"].arrayValue{
            
            let lotdata = FacilitiesModel(withJSON: item)
            
            self.facilities.append(lotdata)
        }

    }
    
}



class FacilitiesModel {
    
    var fl_image: String!
    var fl_name: String!
    var fl_price: String!
    
    init(withJSON data: JSON) {
        
        self.fl_image = data["fl_image"].stringValue
        self.fl_name = data["fl_name"].stringValue
        self.fl_price = data["fl_price"].stringValue
        
    }
    
}


class BeaconDetailsModel {
    
    var _id: String!
    var bn_major: Int!
    var bn_minor: Int!
    var bn_name: String!
    var bn_type: String!
    var category: String!
    
    init(withJSON data: JSON) {
        
        self._id = data["_id"].stringValue
        self.bn_major = data["bn_major"].intValue
        self.bn_minor = data["bn_minor"].intValue
        self.bn_name = data["bn_name"].stringValue
        self.bn_type = data["bn_type"].stringValue
        self.category = data["category"].stringValue

    }
}


class ChargeGridModel {
    
    var category: String!
    var charge: String!
    
    init(withJSON data: JSON) {
        
        self.category = data["category"].stringValue
        self.charge = data["charge"].stringValue

    }
}
