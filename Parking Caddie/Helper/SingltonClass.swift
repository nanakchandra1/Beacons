//
//  SingltonClass.swift
//  Parking Caddie
//
//  Created by Appinventiv on 04/08/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation

let parkingSharedInstance = SingltonClass.sharedInstance

class SingltonClass {
    
    var facility = JSONDictionaryArray()
    var beaconsDetails = [BeaconDetailsModel]()
    var vehicle = [String:String]()
    var selectedFacility = JSONDictionaryArray()
    var selectedLotDetail = selectedLotDataModel([:])//JSONDictionary()
    var upgrade = 0
    var disableTab = true
    var agentInfo = JSONDictionary()

    static let sharedInstance = SingltonClass()

    fileprivate init(){
    
    }
    
}
