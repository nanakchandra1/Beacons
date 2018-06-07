//
//  CommonClass.swift
//  Parking Caddie
//
//  Created by Appinventiv on 10/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation
import UIKit
class CommonClass{

        // Email Validation
    
     class func isValidEmail(_ testStr:String) -> Bool {
        
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: testStr)
        return result
        
    }
    
    
  class func delay(_ delay:Double, closure:@escaping ()->()) {
    
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    class func covert_UTC_to_Local_WithTime(_ date:String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date1 = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM, yyyy hh:mm a"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        if date1 == nil{
            
            return "N/A"

        }
        let strDate = dateFormatter.string(from: date1!)
        return strDate

    }
    
    
   class func covert_UTC_to_Local(_ date:String) -> String{
    
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date1 = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
    if date1 == nil{
        
        return "N/A"
        
    }

        let strDate = dateFormatter.string(from: date1!)
        return strDate
    }
    
    class func timeString(_ time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        return String(format:"%02i:%02i",hours,minutes)
    }

    
   class func getCurrentDate() -> String{
        let todaysDate:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: todaysDate)
    }
    
    class func getCurrentDate_Date_form() -> Date{
        let todaysDate:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let date =  dateFormatter.string(from: todaysDate)
        return dateFormatter.date(from: date)!
    }

    class func convertStringToDate(_ str:String) -> Date{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        return dateFormatter.date(from: str)!
    
        
    }
    
    class var isConnectedToNetwork : Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection) ? true : false
    }
    
    
   class func turnonBlutooth(){
    
        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.openURL(url)
        }
    }
    


    
    
    class func clearPrefrences(){
        
        UserDefaults.clearUserDefaults()
        CommonFunctions.gotoLoginPage()
    }


    
    
//MARK:- Method for Loder
//MARK:-*****************
    
    class func startLoader() {
        loader.start()
    }
    
    class func stopLoader() {
        loader.stop()
    }
    
}


var loader = __Loader(frame: CGRect.zero)
class __Loader : UIView {
    
    var activityIndicator : UIActivityIndicatorView!
    
    var isLoading = false
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        
        let lbl = UILabel(frame: CGRect(x: 30, y: 0, width: 100, height: 50))
        lbl.textColor = UIColor.white
        lbl.text = "Loading..."
        
        let innerView = UIView(frame: CGRect(x: 0,y: 0,width: 130,height: 50))
        innerView.addSubview(self.activityIndicator)
        self.activityIndicator.center = CGPoint(x: 10, y: innerView.center.y)
        innerView.center = self.center
        innerView.addSubview(self.activityIndicator)
        innerView.addSubview(lbl)
        
        self.addSubview(innerView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    
    func start() {
        
        if self.isLoading { return }
        
        APPDELEGATEOBJECT.window?.addSubview(self)
        self.activityIndicator.startAnimating()
        self.isLoading = true
    }
    
    
    func stop() {
        
        self.activityIndicator.stopAnimating()
        self.removeFromSuperview()
        self.isLoading = false
    }

}

func print_debug <T> (_ object: T) {
    
    // TODO: Comment Next Statement To Deactivate Logs
    
    print(object)
    
}



