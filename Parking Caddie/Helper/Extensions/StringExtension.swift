//
//  StringExtension.swift
//  Parking Caddie
//
//  Created by Appinventiv on 11/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation

extension String{
    
    func convertTimeWithTimeZone(_ timeZome: String = TimeZoneString.UTC, formate: String) -> String{
        
        if self.isEmpty{
            
            return ""
            
        }else{
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.timeZone = TimeZone(abbreviation: timeZome)
            
            dateFormatter.dateFormat = DateFormate.utcDateWithTime
            
            let date1 = dateFormatter.date(from: self)
            
            dateFormatter.dateFormat = formate
            
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            
            dateFormatter.locale = Locale.current
            
            let strDate = dateFormatter.string(from: date1!)
            
            return strDate
            
        }
        
    }
    
}
