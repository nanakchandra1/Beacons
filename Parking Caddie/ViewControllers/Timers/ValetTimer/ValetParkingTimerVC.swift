//
//  ValetParkingTimerVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 14/06/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import CoreBluetooth

enum PriceUpdate {
    case zero,one
}

class ValetParkingTimerVC: UIViewController,CLLocationManagerDelegate,ESTBeaconManagerDelegate {
    
    //MARK:- IBOutlets
    //MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationTitleLbl: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var chargrLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var bringMyCarBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var pickUpBtn: UIButton!
    
    //pop up view
    
    @IBOutlet weak var poipUpBgView: UIView!
    @IBOutlet weak var bgViiew: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    // pickere popup view
    
    @IBOutlet weak var terminalPickerBgView: UIView!
    @IBOutlet weak var exitTerminalPickerView: UIPickerView!
    @IBOutlet weak var doneBtn: UIView!
    @IBOutlet weak var slectExitLbl: UILabel!
    
    
    //MARK:- Properties
    //MARK:-  -------------------------------------------------------------------------------
    
    var myBTManager:CBPeripheralManager!
    var agent_Details = JSONDictionary()
    var locationVC: ParkingLocationVC!
    var bl_power_On_Off:BluetoothPower = .on
    var timerstate:TimerState!
    var valet_Timer = Timer()
    var bluetoothTimer = Timer()
    var Pre_aloeTime = Timer()
    var pre_agentDetail = HistoryModel()
    var preBeaconsDetail = [BeaconDetailsModel]()
    var prem_Charge:String?
    var price_update:PriceUpdate = .zero
    var exitTerminal = [ExitTerminalModel]()
    var teriminal = [String:String]()
    var bringMyCarPara = JSONDictionary()
    fileprivate var circleSlider: CircleSlider! {
        didSet {
            self.circleSlider.tag = 0
        }
    }
    
    fileprivate var progressLabel: UILabel!
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
    var matchAreaExitBeacon = [[String:AnyObject]]()
    
    
    //MARK:- View life cycle
    //MARK:-  -------------------------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildCircleSlider()
        self.terminalPickerBgView.isHidden = true
        self.terminalPickerBgView.layer.cornerRadius = 3
        self.pickUpBtn.layer.cornerRadius = 3
        
        checkValetParking_status()
        
        if CurrentUser.parkingStaus == nil{
            
            userDefaults.set(parkingState.valet, forKey:NSUserDefaultsKeys.PARKING_STAUS)
            
            
            timeCount = 0.0
            progressValue = 0
            
        }
        
        self.myBTManager = CBPeripheralManager()
        self.bringMyCarBtn.layer.cornerRadius = 3
        self.locationVC = tabbarStoryboard.instantiateViewController(withIdentifier: "ParkingLocationVC") as! ParkingLocationVC
        
        self.poipUpBgView.isHidden = true
        self.bgViiew.layer.cornerRadius = 3
        self.timerView.layer.cornerRadius = self.timerView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.timerLbl.text = timeString(timeCount)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.valet_Timer.invalidate()
        timeCount = 0
        progressValue = 0
        bluetoothTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        if let view = touches.first?.view {
        //            if view == self.poipUpBgView && !self.poipUpBgView.subviews.contains(view) {
        //                self.poipUpBgView.hidden = true
        //            }
        //        }
    }
    
    
    //MARK:- IBActions
    //MARK:-  -------------------------------------------------------------------------------
    
    @IBAction func onTapBringMyCar(_ sender: UIButton) {
        
        let obj = parkingStoryboard.instantiateViewController(withIdentifier: "RequestPickUpVC") as! RequestPickUpVC
        obj.modalPresentationStyle = .overCurrentContext
        obj.delegate = self
        obj.exitTerminal = self.exitTerminal
        self.present(obj, animated: true, completion: nil)
        
        //        let alert = UIAlertController(title: "Alert", message: myAppconstantStrings.exit_parking, preferredStyle: UIAlertControllerStyle.alert)
        //        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: {
        //            alertAction in self.exitPremiumArea()
        //        }))
        //        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        //        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func onTapPickMeUp(_ sender: UIButton) {
        
        let obj = parkingStoryboard.instantiateViewController(withIdentifier: "PickMeUpVC") as! PickMeUpVC
        obj.modalPresentationStyle = .overCurrentContext
        obj.delegate = self
        self.present(obj, animated: true, completion: nil)
        
    }
    
    
    @IBAction func onTapDoneButton(_ sender: UIButton) {
        
        CommonClass.startLoader()
        
        if let _ = self.teriminal["terminal_id"]{
            
            self.bringmy_car()
            
        }else{
            
            guard !self.exitTerminal.isEmpty else {return}
            
            self.teriminal["terminal_id"] = self.exitTerminal.first?._id ?? ""
                
            self.teriminal["terminal_name"] = self.exitTerminal.first?.ploc_name ?? ""
                
            self.bringmy_car()
        }
    }
    
    
    //MARK:- Functions
    //MARK:-  -------------------------------------------------------------------------------
    
    
    fileprivate func buildCircleSlider() {
        
        self.circleSlider = CircleSlider(frame: self.timerView.bounds, options: self.sliderOptions)
        
        self.circleSlider.backgroundColor = UIColor.clear
        
        self.timerView.addSubview(self.circleSlider!)
        
        self.chargrLbl.text = "CURRENT CHARGES"
        
        self.rateLbl.text = "$0"
    }
    
    
    func valueChange() {
        
        self.valet_Timer.invalidate()
        
        self.valet_Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ValetParkingTimerVC.fire), userInfo: nil, repeats: true)
    }
    
    
    func fire() {
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            timeCount = timeCount + self.timeInterval
            
            progressValue = Float((timeCount.truncatingRemainder(dividingBy: 3600)) / 24)
            if CurrentUser.charge_type != nil{
                
                if CurrentUser.charge_type == myAppconstantStrings.per_hr{
                    
                    let charge = Double(Int(timeCount / 3600) + 1) * Double(self.prem_Charge!)!.roundToPlaces(2)
                    
                    self.rateLbl.text = "$" + String(format:"%.2f",charge)//"$\((Double(Int(timeCount / 3600) + 1) * Double(self.prem_Charge!)!).roundToPlaces(2))"
                }
                else{
                    
                    let charge = Double(Int(timeCount / 86400) + 1) * Double(self.prem_Charge!)!.roundToPlaces(2)
                    
                    self.rateLbl.text = "$" + String(format:"%.2f",charge)
                    //self.rateLbl.text = "$\((Double(Int(timeCount / 86400) + 1) * Double(self.prem_Charge!)!).roundToPlaces(2))"
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
    
    
    func checkValetParking_status(){
        
        CommonClass.startLoader()
        
        WebserviceController.checkParkingStatus({ (success, json) in
            
            if success{
                
                let result = json["result"]
                
                let parkingDetail = CheckParkingStatusModel(result)
                
                self.locationLbl.text = parkingDetail.pa_name
                
                let date = parkingDetail.date ?? ""
                self.dateLbl.text = date.convertTimeWithTimeZone(formate: DateFormate.dateWithTime)
                
                let duration = parkingDetail.duration ?? 0
                
                let seconds = Int(duration * 3600)
                
                timeCount = TimeInterval(seconds)
                
                progressValue = Float((timeCount.truncatingRemainder(dividingBy: 3600)) / 25)
                
                userDefaults.set(parkingDetail.charge_type, forKey: NSUserDefaultsKeys.CHARGE_TYPE)
                
                self.prem_Charge = parkingDetail.charge ?? ""
                
                self.preBeaconsDetail = parkingDetail.beaconDetails
                
                self.exitTerminal = parkingDetail.exitTerminal
                
                let is_request_pickup = parkingDetail.is_request_pickup ?? false
                
                let request_for_custom_location = parkingDetail.request_for_custom_location ?? false
                
                self.setButtonsStatus(is_request_pickup, request_for_custom_location: request_for_custom_location)
                
                self.valueChange()
                
            }else{
                
                if json["code"].intValue == 225 {
                    
                    self.removeDataFromUserDefault()
                    self.valet_Timer.invalidate()
                    progressValue = 0
                    timeCount = 0.0
                    let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                    obj.tabBarTempState = TabBarTempState.search
                    self.navigationController?.pushViewController(obj, animated: true)
                    
                }
            }
        }) { (error) in
            
            self.locationLbl.text = myAppconstantStrings.not_available
            self.dateLbl.text = myAppconstantStrings.not_available
            self.valet_Timer.invalidate()
            progressValue = 0
            timeCount = 0.0
            
            
        }
        
    }
    
    fileprivate func setButtonsStatus(_ is_request_pickup: Bool , request_for_custom_location: Bool ){
        
        
        if is_request_pickup{
            
            self.pickUpBtn.backgroundColor = UIColor.gray
            //self.pickUpBtn.setTitleColor(UIColor.black, for: .normal)
            self.pickUpBtn.isEnabled = false
        }else{
            
            self.pickUpBtn.backgroundColor = UIColor.appBlue
            //self.pickUpBtn.setTitleColor(UIColor.white, for: .normal)
            self.pickUpBtn.isEnabled = true

        }
        
        if request_for_custom_location{
            
            self.bringMyCarBtn.backgroundColor = UIColor.gray
            //self.bringMyCarBtn.setTitleColor(UIColor.black, for: .normal)
            self.bringMyCarBtn.isEnabled = false

        }else{
            
            self.bringMyCarBtn.backgroundColor = UIColor.appBlue
            //self.bringMyCarBtn.setTitleColor(UIColor.white, for: .normal)
            self.bringMyCarBtn.isEnabled = true

        }
        
    }
    
//    fileprivate func getExitTerminal(_ arr:[ExitTerminalModel]){
//        
//        for res in self.preBeaconsDetail{
//            
//            for val in arr{
//                
//                if res._id == val._id{
//                    
//                    self.exitTerminal.append(res)
//                }
//            }
//        }
//    }
    
    func exitPremiumArea(){
        showAlertForBluetooth()
        self.bluetoothTimer.invalidate()
        self.bluetoothTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ValetParkingTimerVC.showAlertForBluetooth), userInfo: nil, repeats: true)
        parkingSharedInstance.disableTab = false
        self.bringmy_car()
    }
    
    
    func bringmy_car(){
        
        var param = JSONDictionary()
        
        param["terminal"] = self.bringMyCarPara["terminal"]
        param["terminal_name"] = self.bringMyCarPara["terminal_name"]
        param["request_time"] = self.bringMyCarPara["time"]
        
        self.valet_Timer.invalidate()
        
        WebserviceController.bringMyCarService(param, succesBlock: { (success, json) in
            
            if success{
                
                self.poipUpBgView.isHidden = true
                
                parkingSharedInstance.disableTab = true
                
                self.terminalPickerBgView.isHidden = true
                
                AppDelegate.showToast("Getting back your car soon.")
                
                self.locationManager.requestWhenInUseAuthorization()
                
                if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
                    
                    self.locationManager.requestWhenInUseAuthorization()
                }
                
                self.locationManager.startRangingBeacons(in: self.region)
                
                self.locationManager.delegate = self
                
            }
            
        }) { (error) in
            
        }
        
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
    
    
    
    
    fileprivate func removeDataFromUserDefault(){
        
        UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.PARKING_STAUS)
        
    }
    
    
    
    func exitParkingWebService(){
        
        let duration = timeCount / 3600
        
        var params = JSONDictionary()
        
        params["duration"] =  duration.roundToPlaces(2)
        
        params["ctoken"] = CurrentUser.c_token!
        
        WebserviceController.exitParkingService(params, succesBlock: { (success, json) in
            
            if success{
                
                let result = json["result"]
                
                progressValue = 0
                
                timeCount = 0.0
                
                self.poipUpBgView.isHidden = false
                
                parkingSharedInstance.disableTab = false
                
                self.bgViiew.isHidden = false
                
                self.msgLbl.text = myAppconstantStrings.agentApproval
                
                
                self.pre_agentDetail = HistoryModel(result)
                
                self.exitPremiumParking()
                
                self.Pre_aloeTime = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ValetParkingTimerVC.exitPremiumParking), userInfo: nil, repeats: true)
                
            }
            
        }) { (error) in
            
        }
        
    }
    
    
    func exitPremiumParking(){
        
        timeCount = timeCount + self.timeInterval
        
        if timeCount < 600{
            
            WebserviceController.exitAlloewdService({ (success, json) in
                
                if success{
                    
                    self.Pre_aloeTime.invalidate()
                    timeCount = 0.0
                    self.msgLbl.text = myAppconstantStrings.thanks
                    self.removeDataFromUserDefault()
                    CommonClass.delay(5, closure: {
                        self.poipUpBgView.isHidden = true
                        parkingSharedInstance.disableTab = true
                        let obj = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "ReceiptVC") as! ReceiptVC
                        //obj.receiptInfo = self.pre_agentDetail
                        obj.receiptState = ReceiptState.exit
                        self.navigationController?.pushViewController(obj, animated: true)
                    })
                }
                
            }, failureBlock: { (error) in
                
                
                
            })
        }
        else{
            Pre_aloeTime.invalidate()
            timeCount = 0.0
            AppDelegate.showToast(myAppconstantStrings.agentContact)
        }
        
        
    }
    
    //MARK:- CLLocation MAnager Dalegate
    //MARK:-  -------------------------------------------------------------------------------
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for res in beacons{
            
            let minor = res.minor.intValue
            
            let major = res.major.intValue
            
            if self.preBeaconsDetail.count != 0{
                
                for value in self.preBeaconsDetail{
                    
                    let ex_Minor = value.bn_minor
                    
                    let ex_Major = value.bn_major
                    
                    if minor == ex_Minor {
                        
                        if major == ex_Major{
                            
                            beaconManager.stopMonitoring(for: region)
                            
                            self.preBeaconsDetail.removeAll()
                            
                            self.exitParkingWebService()
                            
                        }
                    }
                }
            }
        }
    }
}




//MARK:- bring my car delegate
//MARK:-  =========================================


extension ValetParkingTimerVC:BringMyCarDelegate{
    
    func getBackMyCar(_ is_request_pickup: Bool, request_for_custom_location: Bool) {
        
        self.setButtonsStatus(is_request_pickup, request_for_custom_location: request_for_custom_location)
    }
    
}

//MARK:- pickeview datasource and delegate
//MARK:-  -------------------------------------------------------------------------------


extension ValetParkingTimerVC:UIPickerViewDataSource,UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.exitTerminal.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return self.exitTerminal[row].ploc_name ?? ""
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
            self.teriminal["terminal_id"] = self.exitTerminal[row]._id ?? ""
        
            self.teriminal["terminal_name"] = self.exitTerminal[row].ploc_name ?? ""
    }
}

