//
//  ReserveLotVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 03/03/16.
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


enum SelectPickerView{
    case date, time , none
}

enum DateSelect {
    
    case arrival_date,return_date,arrival_time,return_time,none
}


class ReserveLotVC: UIViewController {
    
    //MARK:- Properties
    //MARK:-  -------------------------------------------------------------------------------
    
    var selectedIndexPath =  IndexPath()
    var parkingLotData = SelectedParkingLotDetailModel([:])
    var indexes = [Int]()
    var facilityName = [String]()
    var facilitycost = [String]()
    var facilities = JSONDictionaryArray()
    var imgURL:String!
    var carName = [String]()
    var plateNo = [String]()
    var index : Int!
    var parking_catagory:ParkingLotCatagory = .economy
    var pickerSelect:SelectPickerView = .none
    var selectDate:DateSelect = .none
    var selectedDateDict = [String:String]()
    var arrivalTime = ""
    var totalTime = 0
    var catagoryList = JSONArray()
    var chargeType = ""
    var category = ""
    
    
    
    //MARK:- IBOutlets
    //MARK:-  ====================================
    
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var reservLotTableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    
    // date picker outlets
    
    @IBOutlet weak var datePickerBgView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerBgBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var setDateBtn: UIButton!
    
    // picker view outlets
    
    @IBOutlet weak var pickerBgView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerBgViewBottomConstraint: NSLayoutConstraint!
    
    
    //MARK:- View life cycle
    //MARK:-  -------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getVehicleName()
        getFacilities()
        self.reservLotTableView.dataSource = self
        self.reservLotTableView.delegate = self
        //        self.selectVehicleCollectionView.dataSource = self
        //        self.selectVehicleCollectionView.delegate = self
        self.reservLotTableView.separatorStyle = .none
        self.datePickerBgBottomConstraint.constant = -170
        self.pickerBgViewBottomConstraint.constant = -180
        self.reservLotTableView.register(UINib(nibName: "CoupancodeCell", bundle: nil), forCellReuseIdentifier: "CoupancodeCell")
        self.reservLotTableView.register(UINib(nibName: "VehicleimageCell", bundle: nil), forCellReuseIdentifier: "VehicleimageCell")
        self.reservLotTableView.register(UINib(nibName: "ParkinLotnameCell", bundle: nil), forCellReuseIdentifier: "ParkinLotnameCell")
        self.reservLotTableView.register(UINib(nibName: "SelectedFacilityCell", bundle: nil), forCellReuseIdentifier: "SelectedFacilityCell")
        
        if let url = self.parkingLotData.pa_image{
            
            self.imgURL = parkingImageUrl + url
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK:- IBAction
    //MARK:-  -------------------------------------------------------------------------------
    
    
    @IBAction func onTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onTapDoneBtn(_ sender: UIButton) {
        self.getDateAndTime()
        
        UIView.animate(withDuration: 5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
            self.datePickerBgBottomConstraint.constant = -170
        })
    }
    
    
    @IBAction func onTapDatePicker(_ sender: AnyObject) {
        self.getDateAndTime()
    }
    
    
    
    
    func onTapConfirmBtn(_ sender:UIButton){
        
        if self.parking_catagory == .ultimate{
            
            let obj = parkingStoryboard.instantiateViewController(withIdentifier: "UltimateValetVC") as! UltimateValetVC
            
            obj.parkingLotData = self.parkingLotData
            obj.indexes = self.indexes
            obj.parking_catagory = self.parking_catagory
            self.navigationController?.pushViewController(obj, animated: true)
            
            return
        }
        
        self.confirmReserveVehicle()
    }
    
    
    
    
    func onTapCancelBtn(_ sender:UIButton){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func onTapAddBtn(){
        
        let obj = parkingStoryboard.instantiateViewController(withIdentifier: "SelectVehicleVC") as! SelectVehicleVC
        obj.carName = self.carName
        obj.delegate = self
        obj.modalPresentationStyle = .overCurrentContext
        self.present(obj, animated: true, completion: nil)
        
    }
    
    
    func openDatePicker(_ indexpath:IndexPath){
        
        if indexpath.section == 4{
            if let _ = self.selectedDateDict["arrival_time"]{
                self.selectedDateDict.removeAll()
            }else{
                self.selectDate = .arrival_date
                self.showHideDatePickerView(.date, pickerMode: SelectPickerView.date)
            }
        }
        else if indexpath.section == 6{
            if let _  = self.selectedDateDict["return_time"]{
                self.selectedDateDict.removeValue(forKey: "return_time")
                self.selectDate = .return_date
                self.showHideDatePickerView(.date, pickerMode: SelectPickerView.date)
                self.reservLotTableView.reloadData()
            }
            if let _ = self.selectedDateDict["arrival_date"],let _ = self.selectedDateDict["arrival_time"]{
                self.selectDate = .return_date
                self.showHideDatePickerView(.date, pickerMode: SelectPickerView.date)
            }
        }
    }
    
    func showHideDatePickerView(_ mode:UIDatePickerMode,pickerMode:SelectPickerView){
        
        self.pickerBgView.isHidden = true
        self.datePickerBgView.isHidden = false
        self.datePicker.datePickerMode = mode
        self.pickerSelect = pickerMode
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
            self.datePickerBgBottomConstraint.constant = 0
        })
    }
    
    
    
    func openTimePicker(_ indexpath:IndexPath){
        
        if indexpath.section == 5{
            if let _ = self.selectedDateDict["arrival_date"]{
                if let _ = self.selectedDateDict["arrival_time"],let _ = self.selectedDateDict["return_date"]{
                    self.selectedDateDict.removeValue(forKey: "return_date")
                    self.selectedDateDict.removeValue(forKey: "return_time")
                    self.selectDate = .arrival_time
                    self.datePicker.minimumDate = Date()
                    self.showHideDatePickerView(.time, pickerMode: SelectPickerView.time)
                    self.reservLotTableView.reloadData()
                }
                else{
                    self.selectDate = .arrival_time
                    self.showHideDatePickerView(.time, pickerMode: SelectPickerView.time)
                }
            }
        }
        else if indexpath.section == 7{
            
            if let _ = self.selectedDateDict["return_date"]{
                self.selectDate = .return_time
                if let _ = self.selectedDateDict["arrival_send_date"],let _ = self.selectedDateDict["arrival_time"]{
                    let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    var components: DateComponents = DateComponents()
                    
                    components.hour = 1
                    
                    let minDate: Date = (gregorian as NSCalendar).date(byAdding: components, to: getDurationFromCurrentDate(), options: NSCalendar.Options(rawValue: 0))!
                    self.datePicker.minimumDate = minDate
                }
                
                self.showHideDatePickerView(.time, pickerMode: SelectPickerView.time)
            }
        }
    }
    
    
    
    func openPickerView(_ sender: UIButton){
        self.pickerBgView.isHidden = false
        self.datePickerBgView.isHidden = true
        self.pickerBgViewBottomConstraint.constant = 0
    }
    
    
    
    //    func onTapEconomyBtn(_ sender:UIButton){
    //        self.parking_catagory = ParkingLotCatagory.economy
    //        let pa_charge = self.parkingLotData["pa_charge"] as? JSONDictionary ?? [:]
    //
    //        if let premium = pa_charge["premium"] as? String{
    //            self.setChargeType(premium)
    //        }
    //
    //        self.reservLotTableView.reloadData()
    //
    //    }
    
    //    func onTapBuninessBtn(_ sender:UIButton){
    //        self.parking_catagory = ParkingLotCatagory.business
    //        let pa_charge = self.parkingLotData["pa_charge"] as? JSONDictionary ?? [:]
    //
    //        if let premium = pa_charge["premium"] as? String{
    //            self.setChargeType(premium)
    //        }
    //
    //        self.reservLotTableView.reloadData()
    //    }
    
    //    func onTapPremiumBtn(_ sender: UIButton){
    //        self.parking_catagory = ParkingLotCatagory.premium
    //        let pa_charge = self.parkingLotData["pa_charge"] as? JSONDictionary ?? [:]
    //
    //        if let premium = pa_charge["premium"] as? String{
    //            self.setChargeType(premium)
    //        }
    //
    //        self.reservLotTableView.reloadData()
    //
    //
    //    }
    
    
    //    func onTapUltimatevaletBtn(_ sender: UIButton){
    //
    //        self.parking_catagory = ParkingLotCatagory.ultimate
    //
    //        let pa_charge = self.parkingLotData["pa_charge"] as? JSONDictionary ?? [:]
    //
    //        if let ultimatevalet = pa_charge["ultimatevalet"] as? String{
    //            self.setChargeType(ultimatevalet)
    //        }
    //
    //        self.reservLotTableView.reloadData()
    //
    //    }
    
    
    //    func setChargeType(_ charge : Any){
    //
    //        userDefaults.set(charge, forKey: NSUserDefaultsKeys.CHARGE)
    //
    //        if !self.parkingLotData.isEmpty{
    //
    //
    //            if let type = self.parkingLotData["pa_charge_type"] as? String{
    //
    //                if type == myAppconstantStrings.per_hr{
    //
    //                    userDefaults.set(type, forKey: NSUserDefaultsKeys.CHARGE_TYPE)
    //                }
    //                else{
    //
    //                    userDefaults.set(type, forKey: NSUserDefaultsKeys.CHARGE_TYPE)
    //                }
    //            }
    //        }
    //    }
    
    
    //MARK:- Functions
    //MARK:-  -------------------------------------------------------------------------------
    
    func getDateAndTime(){
        
        let dateFormatter = DateFormatter()
        if self.pickerSelect == .date{
            if self.selectDate == .arrival_date{
                self.totalTime = 0
                dateFormatter.dateFormat = "dd MMM yyyy"
                self.datePicker.minimumDate = Foundation.Date()
                let strDate = dateFormatter.string(from: self.datePicker.date)
                self.selectedDateDict["arrival_date"] = strDate
                let dateFormatt = DateFormatter()
                dateFormatt.dateFormat = "yyyy-MM-dd"
                let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let currentDate: Foundation.Date = Foundation.Date()
                var components: DateComponents = DateComponents()
                components.month = 1
                let maxDate: Foundation.Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
                self.datePicker.maximumDate = maxDate
                self.datePicker.minimumDate = Foundation.Date()
                let Date = dateFormatt.string(from: self.datePicker.date)
                self.selectedDateDict["arrival_send_date"] = Date
                self.getTimeDuration()
                self.reservLotTableView.reloadData()
            }
            else if self.selectDate == .return_date{
                
                dateFormatter.dateFormat = "dd MMM yyyy"
                self.datePicker.minimumDate = Foundation.Date()
                let strDate = dateFormatter.string(from: self.datePicker.date)
                self.selectedDateDict["return_date"] = strDate
                let dateFormatt = DateFormatter()
                let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let currentDate: Foundation.Date = Foundation.Date()
                var components: DateComponents = DateComponents()
                components.month = 1
                let maxDate: Foundation.Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
                self.datePicker.maximumDate = maxDate
                if let _ = self.selectedDateDict["arrival_send_date"],let _ = self.selectedDateDict["arrival_time"]{
                    self.datePicker.minimumDate = getDurationFromCurrentDate()
                }
                dateFormatt.dateFormat = "yyyy-MM-dd"
                let Date = dateFormatt.string(from: self.datePicker.date)
                self.selectedDateDict["return_send_date"] = Date
                self.getTimeDuration()
                self.reservLotTableView.reloadData()
            }
            
        }
        else if self.pickerSelect == .time{
            
            if self.selectDate == .arrival_time{
                
                dateFormatter.dateFormat = "HH:mm:ss"
                
                self.datePicker.minimumDate = Date()
                
                self.selectedDateDict["arrival_time"] = dateFormatter.string(from: self.datePicker.date)
                
                self.getTimeDuration()
                
                if let arrival_date =  self.selectedDateDict["arrival_send_date"], let arrival_time = self.selectedDateDict["arrival_time"]{
                    
                    arrivalTime =  arrival_date + " " + arrival_time
                }
                
                self.reservLotTableView.reloadData()
                
            }
            else if self.selectDate == .return_time{
                
                dateFormatter.dateFormat = "HH:mm:ss"
                
                if let _ = self.selectedDateDict["arrival_send_date"],let _ = self.selectedDateDict["arrival_time"]{
                    
                    //                    let _: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    
                    var components: DateComponents = DateComponents()
                    
                    components.hour = 1
                    
                    //let minDate: Date = (gregorian as NSCalendar).date(byAdding: components, to: getDurationFromCurrentDate(), options: NSCalendar.Options(rawValue: 0))!
                    
                    self.datePicker.minimumDate = Date()
                }
                self.selectedDateDict["return_time"] = dateFormatter.string(from: self.datePicker.date)
                self.getTimeDuration()
                self.reservLotTableView.reloadData()
                
            }
        }
    }
    
    fileprivate func matchCurrentDate() -> Bool{
        let currentDate:Date = Date()
        let dateFormetter = DateFormatter()
        dateFormetter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormetter.string(from: currentDate)
        let strDate = dateFormetter.date(from: dateStr)
        let arrival = dateFormetter.date(from: self.arrivalTime)
        let duration = arrival?.minutesFrom(strDate!)
        if duration < 0{
            return true
        }
        else{
            return false
        }
    }
    
    func getDurationFromCurrentDate() -> Date{
        
        let dateFormattre = DateFormatter()
        dateFormattre.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let arrivalDateAndTime =  self.selectedDateDict["arrival_send_date"]! + " " + self.selectedDateDict["arrival_time"]!
        return dateFormattre.date(from: arrivalDateAndTime)!
    }
    
    func getTimeDuration(){
        
        if let arrival_date =  self.selectedDateDict["arrival_send_date"], let arrival_time = self.selectedDateDict["arrival_time"] , let returnDate = self.selectedDateDict["return_send_date"] , let return_time = self.selectedDateDict["return_time"]{
            let arrivalDateAndTime =  arrival_date + " " + arrival_time
            let returnDAteAndTime = returnDate + " " + return_time
            let dateFormattre = DateFormatter()
            dateFormattre.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let arrivalDate = dateFormattre.date(from: arrivalDateAndTime)
            let returnDate = dateFormattre.date(from: returnDAteAndTime)
            self.totalTime = (returnDate?.minutesFrom(arrivalDate!))!
        }
    }
    
    
    func confirmReserveVehicle(){
        
        
        var catagory = ""
        
        if self.index == nil{
            AppDelegate.showToast(myAppconstantStrings.selectVehicle)
            return
        }
        
        guard let _ = self.selectedDateDict["arrival_send_date"] else{
            AppDelegate.showToast(myAppconstantStrings.selectDate)
            return
        }
        guard let _ = self.selectedDateDict["arrival_time"] else{
            AppDelegate.showToast(myAppconstantStrings.selectTime)
            return
            
        }
        guard let _ = self.selectedDateDict["return_send_date"] else{
            AppDelegate.showToast(myAppconstantStrings.selectDate)
            return
        }
        guard let _ = self.selectedDateDict["return_time"] else{
            AppDelegate.showToast(myAppconstantStrings.selectTime)
            return
        }
        if matchCurrentDate(){
            AppDelegate.showToast("Past reservation date is not allowed")
            return
        }
        
        var charge: Double = 0
        var data = Data()
        do {
            data = try JSONSerialization.data(
                withJSONObject: parkingSharedInstance.selectedFacility ,
                options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        catch{
            print_debug("error")
        }
        
        let facilities = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        switch self.parking_catagory {
            
        case .economy:
            
            catagory = "economy"
            
            if let eco = self.parkingLotData.economy{
                
                charge = Double("\(eco)")!
            }
            
        case .business:
            
            
            catagory = "business"
            
            if let business = self.parkingLotData.business{
                
                charge = Double("\(business)")!
            }
            
        case .indoor:
            
            catagory = "premium"
            
            if let indoor = self.parkingLotData.premium{
                
                charge = Double("\(indoor)")!
            }
            
        case .outdoor:
            
            catagory = "outdoor"
            
            if let outdoor = self.parkingLotData.outdoor{
                
                charge = Double("\(outdoor)")!
            }
            
        case .ultimate:
            
            catagory = "ultimatevalet"
            
            if let ultimatevalet = self.parkingLotData.ultimatevalet{
                
                charge = Double("\(ultimatevalet)")!
            }
            
        default:
            
            print_debug("************ default case ************")
        }
        
        var params = JSONDictionary()
        
        params["pa_id"] = self.parkingLotData._id
        params["user_id"] = CurrentUser.id
        params["vehicle"] = self.carName[index]
        params["plate_no"] = self.plateNo[index]
        params["date"] = self.selectedDateDict["arrival_send_date"]! + " " + self.selectedDateDict["arrival_time"]!
        
        params["duration"] = (Double(self.totalTime) / 60).roundToPlaces(2)
        params["category"] = catagory
        params["bt_customer_id"] = CurrentUser.customer_id
        
        
        params["reserved_until"] = self.selectedDateDict["return_send_date"]! + " " + self.selectedDateDict["return_time"]!
        
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
        
        CommonClass.startLoader()
        
        WebserviceController.reservationService(params, succesBlock: { (success, json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                AppDelegate.showToast(json["message"].stringValue)
                
                let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                obj.tabBarTempState = TabBarTempState.historyActive
                self.navigationController?.pushViewController(obj, animated: true)
                
            } else {
                
                AppDelegate.showToast(json["message"].stringValue)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
    }
    
    
    func getVehicleName(){
        
        if CurrentUser.vehicles?.count > 0{
            for key in (CurrentUser.vehicles?.keys)!{
                self.carName.append(key)
            }
        }
        if CurrentUser.vehicles?.count > 0{
            for key in (CurrentUser.vehicles?.values)!{
                self.plateNo.append(key as! String)
            }
        }
    }
    
    func getFacilities(){
        
        for res in self.indexes{
            self.facilityName.append(self.facilities[res]["fl_name"] as! String)
            self.facilitycost.append(self.facilities[res]["fl_price"] as! String)
        }
    }
    
    
    func setDurationWithDayAndHour() -> String{
        
        let remainder = self.totalTime % 1440
        
        let day = self.totalTime / 1440
        
        let hour = remainder / 60
        
        let min = remainder % 60
        
        if day > 0 && hour > 0 && min > 0{
            return "\(day) day, \(hour) hr, \(min) min"
        }
        else if day > 0 && hour > 0 && min == 0{
            return "\(day) day, \(hour) hr"
        }
        else if day > 0 && hour == 0 && min > 0{
            return "\(day) day, \(min) min"
        }
        else if day > 0 && hour == 0 && min == 0{
            return "\(day) day"
        }
            
        else if day == 0 && hour > 0 && min == 0{
            return "\(hour) hr"
        }
        else if day == 0 && hour > 0 && min > 0{
            return "\(hour) hr, \(min) min"
        }
        else if day == 0 && hour == 0 && min > 0{
            return "\(min) min"
        }
        else{
            return "\(min) min"
        }
    }
}


//MARK:- set selected vehicle delegate method
//MARK:-  ====================================

extension ReserveLotVC: SetSelectedVehicleDelegate{
    
    func setSelectedVehicle(_ selectedIndex: IndexPath) {
        
        self.index = selectedIndex.item
        self.reservLotTableView.reloadData()
        
    }
    
    func pushView() {
        
    }
}


//MARK:- Table View Delegate And Datasource
//MARK:-  -------------------------------------------------------------------------------


extension ReserveLotVC: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.facilityName.count == 0{
            if section == 10{
                return 2
            }
            else if section == 9{
                
                return self.parkingLotData.pa_charge_grid.count
                
            }else{
                
                return 1
            }
        }
        else{
            if section == 10{
                
                return self.facilityName.count + 1
                
            }else if section == 9{
                
                return self.catagoryList.count
                
            }else{
                
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return setTableViewData(indexPath, tableView: tableView)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
            
        case 0:
            return UIScreen.main.bounds.height / 4
        case 1,2,4,3,5,6,7:
            return 60
        case 8:
            return 44
        case 9:
            if indexPath.row == 0{
                return 76
            }else{
                return 36
                
            }
            
        case 10:
            
            if indexPath.row == 0{
                return 30
            }
            else{
                if self.facilityName.count > 0{
                    return 25
                }
                else{
                    return 44
                }
            }
            
        default:
            return 70
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    
    func setTableViewData(_ indexPath:IndexPath,tableView:UITableView) -> UITableViewCell{
        
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
            cell.parkinLotNameLbl.text = self.parkingLotData.pa_name
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoupancodeCell", for: indexPath) as! CoupancodeCell
            cell.iconImage.image = UIImage(named: "location")
            cell.parkinLocationLbl.text = "Location"
            cell.LocationNameLbl.isHidden = false
            cell.iconImage.isHidden = false
            cell.seperatorView.isHidden = false
            cell.Bgview.roundCorners([.bottomLeft,.bottomRight], radius: 0.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 60))
            
            cell.LocationNameLbl.text = self.parkingLotData.pa_address + ", " + self.parkingLotData.pa_location
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.symbolImage.image = UIImage(named: "reserve")
            cell.symbolImage.isHidden = false
            cell.locationNameLbl.isHidden = false
            
            if let _ = self.index{
                cell.placeLbl.text = self.carName[index]
            }
            else{
                cell.placeLbl.text = "Select Vehicle"
                
            }
            cell.locationNameLbl.text = "Vehicle"
            
            return cell
        case 4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.symbolImage.image = UIImage(named: "reserve")
            cell.addBtn.setImage(UIImage(named: "reserve_calendar"), for: UIControlState())
            cell.symbolImage.isHidden = false
            cell.locationNameLbl.isHidden = false
            cell.locationNameLbl.text = "Reserve for"
            if let arrival_date = self.selectedDateDict["arrival_date"], arrival_date != ""{
                cell.placeLbl.text = arrival_date
            }
            else{
                cell.placeLbl.text = "Select Date"
            }
            return cell
            
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.symbolImage.image = UIImage(named: "reserve")
            cell.symbolImage.isHidden = true
            cell.locationNameLbl.isHidden = true
            cell.addBtn.setImage(UIImage(named: "reserve_clock"), for: UIControlState())
            cell.locationNameLbl.text = "Reserve for"
            if let arrival_time = self.selectedDateDict["arrival_time"], arrival_time != ""{
                cell.placeLbl.text = arrival_time
            }
            else{
                cell.placeLbl.text = "Select Time"
            }
            
            return cell
        case 6:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.symbolImage.image = UIImage(named: "reserve")
            cell.addBtn.setImage(UIImage(named: "reserve_calendar"), for: UIControlState())
            cell.symbolImage.isHidden = false
            cell.locationNameLbl.isHidden = false
            cell.locationNameLbl.text = "Reserve until"
            if let return_date = self.selectedDateDict["return_date"], return_date != ""{
                cell.placeLbl.text = return_date
            }
            else{
                cell.placeLbl.text = "Select Date"
            }
            
            return cell
            
        case 7:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.symbolImage.image = UIImage(named: "reserve")
            cell.symbolImage.isHidden = true
            cell.locationNameLbl.isHidden = true
            cell.addBtn.setImage(UIImage(named: "reserve_clock"), for: UIControlState())
            cell.locationNameLbl.text = "Reserve for"
            if let return_time = self.selectedDateDict["return_time"], return_time != ""{
                cell.placeLbl.text = return_time
            }
            else{
                cell.placeLbl.text = "Select Time"
            }
            
            return cell
            
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.symbolImage.image = UIImage(named: "duration")
            cell.symbolImage.isHidden = false
            cell.locationNameLbl.isHidden = false
            cell.placeLbl.text = ""
            cell.addBtn.setImage(UIImage(named: ""), for: UIControlState())
            if self.totalTime == 0{
                if let _ = self.selectedDateDict["return_time"]{
                    cell.locationNameLbl.text = "Duration :   0 min"
                    
                }else{
                    cell.locationNameLbl.text = "Duration"
                }
            }
            else{
                cell.locationNameLbl.text = "Duration :   \(setDurationWithDayAndHour())"
            }
            
            return cell
            
        case 9:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath) as! DurationCell
            
            let data = self.parkingLotData.pa_charge_grid[indexPath.row]
            let cat = data.category ?? ""
            let charge = data.charge ?? ""
            
            cell.symbolImage.image = UIImage(named: "amount")
            
            cell.durationLbl.text = "Amount"
            
            let str = cat + "  :  "
            let str2 = str + "$" + charge
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
            
            
            
            switch self.parking_catagory {
                
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
            if self.facilityName.isEmpty{
                
                cell.bgView.roundCorners([.bottomLeft,.bottomRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 170))
            }
            return cell
            
            
        case 10:
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CoupancodeCell", for: indexPath) as! CoupancodeCell
                cell.iconImage.image = UIImage(named: "additional_facility")
                cell.parkinLocationLbl.text = myAppconstantStrings.carCare
                cell.LocationNameLbl.isHidden = true
                cell.seperatorView.isHidden = true
                return cell
            }
            if self.facilityName.count > 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedFacilityCell", for: indexPath) as! SelectedFacilityCell
                cell.facilityNameLbl.text = facilityName[indexPath.row - 1]
                cell.priceLbl.text = "$" + self.facilitycost[indexPath.row - 1]
                cell.bgView.roundCorners([.bottomLeft,.bottomRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 25))
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CoupancodeCell", for: indexPath) as! CoupancodeCell
                cell.iconImage.isHidden = true
                cell.parkinLocationLbl.text = myAppconstantStrings.facilityWarn
                cell.LocationNameLbl.isHidden = true
                cell.seperatorView.isHidden = true
                cell.Bgview.roundCorners([.bottomLeft,.bottomRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 44))
                return cell
            }
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmBtnCell", for: indexPath) as! ConfirmBtnCell
            cell.bgView.layer.cornerRadius = 3
            cell.bgView.layer.borderWidth = 1
            cell.bgView.layer.borderColor = UIColor.gray.cgColor
            cell.confirmBtn.addTarget(self, action: #selector(ReserveLotVC.onTapConfirmBtn(_:)), for: UIControlEvents.touchUpInside)
            cell.cancelBtn.addTarget(self, action: #selector(ReserveLotVC.onTapCancelBtn(_:)), for: UIControlEvents.touchUpInside)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
            onTapAddBtn()
        case 4:
            openDatePicker(indexPath)
            
        case 5:
            openTimePicker(indexPath)
        case 6:
            openDatePicker(indexPath)
            
        case 7:
            openTimePicker(indexPath)
            
        case 9:
            
            let data = self.parkingLotData.pa_charge_grid[indexPath.row]
            
            let cat = data.category ?? ""
            
            let charge = data.charge ?? ""
            
            userDefaults.set(charge, forKey: NSUserDefaultsKeys.CHARGE)
            
            switch cat{
                
            case "Economy":
                self.parking_catagory = .economy
                self.category = "economy"
            case "Business":
                self.parking_catagory = .business
                self.category = "business"
                
            case "Premium Indoor":
                self.parking_catagory = .indoor
                self.category = "premium"
                
            case "Premium Outdoor":
                self.parking_catagory = .outdoor
                self.category = "outdoor"
                
            case "Ultimate Valet":
                self.parking_catagory = .ultimate
                self.category = "ultimatevalet"
                
            default:
                self.parking_catagory = .none
                
                
            }
            
            self.reservLotTableView.reloadSections([9], with: .none)
            
        default:
            print_debug("")
        }
    }
}


//MARK:- Table view cell classess
//MARK:-  -------------------------------------------------------------------------------

class ConfirmBtnCell: UITableViewCell{
    
    //MARK:- OUTLETS
    //MARK:- ********************************************************
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
}



class LocationCell: UITableViewCell{
    
    @IBOutlet weak var symbolImage: UIImageView!
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func showHideFields(_ isShow: Bool){
        
        self.locationTextField.isHidden = isShow
        self.placeLbl.isHidden = !isShow
        
        
    }
    
}


class DurationCell:UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var catagoryView: UIView!
    @IBOutlet weak var symbolImage: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var categoryRadiobtn: UIButton!
    @IBOutlet weak var categorylbl: UILabel!
    @IBOutlet weak var categoryViewHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}



