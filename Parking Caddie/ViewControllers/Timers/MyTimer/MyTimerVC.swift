//
//  MyTimerVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import CoreBluetooth
import SwiftyJSON

var timeCount:TimeInterval = 0.0
var progressValue: Float = 0

enum TimerState{
    case normal,parked,none
}

enum ParkingTimerStatus {
    case start,current
}

enum BluetoothPower{
    case on , off
}



class MyTimerVC: UIViewController,CLLocationManagerDelegate,ESTBeaconManagerDelegate{
    
//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------

    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationTitleLbl: UILabel!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var detailBgView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var chargrLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var parkingCatagoryLbl: UILabel!
    @IBOutlet weak var beaconIdLbl: UILabel!
    @IBOutlet weak var parkingTimeLbl: UILabel!
    @IBOutlet weak var personNameLbl: UILabel!
    @IBOutlet weak var contactNoLbl: UILabel!
    
        //pop up view
    
    @IBOutlet weak var poipUpBgView: UIView!
    @IBOutlet weak var bgViiew: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var noparkingView: UIView!
    
   
//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------

    var myBTManager:CBPeripheralManager!
    var agent_Details = JSONDictionary()
    var locationVC: ParkingLocationVC!
    var bl_power_On_Off:BluetoothPower = .on
    var timer_state:TimerState = TimerState.none
    var normal_Timer =  Timer()
    var bluetoothTimer = Timer()
    var allowTime = Timer()
    var recieptDetail = HistoryModel()
    var beaconsDetail = [BeaconDetailsModel]()
    var temp_beaconsDetail = [BeaconDetailsModel]()

    var parkingStatus:ParkingTimerStatus = .start
    var areaExitBeacon = JSONArray()
    var parkingBeaconName = ""
    var charge:String?
    var charge_update:PriceUpdate = PriceUpdate.zero
    var tapGasture: UITapGestureRecognizer!

    
    
    fileprivate var circleSlider: CircleSlider! {
        didSet {
            self.circleSlider.tag = 0
        }
    }
    
    fileprivate var progressLabel: UILabel!
    var normal_timer = Timer()
    let timeInterval:TimeInterval = 1
    var count:TimeInterval = 0.0
    fileprivate var progrss: Float = 0
    
    fileprivate var sliderOptions: [CircleSliderOption] {
        return [
            CircleSliderOption.barColor(UIColor.lightGray),
            CircleSliderOption.thumbColor(UIColor.appBlue),
            CircleSliderOption.trackingColor(UIColor.appBlue),
            CircleSliderOption.barWidth(10),
            CircleSliderOption.startAngle(-90),
            CircleSliderOption.maxValue(150),
            CircleSliderOption.minValue(0)
        ]
    }
    
    
    let locationManager = CLLocationManager()
    let beaconManager = ESTBeaconManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    
 
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.parkingCatagoryLbl.text = ""

        if self.timer_state == TimerState.parked{
            
            self.noparkingView.isHidden = true

            self.setparkingInfo()

            if CurrentUser.parkingStaus == parkingState.Processing || CurrentUser.parkingStaus == nil{
                
                userDefaults.set(parkingState.normal, forKey: NSUserDefaultsKeys.PARKING_STAUS)
                timeCount = 0
                progressValue = 0
            }
        }else if self.timer_state == TimerState.normal{
            
            self.setParkingDataWithoutParking()
            
        }
        
        self.poipUpBgView.isHidden = true
        
        parkingSharedInstance.disableTab = true
        
        self.bgViiew.layer.cornerRadius = 3
        
        self.timerView.layer.cornerRadius = self.timerView.frame.width / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.payNow(userInfo:)), name: .PayNowNotificationName, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.timer_state == TimerState.parked{
            self.timerLbl.text = timeString(timeCount)
            self.checkParking_status()

        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.normal_Timer.invalidate()
       // timeCount = 0
        progressValue = 0
        bluetoothTimer.invalidate()
        self.locationManager.stopUpdatingLocation()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    


//MARK:- IBActions
//MARK:-  -------------------------------------------------------------------------------

    @IBAction func onTapExitBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: myAppconstantStrings.exit_parking, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: {
            alertAction in self.exitArea()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    
//MARK:- TIMER CIRCLE AND SLIDER
//MARK:-  -------------------------------------------------------------------------------
    
    fileprivate func buildCircleSlider() {
        self.circleSlider = CircleSlider(frame: self.timerView.bounds, options: self.sliderOptions)
        self.circleSlider.backgroundColor = UIColor.clear
        self.timerView.addSubview(self.circleSlider!)
        self.chargrLbl.text = "CURRENT CHARGES"
        if self.timer_state == TimerState.parked{
            self.rateLbl.text = "$0"
        }
        else if self.timer_state == TimerState.normal{
            self.rateLbl.text = ""
        }
    }
    
    
    func valueChange() {
        
            self.normal_Timer.invalidate()
            self.normal_Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MyTimerVC.fire), userInfo: nil, repeats: true)
    }
    
    
    func fire() {
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            timeCount = timeCount + self.timeInterval
            progressValue = Float((timeCount.truncatingRemainder(dividingBy: 3600)) / 24)
            if CurrentUser.charge_type != nil{
                if CurrentUser.charge_type == myAppconstantStrings.per_hr{
                    let charge = Double(Int(timeCount / 3600) + 1) * Double(self.charge!)!.roundToPlaces(2)
                self.rateLbl.text = "$" + String(format:"%.2f",charge)                }
                else{
                    let charge = Double(Int(timeCount / 86400) + 1) * Double(self.charge!)!.roundToPlaces(2)

                    self.rateLbl.text = "$" + String(format:"%.2f",charge)
                }
            }
            self.progrss = progressValue
            self.timerLbl.text = self.timeString(timeCount)
            self.circleSlider.value = self.progrss
        })
    }
    
    
    func timeString(_ time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        return String(format:"%02i:%02i",hours,minutes)
    }
    
    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------

    func setparkingInfo(){
        
        self.myBTManager = CBPeripheralManager()
        self.exitBtn.isHidden = false
        self.locationVC = tabbarStoryboard.instantiateViewController(withIdentifier: "ParkingLocationVC") as! ParkingLocationVC
        self.buildCircleSlider()
    }
    
    
    func setParkingDataWithoutParking(){
        
        self.buildCircleSlider()
        self.exitBtn.isHidden = true
        self.noparkingView.isHidden = false
        self.locationLbl.text = myAppconstantStrings.not_available
        self.personNameLbl.text = myAppconstantStrings.not_available
        self.contactNoLbl.text = myAppconstantStrings.not_available
        self.beaconIdLbl.text = myAppconstantStrings.not_available
        self.parkingCatagoryLbl.text = myAppconstantStrings.not_available
        self.parkingTimeLbl.text = myAppconstantStrings.not_available
        self.navigationTitleLbl.text = "PARKING"
    }
    
    func openDialPad(_ sender:UITapGestureRecognizer){
        let url  = URL(string: "tel://" + self.contactNoLbl.text!)
        if UIApplication.shared.canOpenURL(url!) == true  {
            UIApplication.shared.openURL(url!)
        }
    }
    
    func checkParking_status(){
        
        CommonClass.startLoader()
        
        WebserviceController.checkParkingStatus({ (success, json) in
            
            if success{
                
                let result = json["result"]
                let parkingDetail = NormalParkingModel(result)
                self.charge = parkingDetail.charge

                self.valueChange()
                
                self.personNameLbl.text = parkingDetail.ag_name

                self.contactNoLbl.text = parkingDetail.ag_phone
                
                self.contactNoLbl.isUserInteractionEnabled = true
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(MyTimerVC.openDialPad(_:)))
                
                self.contactNoLbl.addGestureRecognizer(tap)

                self.parkingTimeLbl.text = parkingDetail.date.convertTimeWithTimeZone(formate: DateFormate.dateWithTime)
                
                let duration = parkingDetail.duration
                
                let seconds = Int(duration! * 3600)
                
                timeCount = TimeInterval(seconds)
                
                progressValue = Float((timeCount.truncatingRemainder(dividingBy: 3600)) / 25)

                self.parkingCatagoryLbl.text = (parkingDetail.category ?? "").capitalized

                userDefaults.set(parkingDetail.charge_type, forKey: NSUserDefaultsKeys.CHARGE_TYPE)

                self.locationLbl.text = parkingDetail.pa_name

                self.areaExitBeacon = parkingDetail.areaexit

                self.beaconsDetail = parkingDetail.beaconDetails
                self.temp_beaconsDetail = parkingDetail.beaconDetails
                self.getParkingBeacon()

            }else{
            
                if json["code"].intValue == 225 {
                
                    self.removeDataFromUserDefault()
                    self.normal_Timer.invalidate()
                    progressValue = 0
                    timeCount = 0.0
                    let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                    obj.tabBarTempState = TabBarTempState.search
                    self.navigationController?.pushViewController(obj, animated: true)

                }
            }
        }) { (error) in
            
            self.locationLbl.text = myAppconstantStrings.not_available
            self.parkingTimeLbl.text = myAppconstantStrings.not_available
            self.personNameLbl.text = myAppconstantStrings.not_available
            self.contactNoLbl.text = myAppconstantStrings.not_available
            self.parkingCatagoryLbl.text = myAppconstantStrings.not_available
            self.beaconIdLbl.text = myAppconstantStrings.not_available
            self.normal_Timer.invalidate()
            progressValue = 0
            timeCount = 0.0
            
        }
    }
    
    func getParkingBeacon(){
        
        for res in self.beaconsDetail{
        
            if (res.bn_type ?? "").lowercased() == "parking"{
                
                self.beaconIdLbl.text = res.bn_name
            }
        }
        
    }

    
    func payNow(userInfo: Notification){
    
        let info = JSON(userInfo.userInfo!)
        let token = info["cToken"].stringValue
        self.locationManager.stopUpdatingLocation()
        self.exitNormalParkingWebService(token)
        
    }
    
    
    //MARK:- Alert Method for bluetooth
    //MARK:- ****************************************************
    
    
    func showAlertForBluetooth(){
        if isBluetoothOn(){
            alertForBluetooth()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print_debug("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print_debug("Access")
            }
        } else {
            alertForLocation(myAppconstantStrings.locationService)
        }
    }
    
    
    func isBluetoothOn() -> Bool {
        if myBTManager.state == .poweredOff {
            return true
        }
        return false
    }
    
    func alertForBluetooth(){
        self.myBTManager = CBPeripheralManager()
    }
    
    func alertForLocation(_ msg:String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: {
            alertAction in self.turnBluetoothon()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func turnBluetoothon(){
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
    }

    func starBeaconScanning(){
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startRangingBeacons(in: self.region)
        self.locationManager.delegate = self
    }
    
    func exitArea(){
        
        self.normal_Timer.invalidate()
        progressValue = 0
       // timeCount = 0.0
        self.starBeaconScanning()
        self.bluetoothTimer.invalidate()
        self.bluetoothTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MyTimerVC.showAlertForBluetooth), userInfo: nil, repeats: true)
        CommonClass.startLoader()
    }
    
    
    fileprivate func removeDataFromUserDefault(){
        
        UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.PARKING_STAUS)
    }
    
    
    
    func exitNormalParkingWebService(_ c_token: String){

        let duration = timeCount / 3600
        
        var params = JSONDictionary()
        
        params["duration"] = duration.roundToPlaces(2)
        params["token"] = c_token

        WebserviceController.exitParkingService(params, succesBlock: { (success, json) in
            
            if success{

                let result = json["result"]
                
//                self.poipUpBgView.isHidden = false
//                
//                parkingSharedInstance.disableTab = false
//                
//                self.msgLbl.text = myAppconstantStrings.agentApproval

                self.recieptDetail = HistoryModel(result)

                let receipt = ExitParkingModel(result)
                
                userDefaults.set(receipt.parking_id ?? "", forKey: NSUserDefaultsKeys.PARKING_ID)
                if receipt.payment_success{
                
                    self.showReceiptPopUp(with: receipt)

                }else{
                
                    self.showReceiptPopUp(with: receipt)

                }
            }
            
        }) { (error) in
            
        }
    }
    
    
    func showReceiptPopUp(with receipt: ExitParkingModel){
    
        let obj = paymentStoryboard.instantiateViewController(withIdentifier: "ReceiptPopUpVC") as! ReceiptPopUpVC
        
        if receipt.payment_success{
            
            obj.delegate = self
            
        }
        
        obj.recieptDetail = receipt
        obj.modalPresentationStyle = .overCurrentContext
        
        APPDELEGATEOBJECT.parentNavigationController.present(obj, animated: true, completion: nil)

    }
    
    func allowedExitParking(){
        
        timeCount = timeCount + self.timeInterval
        
        if timeCount < 600{
            
            WebserviceController.exitAlloewdService({ (success, json) in
                
                print_debug(json)
                
                if success{
                
                    self.allowTime.invalidate()
                    
                    timeCount = 0.0
                    
                    self.msgLbl.text = myAppconstantStrings.thanks
                    
                    self.removeDataFromUserDefault()
                    
                    CommonClass.delay(5, closure: {
                        
                        self.poipUpBgView.isHidden = true
                        
                        parkingSharedInstance.disableTab = true
                        
                        let obj = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "ReceiptVC") as! ReceiptVC
                        
                        obj.receiptState = ReceiptState.exit
                        
                        obj.p_id = CurrentUser.parking_id ?? ""
                        
                        self.navigationController?.pushViewController(obj, animated: true)
                        
                    })
                }else{
                
                    if json["code"].intValue == 225 {
                        
                        CommonClass.clearPrefrences()

                    }
                }
                
            }, failureBlock: { (error) in
                
                
            })
            
        }
        else{
            
         allowTime.invalidate()
            
        timeCount = 0.0
            
        AppDelegate.showToast(myAppconstantStrings.agentContact)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for res in beacons{
            
            let minor = res.minor.intValue
            let major = res.major.intValue
            
            if self.beaconsDetail.count != 0{
                
                for beacon in self.beaconsDetail{
                    
                    guard let ex_minor = beacon.bn_minor else {return}
                    guard let ex_major = beacon.bn_major else {return}

                    if minor == ex_minor {
                        
                        if major == ex_major{
                            
                            self.beaconsDetail.removeAll()

                            beaconManager.stopMonitoring(for: region)
                            
                            self.locationManager.stopUpdatingLocation()
                            
                            self.exitNormalParkingWebService(CurrentUser.c_token ?? "")
                            
                            self.locationVC.parkingArea = Parking_Area_SlotCount.parkingAreas
                        }
                    }
                }
            }
        }
    }
}


//MARK:- Allow Exit parking
//MARK:- ==================================

extension MyTimerVC: AllowExitDelegate{

    func allowExitParking() {
        
        self.poipUpBgView.isHidden = false
        
        parkingSharedInstance.disableTab = false
        
        self.msgLbl.text = myAppconstantStrings.agentApproval

        self.allowedExitParking()
        
        self.allowTime = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MyTimerVC.allowedExitParking), userInfo: nil, repeats: true)

    }

}
