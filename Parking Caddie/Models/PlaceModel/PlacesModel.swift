//
//  PlacesModel.swift
//  WashApp
//
//  Created by Appinventiv on 05/04/17.
//  Copyright © 2017 saurabh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//MARK: Model For Places
//======================
struct PlacesModel {
    
    //MARK: PROPERTIES
    //================
    var place_id : String = ""
    var description : String = ""
    
    init(withJSON json: JSONDictionary) {
        print(json)
        guard let placeid = json["place_id"] else {
            return
        }
        guard let desc = json["description"] else {
            return
        }
        self.place_id = "\(placeid)"
        self.description = "\(desc)"
    }
}
