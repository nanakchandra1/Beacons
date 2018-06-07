//
//  NearbyBeaconVC.swift
//  Parking Caddie
//
//  Created by Anuj on 4/28/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import CoreLocation

enum  ParkingLotCatagory {
    case economy,business, indoor,outdoor, ultimate,none
}

class NearbyBeaconVC: UIViewController, ESTBeaconManagerDelegate,CLLocationManagerDelegate,UIScrollViewDelegate,childViewcontrollerDelegate {
    
//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------
    
    let locationManager = CLLocationManager()
    let beaconManager = ESTBeaconManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    var economyController: EconomyBeaconVC!
    var businessController: BusinessBeaconVC!
    var lotEntryBeacon = [BeaconDetailsModel]()
    var timer = Timer()
    let timeInterval:TimeInterval = 1.0
    let timerEnd:TimeInterval = 0.0
    var timeCount:TimeInterval = 600.0
    var timecountForBeacon:TimeInterval = 20.0
    var beaconId = ""
    var eco_lot_catagory:ParkingLotCatagory = .none
    var lot_catagory:String!
    var minorID:Int?
    var tempCatagory = ""
    var buseness_lot_catagory:ParkingLotCatagory = .none

    


    

//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationBarTitle: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var buttonsBgView: UIView!
    @IBOutlet weak var economyBtn: UIButton!
    @IBOutlet weak var businessBtn: UIButton!
    @IBOutlet weak var sliderview: UIView!
    @IBOutlet weak var nearByScrollView: UIScrollView!
    @IBOutlet weak var sliderLeadingConstraint: NSLayoutConstraint!
    
    //pop up view
    
    @IBOutlet weak var popUpBGView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var welcomeLblHightConstraint: NSLayoutConstraint!
    
    
    
    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setUpSubViews()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.timeLbl.text = timeString(timeCount)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,target: self,selector:#selector(NearbyBeaconVC.timerDidEnd),userInfo: "",repeats: true)
        
        self.locationManager.startRangingBeacons(in: self.region)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager.stopRangingBeacons(in: self.region)
        self.locationManager.stopUpdatingLocation()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let view = touches.first?.view {
            if view == self.popUpBGView && !self.popUpBGView.subviews.contains(view) {
                self.popUpBGView.isHidden = true
            }
        }
    }

    
    
//MARK:- IBACTIONS
//MARK:-  -------------------------------------------------------------------------------
    
    
    @IBAction func onTapEconomyBtn(_ sender: UIButton) {
        self.sliderLeadingConstraint.constant = 0
        self.nearByScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func onTapBusinessBtn(_ sender: UIButton) {
        self.sliderLeadingConstraint.constant = screenWidth - (screenWidth / 3) * 2
        self.nearByScrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width , y: 0), animated: true)
    }
    
    
    @IBAction func onTapConfirmedBtn(_ sender: UIButton) {
        
        if !CommonClass.isConnectedToNetwork{
            AppDelegate.showToast(myAppconstantStrings.noInternet)
        }
        else{
            CommonClass.startLoader()
            parkNowWebService()
        }
    }

 
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------

    private func setUpSubViews(){
    
        self.addChildView()
        
        getlotEntryBeacons()
        
        if !CommonClass.isConnectedToNetwork{
            
            AppDelegate.showToast(myAppconstantStrings.noInternet)
        }
        
        self.popUpBGView.isHidden = true
        
        self.confirmBtn.layer.cornerRadius = 3
        
        self.bgView.layer.cornerRadius = 3
        
        self.nearByScrollView.delegate = self
        
        self.setLocationPermission()
        
    }
    
    private func setLocationPermission(){
    
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startRangingBeacons(in: region)
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()


    }
    
    func timeString(_ time:TimeInterval) -> String {
        
        let minutes = Int(time) / 60
        
        let seconds = time - Double(minutes) * 60
        
        let secondsFraction = seconds - Double(Int(seconds))
        
        return String(format:"%02i:%02i",minutes,Int(seconds),Int(secondsFraction * 10.0))
    }

    
    
    
    func timerDidEnd(){
        
        timeCount = timeCount - timeInterval
        
        if timeCount.truncatingRemainder(dividingBy: self.timecountForBeacon) == 0{
            
            self.eco_lot_catagory = .none
            
            self.buseness_lot_catagory = .none
        }
        
        if timeCount <= timerEnd{
            
            timer.invalidate()
            
            self.popUpBGView.isHidden = false
            
            self.confirmBtn.isHidden = true
            
            self.welcomeLblHightConstraint.constant = 220
            
            self.welcomeLbl.text = myAppconstantStrings.parketAt
            
            CommonClass.delay(5, closure: { () -> () in
                
                self.popUpBGView.isHidden = true
                
                self.confirmBtn.isHidden = false
                
                self.welcomeLblHightConstraint.constant = 107
                
            })
        } else {
            
            self.timeLbl.text = timeString(timeCount)
        }
    }
    
    
    func addChildView(){
        
        self.nearByScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        self.economyController = parkingStoryboard.instantiateViewController(withIdentifier: "EconomyBeaconVC") as! EconomyBeaconVC
        
        self.economyController.delegate = self
        
        self.nearByScrollView.frame = economyController.view.frame
        
        self.nearByScrollView.addSubview(economyController.view)
        
        economyController.willMove(toParentViewController: self)
        
        self.addChildViewController(economyController)
        
        self.businessController = parkingStoryboard.instantiateViewController(withIdentifier: "BusinessBeaconVC") as! BusinessBeaconVC
        
        self.businessController.delegate = self
        
        self.nearByScrollView.frame = businessController.view.frame
        
        self.nearByScrollView.addSubview(businessController.view)
        
        businessController.willMove(toParentViewController: self)
        
        self.addChildViewController(businessController)
        
        self.economyController.view.frame.size.height = screenHeight
        
        self.businessController.view.frame.size.height = screenHeight
        
        self.economyController.view.frame.origin = CGPoint.zero
        
        self.businessController.view.frame.origin = CGPoint(x: screenWidth, y: 0)
        
        self.nearByScrollView.contentSize = CGSize(width: screenWidth*3.0,height: 1.0)
        
        self.nearByScrollView.isPagingEnabled = true
    }
    
    
    
    func getBeaconId(_ becon_id: String, catagory: String) {
        
        self.beaconId = becon_id
        
        self.lot_catagory = catagory
    }
    
    
    func parkNowWebService(){
        
        var params = JSONDictionary()
        var data = Data()
        do {
            data = try JSONSerialization.data(
                withJSONObject: parkingSharedInstance.selectedFacility ,
                options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        catch{
        }
        let facilities = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        params = [
            "pa_id"   :CurrentUser.p_id!,
            "bn_id"   : self.beaconId,
            "vehicle" :parkingSharedInstance.vehicle["car_name"]!,
            "plate_no":parkingSharedInstance.vehicle["plate_no"]!
        ]
        
        if CurrentUser.charge != nil{
            params["charge"] = CurrentUser.charge!
        }
        if CurrentUser.charge_type != nil{
            params["charge_type"] = CurrentUser.charge_type!
        }
        
        if CurrentUser.p_catagory != nil{
            
            params["category"] = CurrentUser.p_catagory
        }
        if CurrentUser.tempCoupon_id != nil{
            
            params["coupon_id"] = CurrentUser.tempCoupon_id
        }
        else if CurrentUser.coupon_id != nil{
            
            params["coupon_id"] = CurrentUser.coupon_id
        }
        else{
            
            params["coupon_id"] = ""
        }
        if !parkingSharedInstance.selectedFacility.isEmpty{
            
            params["facilities"] = facilities
            
        }
        
        
        WebserviceController.parkNowService(params, succesBlock: { (success, json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].dictionaryObject ?? [:]
                
                self.timer.invalidate()
                
                let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                
                obj.tabBarTempState = TabBarTempState.timer
                
                obj.timerScreeState = TimerScreenState.normal
                
                obj.agentDetails = result
                
                self.navigationController?.pushViewController(obj, animated: true)
                
            } else {
                
                AppDelegate.showToast(json["message"].stringValue)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
        
    }
        
   
    
    func getlotEntryBeacons(){
        
        for res in parkingSharedInstance.selectedLotDetail.lots{
            
            for value in res.pl_entryb{
                
                matchLotEntryBeacons(value.stringValue)
            }
        }
    }
    
    
    
    func matchLotEntryBeacons(_ id:String){
        
        for res in parkingSharedInstance.beaconsDetails{
            
            if id == res._id{
                
                self.lotEntryBeacon.append(res)
                
            }
        }
    }
    
    
    fileprivate func showPopUp(){
        
        if self.tempCatagory == "ECONOMY"{
            
            self.eco_lot_catagory = .economy
            
        }
            
        else if self.tempCatagory == "BUSINESS"{
            
            self.buseness_lot_catagory = .business
            
        }
        
        self.popUpBGView.isHidden = false
        
        self.confirmBtn.isHidden = true
        
        self.welcomeLblHightConstraint.constant = 220
        
        self.welcomeLbl.text = tempCatagory + " " + myAppconstantStrings.welcome
        
        CommonClass.delay(5, closure: { () -> () in
            
            self.popUpBGView.isHidden = true
            
            self.confirmBtn.isHidden = false
            
            self.welcomeLblHightConstraint.constant = 107
        })
    }

//MARK:- ScrollView Delegate
//MARK:-  -------------------------------------------------------------------------------
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.sliderLeadingConstraint.constant = self.nearByScrollView.contentOffset.x/2
    }

    
//MARK:- CLLocation MAnager Delegate
//MARK:-  -------------------------------------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for res in lotEntryBeacon{
            
            for value in beacons{
                
                let resBnMinor = res.bn_minor
                
                let resBnMajor = res.bn_major

                if resBnMinor == value.minor.intValue{
                    
                    if resBnMajor == value.major.intValue{
                        
                        self.tempCatagory = (res.category ?? "").uppercased()
                        
                        if self.tempCatagory == "ECONOMY"{
                            
                            if self.eco_lot_catagory != ParkingLotCatagory.economy{
                                
                                self.showPopUp()
                                
                                return
                            }
                        }
                        else if self.tempCatagory == "BUSINESS"{
                            
                            if self.buseness_lot_catagory != ParkingLotCatagory.business{
                                
                                self.showPopUp()
                                
                                return
                            }
                        }
                    }
                }
            }
        }
    }
}
