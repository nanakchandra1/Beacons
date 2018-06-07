//
//  AppDelegate.swift
//  Parking Caddie
//
//  Created by Appinventiv on 02/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import Fabric
import Crashlytics
import BraintreeDropIn
import Braintree


let APPDELEGATEOBJECT = UIApplication.shared.delegate as! AppDelegate
let ManagedObjectContext = APPDELEGATEOBJECT.managedObjectContext
let googleApiKey = "AIzaSyDxGyXyZdm5RqRKVMRpAAChrbeyXlv8-bY"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var launchedFromPushNotification = false
    var pushData : PushPayLoad?
    var device_Token:String!
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var parentNavigationController : UINavigationController!
    var pushCount:Int = 0
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return self.setLaunchOptions(launchOptions,application: application)
        
    }
    
    
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) -> Void{
        
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        token = token.trimmingCharacters(in: characterSet)
        token = token.replacingOccurrences(of: " ", with: "")
        
        if !token.isEmpty{
            
            self.device_Token = token
        }
        else
        {
            self.device_Token = "123456"
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        self.launchedFromPushNotification = true
        
        let aps = userInfo as? JSONDictionary
        
        self.handlePush(application: application, userInfo: aps! as [NSObject : AnyObject])
        
    }
    
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        if CurrentUser.parkingStaus == myAppconstantStrings.valet || CurrentUser.parkingStaus == myAppconstantStrings.normal{
            
            self.checkParking_status()
            
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Saurabh-Sharma.Parking_Caddie" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Parking_Caddie", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    func handlePush(application: UIApplication,  userInfo: [NSObject: AnyObject]){
        
        guard let info = userInfo as? JSONDictionary else { return }
        guard let aps = info["aps"] as? JSONDictionary else { return }
        print_debug(aps)
        parkingSharedInstance.agentInfo = aps
        self.pushData = PushPayLoad(withPayLoad: aps)
        self.pushCount += 1

        
        if application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background{
            
            if self.pushData?.pushType.lowercased() == PushType.Reserved.lowercased(){
                self.gotoHistoryTab()
                
            }else if self.pushData?.pushType == PushType.notification{
                
                CommonFunctions.gotoFromPushNotification(.profileActive)
                
            }else if self.pushData?.pushType == PushType.ultimate_valet || self.pushData?.pushType == PushType.Request_Pickup || self.pushData?.pushType == PushType.RequestApproval || self.pushData?.pushType == PushType.bring_my_car{
                
                 isUltimateValet = true
                 CommonFunctions.gotoLandingPage()

            }else if self.pushData?.pushType == PushType.park_Now{
            
                let tabbarVC = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                    userDefaults.set(parkingState.valet, forKey: NSUserDefaultsKeys.PARKING_STAUS)
                    tabbarVC.tabBarTempState = TabBarTempState.timer
                    tabbarVC.timerScreeState = TimerScreenState.valet
                
                APPDELEGATEOBJECT.parentNavigationController  = UINavigationController(rootViewController: tabbarVC)
                APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
                APPDELEGATEOBJECT.window?.makeKeyAndVisible()
                APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true

            }
            else{
                
                CommonFunctions.gotoFromPushNotification(.settings)
            }
            
        }else {
            
            if self.pushData?.pushType.lowercased() == PushType.Reserved.lowercased(){
                self.gotoHistoryTab()
                
            }else if self.pushData?.pushType == PushType.ultimate_valet || self.pushData?.pushType == PushType.Request_Pickup || self.pushData?.pushType == PushType.RequestApproval || self.pushData?.pushType == PushType.bring_my_car{
                
                let obj = parkingStoryboard.instantiateViewController(withIdentifier: "AgentInfoPopUpVC") as! AgentInfoPopUpVC
                obj.modalPresentationStyle = .overCurrentContext
                obj.agentDetail = info
                self.parentNavigationController.present(obj, animated: true, completion: nil)
                
            }else if self.pushData?.pushType == PushType.park_Now{
            
                let tabbarVC = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                userDefaults.set(parkingState.valet, forKey: NSUserDefaultsKeys.PARKING_STAUS)
                tabbarVC.tabBarTempState = TabBarTempState.timer
                tabbarVC.timerScreeState = TimerScreenState.valet
                
                APPDELEGATEOBJECT.parentNavigationController  = UINavigationController(rootViewController: tabbarVC)
                APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
                APPDELEGATEOBJECT.window?.makeKeyAndVisible()
                APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true

            }else if self.pushData?.pushType == PushType.exit_Now{
                
                CommonFunctions.gotoLandingPage()
                
            }else if self.pushData?.pushType == PushType.PaymentCash{
                
                self.showReceiptPop(PushType.PaymentCash)
                
            }else if self.pushData?.pushType == PushType.PaymentWeb{
                
                self.showReceiptPop(PushType.PaymentWeb)
                
            }
        }
    }
    
    func gotoHistoryTab(){
    
        let tabbarVC = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        
        tabbarVC.tabBarTempState = TabBarTempState.historyActive
        
        APPDELEGATEOBJECT.parentNavigationController  = UINavigationController(rootViewController: tabbarVC)
        APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
        APPDELEGATEOBJECT.window?.makeKeyAndVisible()
        APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true

    }
    
    
    func showReceiptPop(_ pushType: String){
        
            let popUp = paymentStoryboard.instantiateViewController(withIdentifier: "ReceiptPopUpVC") as! ReceiptPopUpVC
        
            popUp.isPush = true
        
            popUp.pushType = pushType

            popUp.modalPresentationStyle = .overCurrentContext
            
            self.parentNavigationController.present(popUp, animated: true, completion: nil)
        
    }
}


struct PushPayLoad {
    
    let alert:String!
    let pushId : String!
    let pushType: String!
    let parking_id: String!
    let msg:String!
    
    init(withPayLoad : JSONDictionary) {
        
        self.pushId = withPayLoad["push_id"] as? String ?? ""
        self.alert = withPayLoad["alert"] as? String ?? ""
        self.pushType = withPayLoad["push_type"] as? String ?? ""
        self.msg = withPayLoad["message"] as? String ?? ""
        self.parking_id = withPayLoad["parking_id"] as? String ?? ""

    }
}



//extension UIApplication {
//    
//    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//        
//        if let nav = base as? UINavigationController {
//            return topViewController(nav.visibleViewController)
//        }
//        
//        if let tab = base as? UITabBarController {
//            let moreNavigationController = tab.moreNavigationController
//            
//            if let top = moreNavigationController.topViewController, top.view.window != nil {
//                return topViewController(top)
//            } else if let selected = tab.selectedViewController {
//                return topViewController(selected)
//            }
//        }
//        
//        if let presented = base?.presentedViewController {
//            return topViewController(presented)
//        }
//        
//        return base
//    }
//}

