//
//  ParkingLotDetailVC.swift
//  Parking Caddie
//
//  Created by Anuj on 4/19/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}



enum ApplyButtonState {
    case apply,cancel
}


class ParkingLotDetailVC: UIViewController {
    
    var id = ""
    var parkingDetails = SelectedParkingLotDetailModel([:])
    var imgURL:String!
    var facilityImgUrl:String!
    var selectedIndexPath = [IndexPath]()
    var plateNumber = [String]()
    var carName = [String]()
    var vehicleSelectedIndexPath =  IndexPath()
    var index:Int!
    var facilities = JSONDictionaryArray()
    var selectedFacilities = [Int]()
    var couponCode = [String:String]()
    var applyButtonState:ApplyButtonState = .apply
    var parking_status:Parking_Area_SlotCount!
    var parking_Catagory:ParkingLotCatagory = .economy
    var tapGasture: UITapGestureRecognizer!
   // var catagoryList = JSONArray()
    var chargeType = ""
    var category = ""
    var noOfSection = 0
    
    //MARK:- OUTLETS
    //MARK:- ************************************************
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navigationBAr: UIView!
    @IBOutlet weak var navigationBarItem: UILabel!
    @IBOutlet weak var parkingLotTableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    
    //MARK:- View life Cycle
    //MARK:- ************************************************
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        CommonClass.startLoader()
        if CurrentUser.couponCode != nil{
            self.applyButtonState = ApplyButtonState.cancel
        }
        else{
            self.applyButtonState = ApplyButtonState.apply
        }
        self.parkingLotTableView.delegate = self
        self.parkingLotTableView.dataSource = self
        self.parkingLotTableView.separatorStyle = .none
        self.parkingLotTableView.register(UINib(nibName: "CoupancodeCell", bundle: nil), forCellReuseIdentifier: "CoupancodeCell")
        self.parkingLotTableView.register(UINib(nibName: "VehicleimageCell", bundle: nil), forCellReuseIdentifier: "VehicleimageCell")
        self.parkingLotTableView.register(UINib(nibName: "ParkinLotnameCell", bundle: nil), forCellReuseIdentifier: "ParkinLotnameCell")
        self.parkingLotTableView.register(UINib(nibName: "ApplyCouponCell", bundle: nil), forCellReuseIdentifier: "ApplyCouponCell")
        tapGasture = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard(_:)))
        
        self.getLocationDetail()
        self.selectedIndexPath.removeAll()
        self.selectedFacilities.removeAll()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getVehicleName()
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
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Functions
    //MARK:- *****************************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Dismiss KeyBord
    
    func dismissKeyboard(_ sender: AnyObject){
        
        self.view.endEditing(true)
        
    }
    
    
    
    func getLocationDetail(){
        
        let url = parkingLovationURL + self.id
        
        WebserviceController.parkingLotDetailService(url, succesBlock: { (success, json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].dictionaryValue
                
                self.parkingDetails = SelectedParkingLotDetailModel(json["result"])
                
                let charge_type = self.parkingDetails.pa_charge_type
                
                userDefaults.set(charge_type, forKey: NSUserDefaultsKeys.CHARGE_TYPE)
                
                if charge_type == myAppconstantStrings.per_hr{
                    
                    self.chargeType = "hr"
                    
                }else{
                    
                    self.chargeType = "day"
                    
                }
                
                
                print_debug(self.parkingDetails)
                
                //self.catagoryList = result["pa_charge_grid"]!.arrayValue
                
                if !self.parkingDetails.pa_charge_grid.isEmpty{
                    
                    let catagory = self.parkingDetails.pa_charge_grid.first
                    let cat = catagory?.category
                    let charge = catagory?.charge
                    userDefaults.set(charge, forKey: NSUserDefaultsKeys.CHARGE)

                    switch cat!{
                        
                    case "Economy":
                        
                        self.parking_Catagory = .economy
                        self.category = "economy"
                        
                    case "Business":
                        
                        self.parking_Catagory = .business
                        self.category = "business"
                        
                    case "Premium Indoor":
                        
                        self.parking_Catagory = .indoor
                        self.category = "premium"
                        
                    case "Premium Outdoor":
                        
                        self.parking_Catagory = .outdoor
                        self.category = "outdoor"
                        
                    case "Ultimate Valet":
                        
                        self.parking_Catagory = .ultimate
                        self.category = "ultimatevalet"
                        
                    default:
                        
                        self.parking_Catagory = .none
                        
                    }
                }
                
                self.facilities = result["facilities"]?.arrayObject as! JSONDictionaryArray
                
                userDefaults.set(self.parkingDetails._id, forKey:NSUserDefaultsKeys.PID)
                
                parkingSharedInstance.beaconsDetails = self.parkingDetails.beaconDetails
                
                
                self.imgURL =  parkingImageUrl + result["pa_image"]!.stringValue
                
                self.noOfSection = 8
                self.parkingLotTableView.reloadData()
                
            } else {
                
                AppDelegate.showToast(json["message"].stringValue)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
    }
    
    
    
    // fetch vehicle detail from database
    
    func getVehicleName(){
        
        self.carName = []
        
        self.plateNumber = []
        
        if CurrentUser.vehicles?.count > 0{
            
            for key in (CurrentUser.vehicles?.keys)!{
                
                self.carName.append(key )
                
            }
            
            for key in (CurrentUser.vehicles?.values)!{
                
                self.plateNumber.append(key as! String)
                
            }
        }
    }
    
    
    
    //MARK:- Button Actions
    //MARK:- *****************************************************************
    
    func onTapAddBtn(_ sender:UIButton){
        
        let cell = self.parkingLotTableView.cellForRow(at: IndexPath(row: 0, section: 5)) as! AditionalFAcilitiesCell
        
        let indexPath = sender.collectionViewIndexPath(cell.aditionalCollectionView)
        
        if self.selectedIndexPath.contains(indexPath!){
            
            self.selectedIndexPath = self.selectedIndexPath.filter({ $0 != indexPath })
            
        }
        else{
            
            self.selectedIndexPath.append(indexPath!)
        }
        
        if self.selectedFacilities.contains((indexPath?.row)!){
            self.selectedFacilities = self.selectedFacilities.filter({$0 != indexPath?.row})
        }
        else{
            self.selectedFacilities.append((indexPath?.row)!)
        }
        
        cell.aditionalCollectionView.reloadItems(at: [IndexPath(row: (indexPath?.row)!, section: 0)])
    }
    
    
    
    // back button
    
    @IBAction func onTapBackBtn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //reservr button
    
    func onTapReserveBtn(_ sender: UIButton){
        
        getFacilities()
        
        if let _ = CurrentUser.vehicles{
            
            let obj = parkingStoryboard.instantiateViewController(withIdentifier: "ReserveLotVC") as! ReserveLotVC
            
            obj.parkingLotData = self.parkingDetails
            obj.indexes = self.selectedFacilities
            obj.parking_catagory = self.parking_Catagory
            obj.chargeType = self.chargeType
            obj.facilities = self.facilities
            self.navigationController?.pushViewController(obj, animated: true)
            
        }
        else{
            self.alertShow()
        }
    }
    
    
    //park now button
    
    func onTapParkBtn(_ sender: UIButton){
        
        self.getFacilities()
        if self.parking_Catagory == ParkingLotCatagory.ultimate{
            
            let obj = parkingStoryboard.instantiateViewController(withIdentifier: "UltimateValetVC") as! UltimateValetVC
            
            obj.parkingLotData = self.parkingDetails
            obj.indexes = self.selectedFacilities
            obj.parking_catagory = self.parking_Catagory
            obj.facilities = self.facilities
            self.navigationController?.pushViewController(obj, animated: true)
            
        }else{
            
            if !CurrentUser.vehicles!.isEmpty{
                
                let obj = parkingStoryboard.instantiateViewController(withIdentifier: "SelectVehicleVC") as! SelectVehicleVC
                obj.delegate = self
                obj.carName = self.carName
                obj.modalPresentationStyle = .overCurrentContext
                self.present(obj, animated: true, completion: nil)
                
            }
            else{
                
                alertShow()
                
            }
        }
    }
    
    
    
    @IBAction func onTapSelectVehicleBtn(_ sender: UIButton) {
        
        if let idx = self.index{
            
            parkingSharedInstance.vehicle["car_name"] = self.carName[idx]
            
            parkingSharedInstance.vehicle["plate_no"] = self.plateNumber[idx]
            
            self.parking_status = Parking_Area_SlotCount.slotCount
            
        }else{
            
            AppDelegate.showToast(myAppconstantStrings.selectVehicle)
        }
        
    }
    
    
    func alertShow(){
        
        let alert = UIAlertController(title: "Alert", message: myAppconstantStrings.addvehicle, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ADD", style: UIAlertActionStyle.cancel, handler: {
            alertAction in self.addVehicle()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func addVehicle(){
        
        let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        obj.profileState = ProfileState.selectVehicle
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    
    func getFacilities(){
        
        parkingSharedInstance.selectedFacility.removeAll()
        
        
        if !self.facilities.isEmpty{
            
            var facilit = JSONDictionaryArray()
            
            for var value in self.facilities{
                
                value.removeValue(forKey: "fl_image")
                
                facilit.append(value)
                
            }
            
            for res in self.selectedFacilities{
                
                parkingSharedInstance.selectedFacility.append(facilit[res])
            }
        }
    }
    
    
    
    func ontapApplyCode(_ sender:UIButton){
        
        var params = JSONDictionary()
        
        if self.applyButtonState == ApplyButtonState.cancel{
            
            self.couponCode["couponCode"] = ""
            
            self.applyButtonState = ApplyButtonState.apply
            
            self.parkingLotTableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: UITableViewRowAnimation.none)
            
        }else{
            
            if couponCode["couponCode"]?.characters.count < 1{
                
                AppDelegate.showToast(myAppconstantStrings.emptyCoupon)
                
            }else{
                
                CommonClass.startLoader()
                
                params["coupon"] = self.couponCode["couponCode"]
                
                params["pa_id"] = self.id
                
                WebserviceController.verifyCoupon(params, succesBlock: { (success, json) in
                    
                    CommonClass.stopLoader()
                    
                    if success{
                        
                        let result = json["result"].dictionary ?? [:]
                        
                        userDefaults.set(result["_id"]?.string ?? "", forKey: NSUserDefaultsKeys.TEMPCOUPON_ID)
                        
                        self.applyButtonState = ApplyButtonState.cancel
                        
                        self.parkingLotTableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: UITableViewRowAnimation.none)
                        
                        
                    } else {
                        
                        AppDelegate.showToast(json["message"].stringValue)
                        
                    }
                    
                }, failureBlock: { (error) in
                    
                    CommonClass.stopLoader()
                    
                })
            }
            
            
        }
        
    }
    
}

//MARK:- Select vehicle delegate
//MARK:- ************************************************

extension ParkingLotDetailVC: SetSelectedVehicleDelegate{
    
    func setSelectedVehicle(_ selectedIndex: IndexPath) {
        
        self.index = selectedIndex.item
        parkingSharedInstance.vehicle["car_name"] = self.carName[selectedIndex.row]
        parkingSharedInstance.vehicle["plate_no"] = self.plateNumber[selectedIndex.row]
    }
    
    func pushView(){
        
        let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "ParkingLocationVC") as! ParkingLocationVC
        obj.parkingArea = .slotCount
        obj.parking_lot_catagory = self.parking_Catagory
        obj.parkingCtegory = self.category
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
}

//MARK:- Table View Delegate And Datasource
//MARK:- ************************************************

extension ParkingLotDetailVC: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.noOfSection
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 4{
            
            return self.parkingDetails.pa_charge_grid.count
            
        }else{
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return setTableViewData(indexPath, tableView: tableView)
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
            
        case 0:
            return UIScreen.main.bounds.height / 4
        case 1,2,3:
            return 60
        case 4:
            if indexPath.row == 0{
                return 76
            }else{
                return 36
                
            }
        case 5:
            return 210
        case 6:
            return 138
            
        default:
            return 70
        }
    }
    
    
    
    fileprivate func setTableViewData(_ indexPath:IndexPath,tableView:UITableView) -> UITableViewCell{
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleimageCell", for: indexPath) as! VehicleimageCell
            if let _ = self.imgURL{
                
                let imageUrl = URL(string: self.imgURL)
                
                cell.vehicleImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "parking_graphic"))
                
            }
            else{
                cell.vehicleImage?.image = UIImage(named: "parking_graphic")
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkinLotnameCell", for: indexPath) as! ParkinLotnameCell
            
            cell.bgView.roundCorners([.topLeft,.topRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 60))
            
            cell.parkinLotNameLbl.text = self.parkingDetails.pa_name
            
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoupancodeCell", for: indexPath) as! CoupancodeCell
            
            cell.iconImage.image = UIImage(named: "location")
            
            cell.parkinLocationLbl.text = "Location"
            
            cell.LocationNameLbl.text = self.parkingDetails.pa_address + ", " + self.parkingDetails.pa_location
            
            
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoupancodeCell", for: indexPath) as! CoupancodeCell
            
            cell.iconImage.image = UIImage(named: "duration")
            
            cell.parkinLocationLbl.text = "Time"
            
            let open = self.parkingDetails.pa_open_time
            
            let closed = self.parkingDetails.pa_close_time
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "HH:mm"
            
            let date = dateFormatter.date(from: closed!)
            
            dateFormatter.dateFormat = "hh:mm"
            
            if let _ = date{
                
                let strTime = dateFormatter.string(from: date!)
                
                if !open!.isEmpty{
                    
                    cell.LocationNameLbl.text = open! + " am TO " + strTime + " pm"
                }
                else{
                    cell.LocationNameLbl.text = myAppconstantStrings.parkingTime
                }
            }
            else{
                cell.LocationNameLbl.text = myAppconstantStrings.parkingTime
            }
            return cell
            
        case 4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath) as! DurationCell
            
            let data = self.parkingDetails.pa_charge_grid[indexPath.row]
            
            let cat = data.category ?? ""
            
            let charge = data.charge ?? ""
            
            cell.symbolImage.image = UIImage(named: "amount")
            
            cell.durationLbl.text = "Amount"
            
            let str1 = cat + "  :  "
            let str2 = str1 + "$" + charge
            let str3 = str2 + " / " + self.chargeType

            cell.categorylbl.text = str3
            
            if indexPath.row == 0{
                
                cell.categoryViewHeight.constant = 40
                cell.symbolImage.isHidden = false
                cell.durationLbl.isHidden = false
                
            }else{
                
                cell.categoryViewHeight.constant = 0
                cell.symbolImage.isHidden = true
                cell.durationLbl.isHidden = true
                
            }
            
            switch self.parking_Catagory {
                
            case .economy:
                
                if cat == "Economy"{
                    
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio_tick"), for: UIControlState())
                    
                }else{
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio"), for: UIControlState())
                    
                }
            case .business:
                
                if cat == "Business"{
                    
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio_tick"), for: UIControlState())
                    
                }else{
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio"), for: UIControlState())
                    
                }
            case .indoor:
                
                if cat == "Premium Indoor"{
                    
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio_tick"), for: UIControlState())
                    
                }else{
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio"), for: UIControlState())
                    
                }
            case .outdoor:
                
                if cat == "Premium Outdoor"{
                    
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio_tick"), for: UIControlState())
                    
                }else{
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio"), for: UIControlState())
                    
                }
                
            case .ultimate:
                
                if cat == "Ultimate Valet"{
                    
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio_tick"), for: UIControlState())
                    
                }else{
                    cell.categoryRadiobtn.setImage(UIImage(named: "radio"), for: UIControlState())
                    
                }
                
            default:
                
                cell.categoryRadiobtn.setImage(UIImage(named: "radio"), for: UIControlState())
                
            }
            return cell
            
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AditionalFAcilitiesCell", for: indexPath) as! AditionalFAcilitiesCell
            
            cell.aditionalCollectionView.delegate = self
            cell.aditionalCollectionView.dataSource = self
            cell.bgView.layer.cornerRadius = 3
            cell.aditionalCollectionView.reloadData()
            return cell
            
        case 6:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyCouponCell", for: indexPath) as! ApplyCouponCell
            cell.applyCodeBtn.addTarget(self, action: #selector(ParkingLotDetailVC.ontapApplyCode(_:)), for: UIControlEvents.touchUpInside)
            cell.promocodeTextField.delegate = self
            if self.applyButtonState == ApplyButtonState.cancel{
                cell.promocodeTextField.isEnabled = false
                cell.promocodeTextField.text = CurrentUser.couponCode//self.couponCode["couponCode"]
                cell.applyCodeBtn.setTitle("CHANGE", for: UIControlState())
            }
            else{
                cell.promocodeTextField.text = self.couponCode["couponCode"]
                cell.promocodeTextField.isEnabled = true
                cell.applyCodeBtn.setTitle("APPLY", for: UIControlState())
            }
            return cell
            
        case 7:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReserveButtonCell", for: indexPath) as! ReserveButtonCell
            cell.buttonsBgView.layer.borderWidth = 1
            cell.buttonsBgView.layer.borderColor = UIColor.gray.cgColor
            cell.buttonsBgView.layer.cornerRadius = 2
            cell.reserveBtn.addTarget(self, action: #selector(ParkingLotDetailVC.onTapReserveBtn(_:)), for: UIControlEvents.touchUpInside)
            cell.parkNowBtn.addTarget(self, action: #selector(ParkingLotDetailVC.onTapParkBtn(_:)), for: UIControlEvents.touchUpInside)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReserveButtonCell", for: indexPath) as! ReserveButtonCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 4 else{return}
        
        let data = self.parkingDetails.pa_charge_grid[indexPath.row]
        
        let cat = data.category ?? ""
        
        let charge = data.charge
    
        userDefaults.set(charge, forKey: NSUserDefaultsKeys.CHARGE)
        
        
        switch cat{
            
        case "Economy":
            self.parking_Catagory = .economy
            self.category = "economy"
        case "Business":
            self.parking_Catagory = .business
            self.category = "business"
            
        case "Premium Indoor":
            self.parking_Catagory = .indoor
            self.category = "premium"
            
        case "Premium Outdoor":
            self.parking_Catagory = .outdoor
            self.category = "outdoor"
            
        case "Ultimate Valet":
            self.parking_Catagory = .ultimate
            self.category = "ultimatevalet"
            
        default:
            self.parking_Catagory = .none
            
            
        }
        self.parkingLotTableView.reloadSections([4], with: .none)
    }
}




//MARK:- Collection View Delegate And Datasource
//MARK:- ************************************************

extension ParkingLotDetailVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.facilities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AditionalFAcilityCollectionViewCell", for: indexPath)  as! AditionalFAcilityCollectionViewCell
        cell.facilityAddBtn.layer.borderWidth = 1
        cell.facilityAddBtn.layer.borderColor = UIColor.appBlue.cgColor
        cell.facilityAddBtn.layer.cornerRadius = 3
        cell.facilityAddBtn.addTarget(self, action: #selector(ParkingLotDetailVC.onTapAddBtn(_:)), for: UIControlEvents.touchUpInside)
        
        let data = self.parkingDetails.facilities[indexPath.item]
        
        let imageUrl = URL(string: data.fl_image)
        
        cell.facilityImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "profile_active"))
        cell.facilityImage.contentMode = .center
        
        cell.facilityNameLbl.text = data.fl_name
        
        cell.facilityChargeLbl.text = "$" + data.fl_price
        
        if self.selectedIndexPath.contains(indexPath){
            
            cell.facilityAddBtn.backgroundColor = UIColor.appBlue
            cell.facilityAddBtn.setTitle("ADDED", for: UIControlState())
            cell.facilityAddBtn.setTitleColor(UIColor.white, for: UIControlState())
        }
        else{
            
            cell.facilityAddBtn.backgroundColor = UIColor.clear
            cell.facilityAddBtn.setTitle("ADD", for: UIControlState())
            
            cell.facilityAddBtn.setTitleColor(UIColor.appBlue, for: UIControlState())
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (UIScreen.main.bounds.width / 4), height: 150 )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

extension ParkingLotDetailVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cell = textField.tableViewCell() as! ApplyCouponCell
        CommonClass.delay(0.1) {
            self.couponCode["couponCode"] = cell.promocodeTextField.text!
        }
        return true
    }
    
}


//MARK:- TableView Cell Classess
//MARK:- ************************************************

class AditionalFAcilitiesCell: UITableViewCell{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var aditionalCollectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

class ReserveButtonCell: UITableViewCell{
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var buttonsBgView: UIView!
    @IBOutlet weak var reserveBtn: UIButton!
    @IBOutlet weak var parkNowBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}


class AmountCell:UITableViewCell{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var symbolImg: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var rate1_Lbl: UILabel!
    @IBOutlet weak var rate2_lbl: UILabel!
    @IBOutlet weak var rate3_Lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


//MARK:- CollectionView Cell Classess
//MARK:- ************************************************

class AditionalFAcilityCollectionViewCell: UICollectionViewCell{
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var facilityImage: UIImageView!
    @IBOutlet weak var facilityNameLbl: UILabel!
    @IBOutlet weak var facilityChargeLbl: UILabel!
    @IBOutlet weak var facilityAddBtn: UIButton!
}

//MARK:- Collection view cell classess
//MARK:- ********************************************************

class SelectVehicle: UICollectionViewCell{
    
    @IBOutlet weak var preView: UIView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var sliderImgeView: UIImageView!
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
}
