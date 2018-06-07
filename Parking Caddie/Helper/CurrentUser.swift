//
//  CurrentUser.swift
//  TravelEase
//
//  Created by Appinventiv on 31/12/15.
//  Copyright © 2015 Appinventiv. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults.standard

class CurrentUser {
    
    
    static var fullName : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.FULL_NAME)
        
    }
    static var c_token : String? {
        return userDefaults.string(forKey: NSUserDefaultsKeys.C_TOKEN)
        
    }
    static var customer_id : String? {
        return userDefaults.string(forKey: NSUserDefaultsKeys.CUSTOMERID)
        
    }
    
    static var userEmail : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.EMAIL)
        
    }
    
    static var userLocation  : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.LOCATION)
        
    }
    
    static var mobile : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.MOBILE)
        
    }
    
    static var userImage : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.PROFILE_PIC)
        
    }
    
    static var userPhone : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.PHONE)
        
    }
    
    static var userCode : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.CODE)
        
    }
    static var couponCode : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.COUPONCODE)
        
    }
    
    
    static var vehicles : JSONDictionary? {
        
        return userDefaults.dictionary(forKey: NSUserDefaultsKeys.VEHICLES)
    }
    
    
    static var userToken : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.TOKEN)
        
    }
    
    static var latitude : Double? {
        
        return userDefaults.double(forKey: NSUserDefaultsKeys.LATITUDE)
        
        
    }
    static var longitude : Double? {
        
        return userDefaults.double(forKey: NSUserDefaultsKeys.LONGITUDE)
        
    }
    
    static var pa_detail : JSONDictionary? {
        
        return userDefaults.dictionary(forKey: NSUserDefaultsKeys.PADETAIL)
    }
    
    
    
    static var p_id : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.PID)
        
    }
    static var agent_Name : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.AGENT_NAME)
        
    }
    
    static var AGENT_PHONE : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.AGENT_PHONE)
        
    }
    
    static var b_id : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.B_ID)
        
    }
    
    static var PARKING_TIME : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.PARKING_TIME)
        
    }
    
    
    static var parkingStaus : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.PARKING_STAUS)
        
    }
    static var coupon_id : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.COUPON_ID)
        
    }
    static var tempCoupon_id : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.TEMPCOUPON_ID)
        
    }
    
    
    static var p_catagory : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.CATAGORY)
        
    }
    
    static var id : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.ID)
        
    }
    static var url : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.BEACON_URL)
        
    }
    
    static var charge : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.CHARGE)

    }
    
    static var charge_type : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.CHARGE_TYPE)
        
    }
    
    static var parking_id : String? {
        
        return userDefaults.string(forKey: NSUserDefaultsKeys.PARKING_ID)
        
    }

    
    static var userStatus : Int? {
        
        return userDefaults.integer(forKey: NSUserDefaultsKeys.TOKEN)
        
    }
    
    static var duration : Double{
        
        return userDefaults.double(forKey: NSUserDefaultsKeys.DURATION)
    }
    
    static var isUserLoggedIn : Bool {
        
        if let _ = self.userToken {
            
            return true
        }
        else {
            
            return false
        }
    }
    
}
