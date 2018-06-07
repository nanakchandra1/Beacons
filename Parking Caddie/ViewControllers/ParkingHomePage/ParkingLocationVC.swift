//
//  SearchLocationVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import CoreBluetooth


enum Parking_Area_SlotCount{
    case parkingAreas, slotCount
}

enum Zoom_in_Zoom_Out{
    case zoomin, zoomout
}

enum ParkingStatus{
    case parked,none
}


class ParkingLocationVC: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate{
    
    //MARK:- Properties
    //MARK:- ****************************************************
    
    
    var filtered = [ParkingLotDataModel]()//JSONDictionaryArray()
    let marker = GMSMarker()
    var locationManager:CLLocationManager!
    var locValue:CLLocationCoordinate2D!
    var tapGasture: UITapGestureRecognizer!
    var slotsCount = 0
    var distance = [Double]()
    var parkingLocationData = [ParkingLotDataModel]()//JSONDictionaryArray()
    let beaconManager = ESTBeaconManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: myAppconstantStrings.uuid_string)!, identifier: "Estimotes")
    var matchAreaBeacon = [BeaconDetailsModel]()
    var zoomLavel:Zoom_in_Zoom_Out = .zoomin
    var myBTManager:CBPeripheralManager!
    var parkingArea = Parking_Area_SlotCount.parkingAreas
    var parking_lot_catagory:ParkingLotCatagory = .none
    var timer = Timer()
    var parking_status:ParkingStatus = ParkingStatus.none
    var bluetoothTimer = Timer()
    var searchParkingArea = [ParkingLotDataModel]()//JSONDictionaryArray()
    var isPaused = true
    var parkingCtegory = ""
    
    
    //MARK:- OUTLETS
    //MARK:- ****************************************************
    
    @IBOutlet weak var mapTopConstrant: NSLayoutConstraint!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBarTitle: UILabel!
    @IBOutlet weak var searchBgView: UIView!
    @IBOutlet weak var searchSymbolImg: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchClearBtn: UIButton!
    @IBOutlet weak var nearByLocationTableView: UITableView!
    @IBOutlet weak var locationBgView: UIView!
    @IBOutlet weak var bgViewHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startOverAgainBtn: UIButton!
    @IBOutlet weak var startOverBtnBottomConstraint: NSLayoutConstraint!
    // pop up outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblBgView: UIView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var navigateBtn: UIButton!
    @IBOutlet weak var reachedBtn: UIButton!
    
    
    //MARK:- View LifeCycle
    //MARK:- ****************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeCount = 0.0
        progressValue = 0
        self.searchTextField.autocorrectionType = UITextAutocorrectionType.no
        self.searchTextField.returnKeyType = UIReturnKeyType.search
        self.myBTManager = CBPeripheralManager()
        self.locationManager = CLLocationManager()
        CommonClass.startLoader()
        if !CommonClass.isConnectedToNetwork{
            CommonClass.stopLoader()
        }
        setUpSubviews()
        self.showAlertForBluetooth()
        self.bluetoothTimer.invalidate()
        self.bluetoothTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ParkingLocationVC.showAlertForBluetooth), userInfo: nil, repeats: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let bt_cus_id = CurrentUser.customer_id, bt_cus_id.isEmpty{
            
            CommonFunctions.getclientToken(self)
        }

        if isUltimateValet{
            
            isUltimateValet = false
            let obj = parkingStoryboard.instantiateViewController(withIdentifier: "AgentInfoPopUpVC") as! AgentInfoPopUpVC
            obj.modalPresentationStyle = .overCurrentContext
            self.present(obj, animated: true, completion: nil)
            
        }
        
        if CurrentUser.parkingStaus != parkingState.Processing{
            
            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.PARKING_STAUS)
        }

        if self.parkingArea == .slotCount{
            self.setViewAfterParking()
            self.timer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(ParkingLocationVC.getSlotCount), userInfo: nil, repeats: true)
        }else{
            self.timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(ParkingLocationVC.getParkingLots), userInfo: nil, repeats: true)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification:Notification!) -> Void in
            self.view.addGestureRecognizer(self.tapGasture)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
                                                                queue: OperationQueue.main) {_ in
                                                                    self.view.removeGestureRecognizer(self.tapGasture)
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        bluetoothTimer.invalidate()
        
        self.timer.invalidate()
        
        self.beaconManager.stopRangingBeacons(in: self.region)
        
        self.locationManager.stopUpdatingLocation()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- IBActions
    //MARK:- ****************************************************
    
    @IBAction func onTapClearSearchText(_ sender: AnyObject) {
        
        self.searchTextField.text = ""
        
        if !self.searchParkingArea.isEmpty{
            
                if self.searchParkingArea.count >= 2{
                    
                    self.filtered = self.searchParkingArea.sorted{ item1, item2  in
                        
                        let cosdata1:Double  = item1.dist
                        
                        let cosdata2:Double  = item2.dist
                        
                        return cosdata1 < cosdata2
                        
                    }
                }
            
            if self.filtered.count >= 3{
                
                self.bgViewHightConstraint.constant = 140
                
            }
            else if self.filtered.count == 2{
                
                self.bgViewHightConstraint.constant = 70
            }
        }
        
        self.nearByLocationTableView.reloadData()
    }
    
    //start over again
    
    @IBAction func onTapStartOverAgainBtn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Alert", message: myAppconstantStrings.startOver, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: {
            alertAction in self.startOverAgain()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.zoomLavel = .zoomin
        
    }
    
    
    
    @IBAction func onTapNavigateBtn(_ sender: UIButton) {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?saddr=&daddr=\(CurrentUser.latitude!),\(CurrentUser.longitude!)&directionsmode=driving")!)
        } else {
            let url  = URL(string: myAppconstantStrings.real_Time_navigate_URL)
            if UIApplication.shared.canOpenURL(url!) == true  {
                UIApplication.shared.openURL(url!)
            }
        }
    }
        
    @IBAction func onTapReachedBtn(_ sender:UIButton) {
        self.beaconsMonitoring()
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
    
    
    //MARK:- functions
    //MARK:- ****************************************************
    
    //****************** Set Up SubViews **************************
    
    fileprivate func setUpSubviews(){
        self.bgView.layer.cornerRadius = 2
        self.bgView.isHidden = true
        locationManager.delegate = self
        self.nearByLocationTableView.delegate = self
        self.nearByLocationTableView.dataSource = self
        self.mapView.delegate = self
        self.searchTextField.delegate = self
        self.locationBgView.isHidden = true
        self.startOverAgainBtn.isHidden = true
        self.navigateBtn.isHidden = true
        self.reachedBtn.isHidden = true
        self.searchBgView.isHidden = false
        self.mapTopConstrant.constant = 40
        
        
        tapGasture = UITapGestureRecognizer(target: self, action: #selector(ParkingLocationVC.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGasture)
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        if self.parkingArea == .parkingAreas{
            getParkingLots()
        }
    }
    
    
    fileprivate func setViewAfterParking(){
        self.startOverAgainBtn.isHidden = false
        self.navigateBtn.isHidden = false
        self.reachedBtn.isHidden = false
        self.locationBgView.isHidden = true
        self.searchSymbolImg.isHidden = true
        self.searchClearBtn.isHidden = true
        self.searchTextField.isEnabled = false
        self.searchTextField.textAlignment = .center
        self.mapTopConstrant.constant = 40
        self.reachedBtn.layer.cornerRadius = 3
        self.startOverAgainBtn.layer.cornerRadius = 3
        if let adress = CurrentUser.pa_detail!["pa_address"] as? String, let loc = CurrentUser.pa_detail!["pa_location"] as? String,let pa_name = CurrentUser.pa_detail!["pa_name"] as? String {
            self.searchTextField.text = pa_name + "," + adress + "," + loc
        }
        self.getSelectedParkingArea()
        self.getSlotCount()
    }
    
    
    //********************************* Dismiss keyboard ***********************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchTextField.resignFirstResponder()
        self.bgViewHightConstraint.constant = 0
        self.mapView.superview?.endEditing(true)
    }
    
    func dismissKeyboard(_ sender: AnyObject){
        self.view.endEditing(true)
    }
    
    
    // ********************************** Get parking Lots Detals *******************************
    
    func getParkingLots(){
        
        if self.parkingArea == .parkingAreas{
            
            if let localValue = self.locValue{
                
                mapView.camera = GMSCameraPosition(target: localValue, zoom: 14, bearing: 0, viewingAngle: 0)
            }
        }
        
        WebserviceController.getParkingLots({ (success, json) in
            
            if success{
            
                print_debug(json)
                
                let result = json["result"]
                let pareas = result["pareas"].arrayValue
                
                self.parkingLocationData = pareas.map({ (p_Area) -> ParkingLotDataModel in
                    
                    ParkingLotDataModel(p_Area)
                })

                let slots = result["slot_counts"].arrayValue
                
                let slotsData = slots.map({ (slot) -> slotDataModel in
                    
                    slotDataModel(slot)
                })

                print_debug(slots)
                
                if self.isPaused{
                    
                    self.setDataForSearch()
                }
                
                self.setAnnotationOnMap(slotsData)

            }
            
        }) { (error) in
            
            
            
        }
        
    }
    
    
    
    
    fileprivate func setDataForSearch(){
        
        for (idx,res) in self.parkingLocationData.enumerated(){
            
                self.searchParkingArea.append(res)
                
                self.searchParkingArea[idx].search = res.pa_name + "," + res.pa_address + "," + res.pa_location
        }
    }
    
    
    // method for set annotation according lat long
    
    func setAnnotationOnMap(_ slots: [slotDataModel]){
        
        
        print_debug(self.parkingLocationData)
        
        for (idx,lot) in self.parkingLocationData.enumerated(){
            
            let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 49))
            var slotcount = 0

            for slot in slots{
                
                if slot._id == lot._id{
                    
                    let total = slot.total_slot_count
                    
                    let booked = slot.booked_slot_count
                    
                    print_debug(self.parkingLocationData)

                    let slots_c = total - booked
                    
                    if slots_c > 0{
                    
                        slotcount = slotcount + slots_c

                    }
                }
            }
            
            self.makeAnnotationMarker(lot, markerView: markerView, slotcount: slotcount)
            
                    if self.isPaused{
                        
                        if idx == self.parkingLocationData.count - 1{
                            
                            self.isPaused = false
                        }
                        
                        if let localValue = self.locValue{
                            
                            self.calculateDistance(CLLocation(latitude: localValue.latitude, longitude: localValue.longitude), destinationLoc: CLLocation(latitude: lot.c_lat, longitude: lot.c_long))
                        }
                    }
        }
    }    
    
    // calculate distance
    
    func calculateDistance(_ currentLoc: CLLocation, destinationLoc: CLLocation){
        
        let dist = Double(currentLoc.distance(from: destinationLoc) / 1000)
        
        self.distance.append(dist.roundToPlaces(2))
        
    }
    
    
    func makeAnnotationMarker(_ lot : ParkingLotDataModel, markerView: UIImageView, slotcount: Int){
    
        let placeLabel = UILabel()
        
        let mark = GMSMarker()
        
        markerView.image = UIImage(named: "parking_pin_location")
        
        placeLabel.frame = CGRect(x: 6, y: 10, width: 25, height: 15)
        
        mark.position = CLLocationCoordinate2DMake(lot.c_lat , lot.c_long)
        
        mark.title = lot.pa_name
        
        mark.snippet = lot.pa_location
        
        mark.map = self.mapView
        
        markerView.contentMode = UIViewContentMode.center
        
        placeLabel.text = String(slotcount)
        
        placeLabel.font = UIFont(name: "HelveticaNeue", size: 13.0)
        
        placeLabel.textAlignment = .center
        
        placeLabel.textColor = UIColor.black
        
        markerView.addSubview(placeLabel)
        
        mark.icon = self.imageWithView(markerView)

    }
    
    func getSelectedParkingArea(){
        
        
        WebserviceController.getParkingLots({ (success, json) in
            
            if success{
            
                let result = json["result"]
                
                let pareas = result["pareas"].arrayValue
                
                self.parkingLocationData = pareas.map({ (p_Area) -> ParkingLotDataModel in
                    
                    ParkingLotDataModel(p_Area)
                })

            }
            
        }) { (error) in
            
        }
    }
    
    
    //****************** Start Monitiring beacons **************************
    
    func beaconsMonitoring(){
        
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        
    }
    
    
    //****************** Get slots count in the selected parkin lot **************************
    
    func getSlotCount(){
        
        var params = JSONDictionary()
        
        var reserveCount:Int = 0
        
        var totalSlot:Int = 0
        
        if CurrentUser.p_id != nil{
            
            params["pa_id"] = CurrentUser.p_id
        }
        
        
        WebserviceController.getParkingSlots(params, succesBlock: { (success, json) in
            
            let msg = json["message"].string ?? ""
            
            if success{
            
                print_debug(json)
                
                let result = json["result"]
                
                parkingSharedInstance.selectedLotDetail = selectedLotDataModel(result)
                
                self.getAreaBeacons()
                
                let data = parkingSharedInstance.selectedLotDetail
                
                reserveCount =  data.economy + data.business + data.premium
                
                totalSlot = data.slots.count
                
                self.updateLotsCounts(totalSlot - reserveCount)
                
            }else{
            
                self.updateLotsCounts(0)
                
                AppDelegate.showToast(msg)

            }
            
        }) { (error) in
            
        }
        
    }
    
    
    
    func getAreaBeacons(){
        
        print_debug(parkingSharedInstance.beaconsDetails)
        print_debug(parkingSharedInstance.selectedLotDetail)

        
        for res in parkingSharedInstance.selectedLotDetail.areaEntryBeacons{
            
            for val in parkingSharedInstance.beaconsDetails{
                
                if res.stringValue == val._id{
                    
                    self.matchAreaBeacon.append(val)
                }
            }
        }
    }
    
    
    // ************************* Match Entry Beacons *********************************
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for res in beacons{
            
            let minor = Int(res.minor)
            let major = Int(res.major)
            
            print_debug("MINOR:   \(minor) -------- MAZOR:   \(major)----------UUID:    \(res.proximityUUID) ")
            
            if !self.matchAreaBeacon.isEmpty{
                
                for value in self.matchAreaBeacon{
                    
                    let _minor = value.bn_minor
                    let _major =  value.bn_major
                    
                    if minor == _minor {
                        
                        if major == _major{
                            
                            self.matchAreaBeacon.removeAll()
                            if self.parking_lot_catagory == ParkingLotCatagory.indoor || self.parking_lot_catagory == ParkingLotCatagory.outdoor{
                                self.parkNowWebService()
                            }
                            else{
                                
                                self.bgView.isHidden = false
                                
                                if CurrentUser.pa_detail != nil{
                                
                                    if let pa_name = CurrentUser.pa_detail!["pa_name"] as? String{
                                        
                                        let name = pa_name.uppercased()
                                        
                                        self.messageLbl.text = name + " " + myAppconstantStrings.welcome

                                    }
                                    
                                }
                                CommonClass.delay(5, closure: { () -> () in
                                    let obj = parkingStoryboard.instantiateViewController(withIdentifier: "NearbyBeaconVC") as! NearbyBeaconVC
                                    self.navigationController?.pushViewController(obj, animated: true)
                                    self.bgView.isHidden = true
                                    self.bluetoothTimer.invalidate()
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parkNowWebService(){
        
        var data = Data()
        do {
            data = try JSONSerialization.data(
                withJSONObject: parkingSharedInstance.selectedFacility ,
                options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        catch{
        }
        
        let facilities = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        
        var params = JSONDictionary()
        params["pa_id"] = CurrentUser.p_id
        params["vehicle"] = parkingSharedInstance.vehicle["car_name"] ?? ""
        params["plate_no"] = parkingSharedInstance.vehicle["plate_no"] ?? ""
        params["category"] = self.parkingCtegory

        if CurrentUser.charge != nil{
            params["charge"] = CurrentUser.charge!
        }
        if CurrentUser.charge_type != nil{
            params["charge_type"] = CurrentUser.charge_type!
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
        
        print_debug("**********************\n \(params) \n*************************")
        
        WebserviceController.parkNowService(params, succesBlock: { (success, json) in
            
            CommonClass.stopLoader()
            if success{
                
                let pa_name = CurrentUser.pa_detail!["pa_name"] as? String ?? ""
                
                self.messageLbl.text = pa_name.uppercased() + " WELCOME YOU!!"
                
                self.bgView.isHidden = false
                self.bluetoothTimer.invalidate()
                CommonClass.delay(5, closure: { () -> () in
                    if self.parking_lot_catagory == ParkingLotCatagory.indoor || self.parking_lot_catagory == ParkingLotCatagory.outdoor{
                        let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                        obj.tabBarTempState = TabBarTempState.timer
                        obj.timerScreeState = TimerScreenState.valet
                        self.navigationController?.pushViewController(obj, animated: true)
                        self.bgView.isHidden = true
                    }
                })
                
            } else {
                
                AppDelegate.showToast(json["message"].stringValue)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
        
    }
    
    
    
    //********************************* update available slots count ***********************
    
    func updateLotsCounts(_ slotCount:Int){
        let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 49))
        let placeLabel = UILabel()
        let mark = GMSMarker()
        markerView.image = UIImage(named: "parking_pin_location")
        placeLabel.frame = CGRect(x: 6, y: 10, width: 25, height: 15)
        mark.position = CLLocationCoordinate2DMake(CurrentUser.latitude!, CurrentUser.longitude!)
        mark.map = self.mapView
        markerView.contentMode = UIViewContentMode.center
        placeLabel.text = String(slotCount)
        placeLabel.font = UIFont(name: "HelveticaNeue", size: 13.0)
        placeLabel.textAlignment = .center
        placeLabel.textColor = UIColor.black
        markerView.addSubview(placeLabel)
        mark.icon = self.imageWithView(markerView)
        if let localValue = self.locValue{
            self.calculateDistance(CLLocation(latitude: localValue.latitude, longitude: localValue.longitude), destinationLoc: CLLocation(latitude: CurrentUser.latitude!, longitude: CurrentUser.longitude!))
            
            self.mapView.drowPath(fromLocation: CLLocation(latitude: localValue.latitude, longitude: localValue.longitude), toLocation: CLLocation(latitude: CurrentUser.latitude!, longitude: CurrentUser.longitude!))
        }
            
        else{
            
            if (self.locValue) != nil{
                let fancy = GMSCameraPosition.camera(withLatitude: CurrentUser.latitude!,longitude: CurrentUser.longitude!, zoom: 5, bearing: 0, viewingAngle: 0)
                self.mapView.camera = fancy
            }
        }
    }
    
    
    func setZoomBound(){
        
        let current = CLLocationCoordinate2D(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
        let destination = CLLocationCoordinate2D(latitude: CurrentUser.latitude!,longitude: CurrentUser.longitude!)
        let bounds = GMSCoordinateBounds(coordinate: current, coordinate: destination)
        let camera = self.mapView.camera(for: bounds, insets:UIEdgeInsets.zero)
        self.mapView.camera = camera!
        
    }
    
    
    // *********************************** convert View as Image *******************************
    
    func imageWithView(_ view : UIView) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 1.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let myimg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return myimg
    }
    
    
    // *********************************** Update Currebt Location ******************************
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locValue = manager.location!.coordinate
        marker.position = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        if self.zoomLavel == .zoomin{
            mapView.camera = GMSCameraPosition(target: manager.location!.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
            self.zoomLavel = .zoomout
        }
        marker.icon = UIImage(named: "parking_logo")
        marker.map = self.mapView
    }
    
    func mapView(_ mapViewUIView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.endEditing(true)
            self.bgViewHightConstraint.constant = 0
        }) 
    }
    
    // ***** ****************************** Cancel parking ******************************
    
    func startOverAgain(){
        
        CommonFunctions.gotoLandingPage()
//        self.parkingArea = .parkingAreas
//        
//        self.zoomLavel = .zoomin
//        
//        distance.removeAll()
//        
//        let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
//        
//        obj.tabBarTempState = TabBarTempState.search
//        
//        parkingSharedInstance.beaconsDetails = []
//        
//        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    
    
    // MapView Delegate
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        userDefaults.set(marker.position.latitude, forKey:NSUserDefaultsKeys.LATITUDE )
        
        userDefaults.set(marker.position.longitude, forKey:NSUserDefaultsKeys.LONGITUDE )

            var id = ""
        
            for lot in self.parkingLocationData{
                
                
                        if CurrentUser.latitude! == lot.c_lat && lot.c_long == CurrentUser.longitude{
                            
                            id = lot._id
                            
                            var detail = [String:String]()
                            
                            detail["pa_location"] = lot.pa_location
                            detail["pa_address"] = lot.pa_address
                            detail["pa_name"] = lot.pa_name
                            
                            userDefaults.set(detail, forKey: NSUserDefaultsKeys.PADETAIL)
                            
                        }
            }
        if let localValue = self.locValue{
            
            self.mapView.drawRoute(fromLocation: CLLocation(latitude: localValue.latitude, longitude: localValue.longitude), toLocation: CLLocation(latitude: CurrentUser.latitude!, longitude: CurrentUser.longitude!))
        }
        
        let obj = parkingStoryboard.instantiateViewController(withIdentifier: "ParkingLotDetailVC") as! ParkingLotDetailVC
        
        obj.id = id
        
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
}


//MARK:- TextField Delegate
//MARK:- ****************************************************

extension ParkingLocationVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.searchTextField.text = ""
        
        if !self.searchParkingArea.isEmpty{
            
            if self.distance.count == 0{
                
                for area in self.searchParkingArea{
                    
                            if let localValue = self.locValue{
                                
                                self.calculateDistance(CLLocation(latitude: localValue.latitude, longitude: localValue.longitude), destinationLoc: CLLocation(latitude: area.c_lat, longitude: area.c_long))
                                
                            }
                }
            }
            
            if !self.distance.isEmpty{
                
                for (index,_) in self.searchParkingArea.enumerated(){
                    
                    self.searchParkingArea[index].dist = self.distance[index]
                }
            }
            
            if distance.count >= 2{
                
                filtered = self.searchParkingArea.sorted{ item1, item2  in
                    
                    let cosdata1  = item1.dist
                    
                    let cosdata2  = item2.dist
                    
                    return cosdata1 < cosdata2
                    
                }
                
                self.locationBgView.isHidden = false
                
                self.nearByLocationTableView.reloadData()
                
                if self.filtered.count >= 3{
                    
                    self.bgViewHightConstraint.constant = 140
                    
                }
                    
                else if self.filtered.count == 2{
                    
                    self.bgViewHightConstraint.constant = 70
                }
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        CommonClass.delay(0.1) { () -> () in
            
            if self.distance.count > 0{
                
                if self.searchTextField.text!.characters.count == 0{
                    
                    if self.distance.count >= 2{
                        
                        self.filtered = self.searchParkingArea.sorted{ item1, item2  in
                            
                            let cosdata1  = item1.dist
                            
                            let cosdata2  = item2.dist
                            
                            return cosdata1 < cosdata2
                            
                        }
                        
                        self.locationBgView.isHidden = false
                        
                        self.nearByLocationTableView.reloadData()
                        
                        if self.filtered.count >= 3{
                            
                            self.bgViewHightConstraint.constant = 140
                            
                        }
                            
                        else if self.filtered.count == 2{
                            
                            self.bgViewHightConstraint.constant = 70
                            
                        }
                    }
                    
                    self.nearByLocationTableView.reloadData()
                }
                else{
                    
                    self.filtered.removeAll()
                    
                    self.filtered = self.searchParkingArea.filter({ $0.search.localizedCaseInsensitiveContains(textField.text!.lowercased()) })
                    
                    if self.filtered.count >= 3{
                        
                        self.bgViewHightConstraint.constant = 105
                        
                    }else if self.filtered.count == 2{
                        
                        self.bgViewHightConstraint.constant = 70
                        
                    }else if self.filtered.count == 1{
                        
                        self.bgViewHightConstraint.constant = 35
                        
                    }else if self.filtered.count == 0{
                        
                        self.bgViewHightConstraint.constant = 35
                    }
                }
                
                if self.filtered.count > 2{
                    
                    if self.distance.count > 0{
                        
                        if textField.text!.characters.count == 0 {
                            
                            self.filtered = self.searchParkingArea.sorted{ item1, item2  in
                                
                                let cosdata1  = item1.dist
                                
                                let cosdata2  = item2.dist
                                
                                return cosdata1 < cosdata2
                                
                            }
                        }
                    }
                }
                
                self.nearByLocationTableView.reloadData()
                
            }
        }
        return true
    }
}


//MARK:- TableView Delegate And DAtasource
//MARK:- ****************************************************

extension ParkingLocationVC:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filtered.isEmpty{
            return 1
        }
        else if self.searchTextField.text!.characters.count == 0 && self.filtered.count >= 3{
            return 4
        }
        else if self.filtered.count == 3{
            return 3
        }
        else{
            return self.filtered.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearByLocationCell", for: indexPath) as! NearByLocationCell
        
        if self.searchTextField.text!.characters.count == 0{
            
            switch indexPath.row{
                
            case 0:
                
                cell.distanceLbl.isHidden = true
                
                cell.locationNameLbl.text = myAppconstantStrings.nearBy
                
                cell.locationNameLbl.textColor = UIColor.appBlue
                
            case 1,2,3:
                
                cell.distanceLbl.isHidden = false
                
                cell.locationNameLbl.textColor = UIColor.black
                
                if  self.filtered.count > 0  {
                    
                    cell.locationNameLbl.text = self.filtered[indexPath.row - 1].search
                    
                    cell.distanceLbl.text = "\(self.filtered[indexPath.row - 1].dist)" + " km"
                }
            default:
                fatalError("ParkingLocationVC in cell for row table view delegate")
            }
        }
        else if self.filtered.isEmpty{
            
            cell.distanceLbl.isHidden = true
            
            cell.locationNameLbl.text = myAppconstantStrings.noResult
            
            cell.locationNameLbl.textColor = UIColor.appBlue
            
        }
        else{
            
            cell.distanceLbl.isHidden = false
            
            cell.locationNameLbl.textColor = UIColor.black
            
            cell.locationNameLbl.text = self.filtered[indexPath.row].search
            
            cell.distanceLbl.text = String(describing: self.filtered[indexPath.row].dist) + " km"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 35
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.bgViewHightConstraint.constant = 0
        
        if self.searchTextField.text!.characters.count == 0{
            
            let area = self.filtered[indexPath.row - 1]
            
            self.mapView.animate(toLocation: CLLocationCoordinate2DMake(area.c_lat, area.c_long))
                    
            self.searchTextField.text = area.search
                        
        }
        else{
            
            let area = self.filtered[indexPath.row]
            
            self.searchTextField.text = area.search
            
            self.mapView.animate(toLocation: CLLocationCoordinate2DMake(area.c_lat, area.c_long))
        }
    }
}




//MARK:- TableView Cell Classess
//MARK:- ****************************************************

class NearByLocationCell: UITableViewCell{
    
    //MARK:- TableView Cell Class OUTLETS
    //MARK:- ****************************************************
    
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

