//
//  TabBarVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 07/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

enum TabBarState{
    
    case search,historyActive,timer,profileActive,settings,none
}

enum TabBarTempState {
    case search,historyActive,timer,profileActive,settings
}

enum TimerScreenState{
    case normal,valet,none
}


class TabBarVC: UIViewController {
    
    var token: String!
    var agentDetails = JSONDictionary()
    var locationVC: ParkingLocationVC!
    var timer_State:TimerState!
    var timerScreeState: TimerScreenState = .none
    var tabBarTempState: TabBarTempState = .search
    var tabBarState : TabBarState = .none {
        willSet {
            
            switch newValue {
                
            case .search:
                self.historySearchBtn.isSelected = true
                self.historyActiveBtn.isSelected = false
                self.timerBtn.isSelected = false
                self.profileActiveBtn.isSelected = false
                self.settingsBtn.isSelected = false
                self.historySearchBtn.setImage(UIImage(named: "search_active"), for: UIControlState())
                self.historyActiveBtn.setImage(UIImage(named: "history"), for: UIControlState())
                self.timerBtn.setImage(UIImage(named: "timer"), for: UIControlState())
                self.profileActiveBtn.setImage(UIImage(named: "profile"), for: UIControlState())
                self.settingsBtn.setImage(UIImage(named: "settings"), for: UIControlState())
                self.historySearchBtn.backgroundColor = UIColor(red: 242.0 / 255.0, green: 208.0 / 255.0, blue: 18.0 / 255.0, alpha: 1)
                self.historyActiveBtn.backgroundColor = UIColor.clear
                self.timerBtn.backgroundColor = UIColor.clear
                self.profileActiveBtn.backgroundColor = UIColor.clear
                self.settingsBtn.backgroundColor = UIColor.clear
                
                
            case .historyActive:
                self.historySearchBtn.isSelected = false
                self.historyActiveBtn.isSelected = true
                self.timerBtn.isSelected = false
                self.profileActiveBtn.isSelected = false
                self.settingsBtn.isSelected = false
                self.historySearchBtn.setImage(UIImage(named: "search"), for: UIControlState())
                self.historyActiveBtn.setImage(UIImage(named: "history_active"), for: UIControlState())
                self.timerBtn.setImage(UIImage(named: "timer"), for: UIControlState())
                self.profileActiveBtn.setImage(UIImage(named: "profile"), for: UIControlState())
                self.settingsBtn.setImage(UIImage(named: "settings"), for: UIControlState())
                self.historyActiveBtn.backgroundColor = UIColor(red: 242.0 / 255.0, green: 208.0 / 255.0, blue: 18.0 / 255.0, alpha: 1)
                self.historySearchBtn.backgroundColor = UIColor.clear
                self.timerBtn.backgroundColor = UIColor.clear
                self.profileActiveBtn.backgroundColor = UIColor.clear
                self.settingsBtn.backgroundColor = UIColor.clear
                
                
                
                
            case .timer:
                self.historySearchBtn.isSelected = false
                self.historyActiveBtn.isSelected = false
                self.timerBtn.isSelected = true
                self.profileActiveBtn.isSelected = false
                self.settingsBtn.isSelected = false
                self.historySearchBtn.setImage(UIImage(named: "search"), for: UIControlState())
                self.historyActiveBtn.setImage(UIImage(named: "history"), for: UIControlState())
                self.timerBtn.setImage(UIImage(named: "timer_active"), for: UIControlState())
                self.profileActiveBtn.setImage(UIImage(named: "profile"), for: UIControlState())
                self.settingsBtn.setImage(UIImage(named: "settings"), for: UIControlState())
                self.timerBtn.backgroundColor = UIColor(red: 242.0 / 255.0, green: 208.0 / 255.0, blue: 18.0 / 255.0, alpha: 1)
                self.historySearchBtn.backgroundColor = UIColor.clear
                self.historyActiveBtn.backgroundColor = UIColor.clear
                self.profileActiveBtn.backgroundColor = UIColor.clear
                self.settingsBtn.backgroundColor = UIColor.clear
                
                
            case .profileActive:
                self.historySearchBtn.isSelected = false
                self.historyActiveBtn.isSelected = false
                self.timerBtn.isSelected = false
                self.profileActiveBtn.isSelected = true
                self.settingsBtn.isSelected = false
                self.historySearchBtn.setImage(UIImage(named: "search"), for: UIControlState())
                self.historyActiveBtn.setImage(UIImage(named: "history"), for: UIControlState())
                self.timerBtn.setImage(UIImage(named: "timer"), for: UIControlState())
                self.profileActiveBtn.setImage(UIImage(named: "profile_active"), for: UIControlState())
                self.settingsBtn.setImage(UIImage(named: "settings"), for: UIControlState())
                self.profileActiveBtn.backgroundColor = UIColor(red: 242.0 / 255.0, green: 208.0 / 255.0, blue: 18.0 / 255.0, alpha: 1)
                self.historySearchBtn.backgroundColor = UIColor.clear
                self.historyActiveBtn.backgroundColor = UIColor.clear
                self.timerBtn.backgroundColor = UIColor.clear
                self.settingsBtn.backgroundColor = UIColor.clear
                
                
            case .settings:
                self.historySearchBtn.isSelected = false
                self.historyActiveBtn.isSelected = false
                self.timerBtn.isSelected = false
                self.profileActiveBtn.isSelected = false
                self.settingsBtn.isSelected = true
                self.historySearchBtn.setImage(UIImage(named: "search"), for: UIControlState())
                self.historyActiveBtn.setImage(UIImage(named: "history"), for: UIControlState())
                self.timerBtn.setImage(UIImage(named: "timer"), for: UIControlState())
                self.profileActiveBtn.setImage(UIImage(named: "profile"), for: UIControlState())
                self.settingsBtn.setImage(UIImage(named: "settings_active"), for: UIControlState())
                self.settingsBtn.backgroundColor = UIColor(red: 242.0 / 255.0, green: 208.0 / 255.0, blue: 18.0 / 255.0, alpha: 1)
                self.historySearchBtn.backgroundColor = UIColor.clear
                self.historyActiveBtn.backgroundColor = UIColor.clear
                self.profileActiveBtn.backgroundColor = UIColor.clear
                self.timerBtn.backgroundColor = UIColor.clear
                
                
            case .none:
                self.historySearchBtn.isSelected = false
                self.historyActiveBtn.isSelected = false
                self.timerBtn.isSelected = false
                self.profileActiveBtn.isSelected = false
                self.settingsBtn.isSelected = false
            }
        }
    }
    
    //MARK:- Outlets
    //MARK:-
    @IBOutlet weak var tabBarBgView: UIView!
    @IBOutlet weak var historySearchBtn: UIButton!
    @IBOutlet weak var historyActiveBtn: UIButton!
    @IBOutlet weak var timerBtn: UIButton!
    @IBOutlet weak var profileActiveBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    
    
    //MARK:- viewDidLoad Method
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubview(toFront: self.tabBarBgView)
        self.tabBarBgView.layer.borderWidth = 1
        self.tabBarBgView.layer.borderColor  = UIColor.gray.cgColor
        self.locationVC = tabbarStoryboard.instantiateViewController(withIdentifier: "ParkingLocationVC") as! ParkingLocationVC
        
        
        if self.tabBarTempState == TabBarTempState.search{
            self.tabBarState = TabBarState.search
            self.setLocation()
        }
        else if self.tabBarTempState == TabBarTempState.timer{
            self.timer()
        }
        else if self.tabBarTempState == TabBarTempState.historyActive{
            self.history()
        }
        else if self.tabBarTempState == TabBarTempState.profileActive{
            profile()
        }
        else if self.tabBarTempState == TabBarTempState.settings{
            self.setting()
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Reset View Hierarchy
    //MARK:-
    
    func resetViewHierarchy() {
        
        self.view.bringSubview(toFront: self.tabBarBgView)
    }
    
    //MARK:- Tab bar Buttons Action
    //MARK:-
    
    //SearchHistory Button action
    @IBAction func onTapSearchHistoryBtn(_ sender: UIButton) {
        if parkingSharedInstance.disableTab{

        if self.timerScreeState != TimerScreenState.none || CurrentUser.parkingStaus != nil{
            
        }else{
            let principalScene = tabbarStoryboard.instantiateViewController(withIdentifier: "ParkingLocationVC") as! ParkingLocationVC
            self.view.addSubview(principalScene.view)
            self.addChildViewController(principalScene)
            principalScene.willMove(toParentViewController: self)
            
            for childVC in self.childViewControllers {
                if childVC === principalScene {
                    
                } else {
                    
                    childVC.view.removeFromSuperview()
                    childVC.removeFromParentViewController()
                }
            }
            
            self.resetViewHierarchy()
            self.tabBarState = TabBarState.search
            }
        }
    }
    
    // Active History Button action
    @IBAction func onTapHistoryActiveBtn(_ sender: UIButton) {
        if parkingSharedInstance.disableTab{

        let principalScene = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "MyParkingVC") as! MyParkingVC
            
        self.view.addSubview(principalScene.view)
            
        self.addChildViewController(principalScene)
            
        principalScene.willMove(toParentViewController: self)
        
        for childVC in self.childViewControllers {
            
            if childVC === principalScene {
                
            } else {
                
                childVC.view.removeFromSuperview()
                
                childVC.removeFromParentViewController()
            }
        }
        self.resetViewHierarchy()
            
        self.tabBarState = TabBarState.historyActive
        }
    }
    
    
    //Timer Button action
    @IBAction func onTapTimerBtn(_ sender: UIButton) {
        
        if parkingSharedInstance.disableTab{
            
        self.locationVC.parkingArea = Parking_Area_SlotCount.parkingAreas
        
        if CurrentUser.parkingStaus == myAppconstantStrings.valet{
            
            let principalScene = parkingStoryboard.instantiateViewController(withIdentifier: "ValetParkingTimerVC") as! ValetParkingTimerVC
            
            principalScene.agent_Details = self.agentDetails
            
            if CurrentUser.parkingStaus != nil{
                
                principalScene.timerstate = TimerState.parked
            }
            else{
                principalScene.timerstate = TimerState.normal
            }
            self.view.addSubview(principalScene.view)
            
            self.addChildViewController(principalScene)
            
            principalScene.willMove(toParentViewController: self)
            
            for childVC in self.childViewControllers {
                
                if childVC === principalScene {
                    
                } else {
                    
                    childVC.view.removeFromSuperview()
                    childVC.removeFromParentViewController()
                }
            }
        }
        else{
            let principalScene = parkingStoryboard.instantiateViewController(withIdentifier: "MyTimerVC") as! MyTimerVC
            if CurrentUser.parkingStaus != nil{
                principalScene.timer_state = TimerState.parked
            }
            else{
                principalScene.timer_state = TimerState.normal
            }
            principalScene.agent_Details = self.agentDetails
            self.view.addSubview(principalScene.view)
            self.addChildViewController(principalScene)
            principalScene.willMove(toParentViewController: self)
            for childVC in self.childViewControllers {
                if childVC === principalScene {
                } else {
                    childVC.view.removeFromSuperview()
                    childVC.removeFromParentViewController()
                }
            }
        }
        self.resetViewHierarchy()
        self.tabBarState = TabBarState.timer
        }
    }
    
    //profle Button action
    
    @IBAction func onTapProfileActiveBtn(_ sender: UIButton) {
        if parkingSharedInstance.disableTab{

        locationVC.zoomLavel = Zoom_in_Zoom_Out.zoomin
        let principalScene = tabbarStoryboard.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.view.addSubview(principalScene.view)
        self.addChildViewController(principalScene)
        principalScene.willMove(toParentViewController: self)
        for childVC in self.childViewControllers {
            if childVC === principalScene {
            } else {
                childVC.view.removeFromSuperview()
                childVC.removeFromParentViewController()
            }
            self.resetViewHierarchy()
            self.tabBarState = TabBarState.profileActive
        }
        }
    }
    
    //Settings Button action
    @IBAction func onTapSettingsBtn(_ sender: UIButton) {
        if parkingSharedInstance.disableTab{

        locationVC.zoomLavel = Zoom_in_Zoom_Out.zoomin
        let principalScene = tabbarStoryboard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self.view.addSubview(principalScene.view)
        self.addChildViewController(principalScene)
        principalScene.willMove(toParentViewController: self)
        for childVC in self.childViewControllers {
            if childVC === principalScene {
            } else {
                childVC.view.removeFromSuperview()
                childVC.removeFromParentViewController()
            }
            self.resetViewHierarchy()
            self.tabBarState = TabBarState.settings
        }
        }
    }
    
    
    func setLocation(){
        locationVC.zoomLavel = Zoom_in_Zoom_Out.zoomin
        let principalScene = tabbarStoryboard.instantiateViewController(withIdentifier: "ParkingLocationVC") as! ParkingLocationVC
        self.view.addSubview(principalScene.view)
        self.addChildViewController(principalScene)
        principalScene.willMove(toParentViewController: self)
        for childVC in self.childViewControllers {
            if childVC === principalScene {
            } else {
                childVC.view.removeFromSuperview()
                childVC.removeFromParentViewController()
            }
        }
        self.resetViewHierarchy()
        self.tabBarState = TabBarState.search
    }
    
    
    
    func timer(){
        if self.timerScreeState == TimerScreenState.normal{
            let principalScene = parkingStoryboard.instantiateViewController(withIdentifier: "MyTimerVC") as! MyTimerVC
            principalScene.timer_state = TimerState.parked
            principalScene.agent_Details = self.agentDetails
            self.view.addSubview(principalScene.view)
            self.addChildViewController(principalScene)
            principalScene.willMove(toParentViewController: self)
            for childVC in self.childViewControllers {
                if childVC === principalScene {
                } else {
                    childVC.view.removeFromSuperview()
                    childVC.removeFromParentViewController()
                }
            }
            
        }
        else if self.timerScreeState == TimerScreenState.valet{
            let principalScene = parkingStoryboard.instantiateViewController(withIdentifier: "ValetParkingTimerVC") as! ValetParkingTimerVC
            self.view.addSubview(principalScene.view)
            self.addChildViewController(principalScene)
            principalScene.willMove(toParentViewController: self)
            for childVC in self.childViewControllers {
                if childVC === principalScene {
                } else {
                    childVC.view.removeFromSuperview()
                    childVC.removeFromParentViewController()
                }
            }
        }
        self.resetViewHierarchy()
        self.tabBarState = TabBarState.timer
    }
    
    
    func history(){
        let principalScene = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "MyParkingVC") as! MyParkingVC
        self.view.addSubview(principalScene.view)
        self.addChildViewController(principalScene)
        principalScene.willMove(toParentViewController: self)
        for childVC in self.childViewControllers {
            if childVC === principalScene {
            } else {
                childVC.view.removeFromSuperview()
                childVC.removeFromParentViewController()
            }
        }
        self.resetViewHierarchy()
        self.tabBarState = TabBarState.historyActive
    }
    
    func profile(){
        let principalScene = settingsStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.view.addSubview(principalScene.view)
        self.addChildViewController(principalScene)
        principalScene.willMove(toParentViewController: self)
        for childVC in self.childViewControllers {
            if childVC === principalScene {
            } else {
                childVC.view.removeFromSuperview()
                childVC.removeFromParentViewController()
            }
            self.resetViewHierarchy()
            self.tabBarState = TabBarState.profileActive
        }
    }
    
    func setting(){
        let principalScene = settingsStoryboard.instantiateViewController(withIdentifier: "PromotionsVC") as! PromotionsVC
        self.view.addSubview(principalScene.view)
        self.addChildViewController(principalScene)
        principalScene.willMove(toParentViewController: self)
        for childVC in self.childViewControllers {
            if childVC === principalScene {
            } else {
                childVC.view.removeFromSuperview()
                childVC.removeFromParentViewController()
            }
            self.resetViewHierarchy()
            self.tabBarState = TabBarState.settings
        }
    }
}
