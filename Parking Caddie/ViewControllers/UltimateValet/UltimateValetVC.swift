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


class UltimateValetVC: UIViewController {
    
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
    
    
    
    //MARK:- IBOutlets
    //MARK:-  -------------------------------------------------------------------------------
    
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
    //MARK:-  ====================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getVehicleName()
        getFacilities()
        self.reservLotTableView.dataSource = self
        self.reservLotTableView.delegate = self
        self.reservLotTableView.separatorStyle = .none
        self.datePickerBgBottomConstraint.constant = -170
        self.pickerBgViewBottomConstraint.constant = -180
        self.reservLotTableView.register(UINib(nibName: "CoupancodeCell", bundle: nil), forCellReuseIdentifier: "CoupancodeCell")
        self.reservLotTableView.register(UINib(nibName: "VehicleimageCell", bundle: nil), forCellReuseIdentifier: "VehicleimageCell")
        self.reservLotTableView.register(UINib(nibName: "ParkinLotnameCell", bundle: nil), forCellReuseIdentifier: "ParkinLotnameCell")
        self.reservLotTableView.register(UINib(nibName: "SelectedFacilityCell", bundle: nil), forCellReuseIdentifier: "SelectedFacilityCell")
        if let url = self.parkingLotData.pa_image{
            self.imgURL = "\(parkingImageUrl)\(url)"
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

        self.confirmReserveVehicle()
    }
    
    
    
    
    func onTapCancelBtn(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func onTapAddBtn(){
        
        self.datePickerBgView.isHidden = true
        self.pickerBgView.isHidden = true
        
        let obj = parkingStoryboard.instantiateViewController(withIdentifier: "SelectVehicleVC") as! SelectVehicleVC
        obj.delegate = self
        obj.modalPresentationStyle = .overCurrentContext
        obj.carName = self.carName
        self.present(obj, animated: true, completion: nil)
    }
    
    
    func openDatePicker(_ indexpath:IndexPath){
        
                self.selectDate = .arrival_date
                self.datePicker.minimumDate = Date()
                self.showHideDatePickerView(.date, pickerMode: SelectPickerView.date)
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
        
            if let _ = self.selectedDateDict["arrival_date"]{
                
                    self.selectDate = .arrival_time
                    self.datePicker.minimumDate = Date()
                    self.showHideDatePickerView(.time, pickerMode: SelectPickerView.time)
                
        }
    }
    
    
    
    func openPickerView(_ sender: UIButton){
        self.pickerBgView.isHidden = false
        self.datePickerBgView.isHidden = true
        self.pickerBgViewBottomConstraint.constant = 0
    }
    
    
//    
//    func onTapEconomyBtn(_ sender:UIButton){
//        self.parking_catagory = ParkingLotCatagory.economy
//        self.reservLotTableView.reloadData()
//        
//    }
//    
//    func onTapBuninessBtn(_ sender:UIButton){
//        self.parking_catagory = ParkingLotCatagory.business
//        self.reservLotTableView.reloadData()
//    }
//    
//    func onTapPremiumBtn(_ sender: UIButton){
//        self.parking_catagory = ParkingLotCatagory.premium
//        self.reservLotTableView.reloadData()
//    }
//    
//    func onTapUltimateValetBtn(_ sender: UIButton){
//        self.parking_catagory = ParkingLotCatagory.ultimate
//        self.reservLotTableView.reloadData()
//    }
    
    
    //MARK:- Functions
    //MARK:-  -------------------------------------------------------------------------------
    
    func getDateAndTime(){
        
        let dateFormatter = DateFormatter()
        
        
            if self.selectDate == .arrival_date{
                
                self.totalTime = 0
                dateFormatter.dateFormat = "dd MMM yyyy"
                self.datePicker.minimumDate = Foundation.Date()
                let strDate = dateFormatter.string(from: self.datePicker.date)
                self.selectedDateDict["arrival_date"] = strDate
                let dateFormatt = DateFormatter()
                dateFormatt.dateFormat = "dd-MM-yyyy"
                let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let currentDate: Foundation.Date = Foundation.Date()
                var components: DateComponents = DateComponents()
                components.month = 1
                let maxDate: Foundation.Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
                self.datePicker.maximumDate = maxDate
                self.datePicker.minimumDate = Foundation.Date()
                //let Date = dateFormatt.string(from: self.datePicker.date)
                self.selectedDateDict["arrival_send_date"] = CommonFunctions.stringFromDate(date: self.datePicker.date, dateFormat: "dd-MM-yyyy")
                self.reservLotTableView.reloadData()
            }
            else if self.pickerSelect == .time{
                
                if self.selectDate == .arrival_time{
                    
                    dateFormatter.dateFormat = "hh:mm a"
                    
                    self.datePicker.minimumDate = Date()
                    
                    self.selectedDateDict["arrival_time"] = dateFormatter.string(from: self.datePicker.date)
                    
                    dateFormatter.dateFormat = "HH:mm"
                    self.selectedDateDict["arrival_send_time"] = CommonFunctions.stringFromDate(date: self.datePicker.date, dateFormat: "HH:mm")

                }
            }
        
        self.reservLotTableView.reloadData()

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
    
    
    
    func confirmReserveVehicle(){
        
        if self.index == nil{
            AppDelegate.showToast(myAppconstantStrings.selectVehicle)
            return
        }
        
        guard let arrival_date = self.selectedDateDict["arrival_send_date"] else{
            AppDelegate.showToast(myAppconstantStrings.selectDate)
            return
        }
        guard let arrival_time = self.selectedDateDict["arrival_send_time"] else{
            AppDelegate.showToast(myAppconstantStrings.selectTime)
            return
            
        }
        guard let airportName = self.selectedDateDict["airpotName"] else{
            AppDelegate.showToast(myAppconstantStrings.airportName)
            return
        }
        guard let terminal = self.selectedDateDict["terminal"] else{
            AppDelegate.showToast(myAppconstantStrings.terminalName)
            return
        }
        
        var params = JSONDictionary()
        
        
        params["category"] = "ultimatevalet"
        params["pa_id"] = self.parkingLotData._id
        params["user_id"] = CurrentUser.id!
        params["vehicle"] = self.carName[index]
        params["plate_no"] = self.plateNo[index]
        params["bt_customer_id"] = CurrentUser.customer_id!
        params["arrival_date"] = arrival_date
        params["arrival_time"] = arrival_time
        params["terminal"] = terminal
        params["airline"] = airportName
        params["timezone"] = TimeZone.current.identifier

        
        if CurrentUser.charge != nil{
            
            params["charge"] = CurrentUser.charge
        }
        if CurrentUser.charge_type != nil{
            
            params["charge_type"] = CurrentUser.charge_type
        }
        if CurrentUser.tempCoupon_id != nil{
            
            params["coupon"] = CurrentUser.tempCoupon_id
        }
        else if CurrentUser.coupon_id != nil{
            
            params["coupon"] = CurrentUser.coupon_id
        }
        else{
            
            params["coupon"] = ""
        }
        
        if !parkingSharedInstance.selectedFacility.isEmpty{
            
            params["facilities"] = CommonFunctions.getJsonObject(parkingSharedInstance.selectedFacility)
            print_debug(params["facilities"])

        }
        
        print_debug(params)

        CommonClass.startLoader()
        WebserviceController.ultimateValetService(params, succesBlock: { (success, json) in
            
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
    
}


//MARK:- Set selected vehicle delegate
//MARK:-  ==================================

extension UltimateValetVC: SetSelectedVehicleDelegate{
    
    func setSelectedVehicle(_ selectedIndex: IndexPath) {
        self.index = selectedIndex.item
        self.reservLotTableView.reloadData()
    }
    
    func pushView() {
        
    }
}


//MARK:- Table View Delegate And Datasource
//MARK:-  ==================================


extension UltimateValetVC: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.facilityName.count == 0{
            if section == 9{
                return 2
            }
            else{
                return 1
            }
        }
        else{
            if section == 9{
                return self.facilityName.count + 1
            }
            else{
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
            if let pa_name = self.parkingLotData.pa_name{
                cell.parkinLotNameLbl.text = pa_name
            }
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
            cell.symbolImage.isHidden = false
            cell.showHideFields(true)
            cell.symbolImage.image = UIImage(named: "amount")
            cell.locationNameLbl.isHidden = false
            cell.locationNameLbl.text = "Amount"
            
            cell.addBtn.setImage(UIImage(named: ""), for: UIControlState())
            if let terminal = CurrentUser.charge{
                cell.placeLbl.text = terminal
            }
            else{
                cell.placeLbl.text = "Amount"
            }
            
            return cell
            
            
        case 4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.showHideFields(true)
            
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
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.showHideFields(true)
            
            cell.symbolImage.image = UIImage(named: "reserve")
            cell.addBtn.setImage(UIImage(named: "reserve_calendar"), for: UIControlState())
            cell.symbolImage.isHidden = false
            cell.locationNameLbl.isHidden = false
            cell.locationNameLbl.text = "Arrival"
            if let arrival_date = self.selectedDateDict["arrival_date"], arrival_date != ""{
                cell.placeLbl.text = arrival_date
            }
            else{
                cell.placeLbl.text = "Select Date"
            }
            return cell
            
        case 6:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.showHideFields(true)
            
            cell.symbolImage.isHidden = true
            cell.locationNameLbl.isHidden = true
            cell.addBtn.setImage(UIImage(named: "reserve_clock"), for: UIControlState())
            if let arrival_time = self.selectedDateDict["arrival_time"], arrival_time != ""{
                cell.placeLbl.text = arrival_time
            }
            else{
                cell.placeLbl.text = "Select Time"
            }
            
            return cell
            
        case 7:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.showHideFields(false)
            cell.symbolImage.image = UIImage(named: "airplane")
            cell.addBtn.setImage(UIImage(named: ""), for: UIControlState())
            cell.symbolImage.isHidden = false
            cell.locationNameLbl.isHidden = false
            cell.locationTextField.delegate = self
            cell.locationNameLbl.text = "Airport"
            
            if let airpotName = self.selectedDateDict["airpotName"], airpotName != ""{
                cell.locationTextField.text = airpotName
            }
            else{
                cell.locationTextField.attributedPlaceholder = NSAttributedString(string: "Airport Name", attributes: [NSForegroundColorAttributeName : UIColor.black])
            }
            
            return cell
            
        case 8:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
            cell.symbolImage.isHidden = true
            cell.showHideFields(false)
            cell.locationTextField.delegate = self

            cell.locationNameLbl.isHidden = true
            cell.addBtn.setImage(UIImage(named: ""), for: UIControlState())
            if let terminal = self.selectedDateDict["terminal"], terminal != ""{
                cell.placeLbl.text = terminal
            }
            else{
                cell.locationTextField.attributedPlaceholder = NSAttributedString(string: "Terinal", attributes: [NSForegroundColorAttributeName : UIColor.black])
                
            }
            
            return cell
            
        case 9:
            
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
        case 4:
            onTapAddBtn()
        case 5:
            openDatePicker(indexPath)
            
        case 6:
            openTimePicker(indexPath)
        default:
            print_debug("")
        }
    }
    
}


extension UltimateValetVC: UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let indexPath = textField.tableViewIndexPath(self.reservLotTableView)else{ return false}
        CommonClass.delay(0.1) {
            
            if indexPath.section == 7{
                self.selectedDateDict["airpotName"] = textField.text

            }else{
                self.selectedDateDict["terminal"] = textField.text

            }
        }
        return true
    }
}




