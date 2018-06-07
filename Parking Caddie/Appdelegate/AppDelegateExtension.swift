//
//  AppDelegateExtension.swift
//  Parking Caddie
//
//  Created by apple on 18/07/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import UserNotifications
import GoogleMaps
import Crashlytics
import BraintreeDropIn
import Braintree
import Fabric




extension AppDelegate{
    
    func setLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?, application: UIApplication) -> Bool{
        
        BTAppSwitch.setReturnURLScheme("app.Parking-Caddie.com.payments")
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
        
        self.RegisterForPushNotification()
        
        GMSServices.provideAPIKey(googleApiKey)
        
        IQKeyboardManager.shared().isEnabled = true
        Fabric.with([Crashlytics.self])
        
        let handler: LookyLooCountryHandler = LookyLooCountryHandler()
        handler.prepareDataBace()
        
        self.setInitialViewSetUp()
        
        if let launch = launchOptions ,
            let remoteNotifications =  launch[UIApplicationLaunchOptionsKey.remoteNotification] as? [NSObject: AnyObject] {
            
            DispatchQueue.main.async{
                
                self.handlePush(application: application, userInfo: remoteNotifications)
            }
        }
        
        return true
    
    }
    
    func RegisterForPushNotification() {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            UIApplication.shared.registerForRemoteNotifications()
            
        } else {
            
            // Fallback on earlier versions
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.sound,UIUserNotificationType.alert,UIUserNotificationType.badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            
        }
    }
    
    
    func setInitialViewSetUp(){
    
        if CurrentUser.isUserLoggedIn{
            
            if CurrentUser.parkingStaus == parkingState.normal{
                
                CommonFunctions.gotoTimerScreen(.parked, timerScreeState: .normal)
            }
            else if CurrentUser.parkingStaus == parkingState.valet{
                
                CommonFunctions.gotoTimerScreen(.parked, timerScreeState: .valet)
                
            }else{
                
                CommonFunctions.gotoLandingPage()
            }
        }
        else{
            
            CommonFunctions.gotoLoginPage()
        }
        
    }
    
    
    func checkParking_status(){
        
        WebserviceController.checkParkingStatus({ (success, json) in
            
            if success{
                
                let duration = json["result"]["parking"]["duration"].float ?? 0
                
                let seconds = Int(duration * 3600)
                
                timeCount = TimeInterval(seconds)
                
                progressValue = Float((timeCount.truncatingRemainder(dividingBy: 3600)) / 25)

            }
            
        }) { (error) in
            
        }
        
    }
}
