//
//  UserData.swift
//  Mutadawel
//
//  Created by Appinventiv on 20/03/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON


 class UserData {
    
    var _id: String!
    var full_name: String!
    var email: String!
    var location: String!
    var mobile: String!
    var country_code: String!
    var phone_no: String!
    var token: String!
    var image: String!
    var is_mobile_verified: Int!
    var pay_token: String!
    var bt_customer_id: String!
    var coupon_code: String!
    var coupon_id: String!
    var is_panal: String!
    
    init(withJson data : JSON) {
        
        self._id = data["id"].stringValue
        self.full_name = data["full_name"].stringValue
        self.email = data["email"].stringValue
        self.location = data["location"].stringValue
        self.mobile = data["mobile"].stringValue
        self.country_code = data["country_code"].stringValue
        self.phone_no = data["phone_no"].stringValue
        self.token = data["token"].stringValue
        self.image = data["image"].stringValue
        self.is_mobile_verified = data["is_mobile_verified"].intValue
        self.pay_token = data["pay_token"].stringValue
        self.bt_customer_id = data["bt_customer_id"].stringValue
        self.coupon_code = data["coupon_code"].stringValue
        self.coupon_id = data["coupon_id"].stringValue
        self.is_panal = data["is_panal"].stringValue
        
        
        userDefaults.set(self._id, forKey: NSUserDefaultsKeys.ID)
        userDefaults.set(self.full_name, forKey: NSUserDefaultsKeys.FULL_NAME)
        userDefaults.set(self.email, forKey: NSUserDefaultsKeys.EMAIL)
        userDefaults.set(self.location, forKey: NSUserDefaultsKeys.LOCATION)
        userDefaults.set(self.mobile, forKey: NSUserDefaultsKeys.MOBILE)
        userDefaults.set(self.country_code, forKey: NSUserDefaultsKeys.CODE)
        userDefaults.set(self.phone_no, forKey: NSUserDefaultsKeys.PHONE)
        userDefaults.set(self.token, forKey: NSUserDefaultsKeys.TOKEN)
        userDefaults.set(self.image, forKey: NSUserDefaultsKeys.PROFILE_PIC)
        userDefaults.set(self.is_mobile_verified, forKey: NSUserDefaultsKeys.STATUS)
        userDefaults.set(self.pay_token, forKey: NSUserDefaultsKeys.C_TOKEN)
        userDefaults.set(self.bt_customer_id, forKey: NSUserDefaultsKeys.CUSTOMERID)
        userDefaults.set(self.coupon_code, forKey: NSUserDefaultsKeys.COUPONCODE)
        userDefaults.set(self.coupon_id, forKey: NSUserDefaultsKeys.COUPON_ID)
        
        let vehicle = data["vehicles"].dictionaryObject ?? [:]
        userDefaults.set(vehicle, forKey: NSUserDefaultsKeys.VEHICLES)

    }
    
    init() {
        
    }
    
}
