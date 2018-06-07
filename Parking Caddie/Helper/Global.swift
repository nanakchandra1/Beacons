//
//  Global.swift
//  Parking Caddie
//
//  Created by apple on 18/07/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import Braintree
import BraintreeDropIn




struct DateFormate {
    
    static let utcDateWithTime = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let dateWithTime = "dd MMM yyyy hh:mm a"
    static let dateOnly = "dd-MM-yyyy"
    static let timeOnly = "hh:mm a"
}

struct TimeZoneString {
    
    static let UTC = "UTC"
    static let SGT = "SGT"
}


//MARK:StoryBoard Initialization


enum AppStoryboard : String{
    
    case Main = "Main"
    case TabBar = "TabBar"
    case Settings = "Settings"
    case Parking = "Parking"
    case ParkingHistory = "ParkingHistory"
    case Payment = "Payment"

    
    var instance : UIStoryboard {
        
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

var isUltimateValet = false
let mainStoryboard = AppStoryboard.Main.instance
let tabbarStoryboard = AppStoryboard.TabBar.instance
let settingsStoryboard = AppStoryboard.Settings.instance
let parkingStoryboard = AppStoryboard.Parking.instance
let parkingHistoryStoryboard = AppStoryboard.ParkingHistory.instance
let paymentStoryboard = AppStoryboard.Payment.instance


//MARK:
//MARK: Dial Phone Number
func dialPhoneNumer(_ phoneNumer:String){
    
    let url = URL(string: "telprompt://\(phoneNumer)")!
    UIApplication.shared.openURL(url)
    
}

func sendMail(_ phoneNumer:String){
    let url = URL(string: "mailto://\(phoneNumer)")!
    UIApplication.shared.openURL(url)
}


class CommonFunctions{
    
    static func gotoLoginPage(){
        
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        APPDELEGATEOBJECT.parentNavigationController = UINavigationController(rootViewController: vc)
        APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true
        APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
        APPDELEGATEOBJECT.window?.makeKeyAndVisible()
        
    }
    
    
    
    
    static func gotoLandingPage(){
        
        let mainViewController = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        mainViewController.tabBarTempState = TabBarTempState.search
        APPDELEGATEOBJECT.parentNavigationController = UINavigationController(rootViewController: mainViewController)
        APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true
        APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
        APPDELEGATEOBJECT.window?.makeKeyAndVisible()
        
    }
    
    
    static func gotoTimerScreen(_ timer_State: TimerState,timerScreeState: TimerScreenState){
        
        let mainViewController = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        mainViewController.tabBarTempState = TabBarTempState.timer
        mainViewController.timerScreeState = timerScreeState
        mainViewController.timer_State = timer_State
        APPDELEGATEOBJECT.parentNavigationController = UINavigationController(rootViewController: mainViewController)
        APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true
        APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
        APPDELEGATEOBJECT.window?.makeKeyAndVisible()
        
    }
    
    
    static func gotoFromPushNotification(_ tabBarTempState: TabBarTempState){
        
        
        let tabBarVC = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        tabBarVC.tabBarTempState = tabBarTempState
        APPDELEGATEOBJECT.parentNavigationController  = UINavigationController(rootViewController: tabBarVC)
        APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
        APPDELEGATEOBJECT.window?.makeKeyAndVisible()
        APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true
        
    }
    
    
    
    
    
    static func getclientToken(_ viewController: UIViewController){
        
        WebserviceController.getClientTokenAPI({ (success, json) in
            
            if success{
                
                let result = json["result"].stringValue
                self.showDropIn(result, viewController: viewController)
                
            }
        }) { (error) in
            
        }
    }
    
    
    static func showDropIn(_ clientTokenOrTokenizationKey: String, viewController: UIViewController) {
        
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            
            if (error != nil) {
                
                print("ERROR")
                
            } else if (result?.isCancelled == true) {
                
                if let bt_cus_id = CurrentUser.customer_id, bt_cus_id.isEmpty{
                
                    self.getclientToken(viewController)
                }
                print("CANCELLED")
                
            }else if let result = result {
                
                let selectedPaymentMethod = result.paymentMethod!
                
                if let bt_cus_id = CurrentUser.customer_id, bt_cus_id.isEmpty{
                    
                    CommonFunctions.postNonceToServer(selectedPaymentMethod.nonce)

                }else{
                    
                    CommonFunctions.addCards(selectedPaymentMethod.nonce)

                }
                
            }
            
            controller.dismiss(animated: true, completion: nil)
        }
        
        viewController.present(dropIn!, animated: true, completion: nil)
        
    }

    
    
    static func postNonceToServer(_ paymentMethodNonce: String) {
        
        var params = JSONDictionary()
        params["pm_nonce"] = paymentMethodNonce
        params["amount"] = 0.1
        params["fullname"] = CurrentUser.fullName
        
        self.payWebService(params)
    }
    
    
    static func payWebService(_ params: JSONDictionary){
    
        WebserviceController.payApi(params, succesBlock: { (success, json) in
            
            if success{
                
                let result = json["result"].dictionary ?? [:]
                userDefaults.set(result["ctoken"]?.stringValue, forKey: NSUserDefaultsKeys.C_TOKEN)
                userDefaults.set(result["bt_customer_id"]?.stringValue, forKey: NSUserDefaultsKeys.CUSTOMERID)
                self.signupCompletePop()
            }
        }) { (error) in
            
        }
    }

    static func addCards(_ paymentMethodNonce: String){
        var params = JSONDictionary()

        params["pm_nonce"] = paymentMethodNonce
        params["amount"] = 0.1
        params["fullname"] = CurrentUser.fullName
        params["bt_customer_id"] = CurrentUser.customer_id
        //params["ctoken"] = CurrentUser.c_token

        WebserviceController.addCardAPI(params, succesBlock: { (success, json) in
            
            let result = json["result"].dictionaryValue
            
            NotificationCenter.default.post(name: .setCardNoNotificationName, object: nil, userInfo: result)//(name: setCardNoNotificationName, object: nil)

            
        }) { (error) in
            
        }
    }
    
   static func signupCompletePop(){
        
        let popUp = mainStoryboard.instantiateViewController(withIdentifier: "SignupCompletePopupVC") as! SignupCompletePopupVC
        
        popUp.modalPresentationStyle = .overCurrentContext
        
        APPDELEGATEOBJECT.parentNavigationController.present(popUp, animated: true, completion: nil)
        
    }

    
   static func getJsonObject(_ detail: Any) -> String{
        
        var data = NSData()
    
        do {
            
            data = try JSONSerialization.data(
                withJSONObject: detail ,
                options: JSONSerialization.WritingOptions(rawValue: 0)) as NSData
            
        }catch{
            
        }
    
        let paramData = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
    
        return paramData
    
    }
    
    
   static func stringFromDate(date:Date, dateFormat:String,timeZone:TimeZone = TimeZone.current)->String{
        
        let forematter = DateFormatter()
        forematter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        forematter.timeZone = TimeZone(abbreviation: "UTC")
        forematter.dateFormat = dateFormat
        forematter.timeZone = timeZone
        return forematter.string(from: date)
    }
    
    
   static func dateFromString(dateString:String, dateFormat:String,timeZone:TimeZone = TimeZone.current)->Date?{
        
        let forematter = DateFormatter()
        forematter.locale = Locale(identifier: "en_US_POSIX")
        forematter.timeZone = TimeZone(abbreviation: "UTC")
        forematter.dateFormat = dateFormat
        forematter.timeZone = timeZone
        return forematter.date(from: dateString)
    }

    
   static func openUrlLink(_ url: String){
        
        let openUrl = URL(string: url)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(openUrl!, options: [:])
        } else {
            UIApplication.shared.openURL(openUrl!)
        }
    }

}



func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
    
    var rootVC = rootViewController
    if rootVC == nil {
        rootVC = UIApplication.shared.keyWindow?.rootViewController
    }
    
    if rootVC?.presentedViewController == nil {
        return rootVC
    }
    
    if let presented = rootVC?.presentedViewController {
        if presented.isKind(of: UINavigationController.self) {
            let navigationController = presented as! UINavigationController
            return navigationController.viewControllers.last!
        }
        
        if presented.isKind(of: UITabBarController.self) {
            let tabBarController = presented as! UITabBarController
            return tabBarController.selectedViewController!
        }
        
        return getVisibleViewController(presented)
    }
    return nil
}


func makeLbl(view: UIView,msg: String, color: UIColor) -> UILabel{
    
    let tablelabel = UILabel(frame: CGRect(x: view.center.x, y: view.center.y, width: view.frame.width, height: view.frame.height))
    
    tablelabel.font = .AvenirLTStd_Medium
    
    tablelabel.textColor = color
    
    tablelabel.textAlignment = .center
    
    tablelabel.text = msg
    
    return tablelabel
    
}

func showNodata(_ data: [Any], tableView: UITableView, msg: String, color: UIColor){
    
    if data.isEmpty{
        
        tableView.backgroundView = makeLbl(view: tableView, msg: msg, color: color)
        
        tableView.backgroundView?.isHidden = false
        
    }else{
        
        tableView.backgroundView?.isHidden = true
        
    }
    
}


