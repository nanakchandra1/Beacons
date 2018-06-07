//
//  RequestPickUpVC.swift
//  Parking Caddie
//
//  Created by apple on 16/08/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

enum SelectLocType {
    case Loc, exit, none
}


protocol BringMyCarDelegate {
    
    func getBackMyCar(_ is_request_pickup: Bool, request_for_custom_location: Bool)
    
}


class RequestPickUpVC: UIViewController {
    
    //MARK:- IBOutlets
    //MARK:- =================================
    @IBOutlet var myLocationRadioBtn: UIButton!
    @IBOutlet var searchLocBgView: UIView!
    @IBOutlet var searchTectField: UITextField!
    @IBOutlet var locHeightConstant: NSLayoutConstraint!
    @IBOutlet var searchLocTableView: UITableView!
    @IBOutlet var parkingExitRadioBtn: UIButton!
    @IBOutlet var exitHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var exitTerminalLbl: UILabel!
    @IBOutlet var selectNearestExitBtn: UIButton!
    @IBOutlet var timeDropDownBtn: UIButton!
    @IBOutlet var nearestExityTableView: UITableView!
    @IBOutlet var selectTimeTableView: UITableView!
    @IBOutlet var timeHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var popupBgView: UIView!
    @IBOutlet weak var popupHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var doneBtn: UIButton!
    
    
    var selectLocType = SelectLocType.none
    var matchedLocationsDict = JSONDictionaryArray()
    var pickupData = JSONDictionary()
    //let exitTerminal = ["Terminal-1","Terminal-2","Terminal-3","Terminal-4","Terminal-5"]
    let time = ["Please select time","Now","15 min","30 min","45 min","60 min"]
    let timeAdd = ["Please select time","0","15","30","45","60"]

    var delegate:BringMyCarDelegate!
    var exitTerminal = [ExitTerminalModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetupView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
        if let view = touches.first?.view {
            
            if view == self.view && !self.view.subviews.contains(view) {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- IBAction
    //MARK:- =================================
    
    @IBAction func selectLocTap(_ sender: UIButton) {
        
        self.selectLocType = .Loc
        self.pickupData.removeValue(forKey: "terminal")
        self.pickupData.removeValue(forKey: "terminal_name")

        self.setHeight(35, exit: 0, time: 0)
        self.parkingExitRadioBtn.setImage(UIImage(named: "radio"), for: .normal)
        self.myLocationRadioBtn.setImage(UIImage(named: "radio_tick"), for: .normal)

    }
    
    @IBAction func exitRadioBtnTapped(_ sender: Any) {
        
        self.pickupData.removeValue(forKey: "location")
        self.selectLocType = .exit
        self.parkingExitRadioBtn.setImage(UIImage(named: "radio_tick"), for: .normal)
        self.myLocationRadioBtn.setImage(UIImage(named: "radio"), for: .normal)

        self.setHeight(0, exit: 35, time: 0)
        
    }
    
    @IBAction func selectExitDropDownBtn(_ sender: UIButton) {
        
        self.setHeight(0, exit: 150, time: 0)
        
    }
    
    @IBAction func timeDropDownBtn(_ sender: UIButton) {
        
        if let _ = self.pickupData["location"]{
        
            self.setHeight(35, exit: 0, time: 150)
            
        }else if let _ = self.pickupData["terminal"]{
            
            self.setHeight(0, exit: 35, time: 150)
            
        }else{
            self.setHeight(0, exit: 0, time: 150)
        }

        
    }
    
    
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        if self.selectLocType == .none{
        
            AppDelegate.showToast("Please select location type")
            return
        }else if self.selectLocType == .Loc{
        
            
            self.bringMyCar(customlocation: "customlocation")
        }else{
            
            
            self.bringMyCar(customlocation: "regularlocation")

        }
        
    }
    
    
    //MARK:- Methods
    //MARK:- =================================
    
    func initialSetupView(){
        
        self.searchTectField.delegate = self
        searchLocTableView.delegate = self
        searchLocTableView.dataSource = self
        nearestExityTableView.delegate = self
        nearestExityTableView.dataSource = self
        selectTimeTableView.delegate = self
        selectTimeTableView.dataSource = self
        self.searchLocBgView.layer.cornerRadius = 3
        self.popupBgView.layer.cornerRadius = 3
        self.selectTimeTableView.layer.cornerRadius = 3
        self.nearestExityTableView.layer.cornerRadius = 3
        self.searchLocBgView.layer.cornerRadius = 3
        self.doneBtn.layer.cornerRadius = 3
        
        let json = JSON(["ploc_name": "please selct nearest terminal","_id": ""])
        
        self.exitTerminal.insert(ExitTerminalModel(withJSON: json), at: 0)
        
        self.setHeight(0, exit: 0, time: 0)
        self.searchLocTableView.register(UINib(nibName: "RequestPickUpCell", bundle: nil), forCellReuseIdentifier: "RequestPickUpCell")
        self.nearestExityTableView.register(UINib(nibName: "RequestPickUpCell", bundle: nil), forCellReuseIdentifier: "RequestPickUpCell")
        self.selectTimeTableView.register(UINib(nibName: "RequestPickUpCell", bundle: nil), forCellReuseIdentifier: "RequestPickUpCell")
        self.exitTerminalLbl.text = "Please select nearest exit"
        self.timeLbl.text = "Please select time"
        
    }
    
    
    func bringMyCar(customlocation: String){
    
        var params = JSONDictionary()


        
        if customlocation == "customlocation"{
        
            guard let location = self.pickupData["location"] else{
                AppDelegate.showToast("Please select location")
                return
            }
            guard let time = self.pickupData["time"] else{
                AppDelegate.showToast("Please select time")
                return
            }
            
            
            params["lat"] = self.pickupData["lat"]
            params["long"] = self.pickupData["long"]
            params["location"] = location
            params["request_time"] = time
            params["api_type"] = customlocation

        }else{
            
            guard let terminal = self.pickupData["terminal"] else{
                AppDelegate.showToast("Please select location")
                return
            }
            guard let time = self.pickupData["time"] else{
                AppDelegate.showToast("Please select time")
                return
            }

            params["terminal"] = terminal
            params["terminal_name"] = self.pickupData["terminal_name"]
            params["request_time"] = time
            params["api_type"] = customlocation
            params["location"] = self.pickupData["terminal_name"]

        }
        

        CommonClass.startLoader()

        WebserviceController.pickMeUpAPI(params, succesBlock: { (success, json) in
            if success{
                
                self.dismiss(animated: true, completion: {
                    
                    AppDelegate.showToast("Getting back your Car soon at your location")
                    
                    if customlocation == "customlocation"{
                        
                        AppDelegate.showToast("Getting back your Car soon at your location")
                        
                        self.delegate.getBackMyCar(false, request_for_custom_location: true)

                    }else{
                        
                        self.delegate.getBackMyCar(false, request_for_custom_location: false)

                    }
                })

            }
        }) { (error) in
            
            
        }

    
    }
    
    func setHeight(_ loc: CGFloat, exit: CGFloat, time: CGFloat){
        
        self.exitHeightConstant.constant = exit
        self.locHeightConstant.constant = loc
        self.timeHeightConstant.constant = time
        
        if loc == 150 || exit == 150 || time == 150{
            self.popupHeightConstant.constant = 420
            self.doneBtn.isEnabled = false
        }else{
            self.popupHeightConstant.constant = 300
            self.doneBtn.isEnabled = true
        }

    }
}


//MARK:- UITextfield delegate methods
//MARK:- =================================

extension RequestPickUpVC: UITextFieldDelegate{
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.setHeight(150, exit: 0, time: 0)
        
        CommonClass.delay(0.01) {
            
            WebserviceController.fetchData(withInput: textField.text!, success: { (success, json) in
                
                let status = json["status"].string ?? ""
                let result = json["predictions"].array ?? [["" : "" ]]
                
                guard status == "OK" else {
                    
                    
                    self.searchLocTableView.reloadData()
                    
                    return
                    
                }
                
                self.matchedLocationsDict.removeAll()
                
                for location in result {
                    
                    let place_id = location["place_id"].string ?? ""
                    let address = location["description"].string ?? ""
                    let dict:JSONDictionary = ["place_id": place_id, "address": address]
                    
                    self.matchedLocationsDict.append(dict)
                }
                CommonClass.delay(Double(0.01), closure: {
                    self.searchLocTableView.reloadData()
                })
                
                
            }, failure: { (error) in
                
            })
        }
        
        return true
    }
    
}

//MARK:- UITableview delegate datasource methods
//MARK:- =================================


extension RequestPickUpVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.searchLocTableView{
            return self.matchedLocationsDict.count
        }else if tableView == self.nearestExityTableView{
            return self.exitTerminal.count

        }else{
            return self.time.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestPickUpCell") as! RequestPickUpCell
        
        if tableView === self.searchLocTableView{
            
            let data = self.matchedLocationsDict[indexPath.row]
            
            cell.locLbl.text = data["address"] as? String ?? ""
            
        }else if tableView == self.nearestExityTableView{
            
                cell.locLbl.text =  self.exitTerminal[indexPath.row].ploc_name

        }else{
            cell.locLbl.text = self.time[indexPath.row]

        }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)

        if tableView === self.searchLocTableView{
            
            let data = self.matchedLocationsDict[indexPath.row]
            CommonClass.startLoader()

            WebserviceController.fetchcoor(withPlaceID: data["place_id"] as? String ?? "", success: { (success,json) in
                
                print_debug(json)
                let status = json["status"].string ?? ""
                let result = json["result"].dictionary ?? [:]
                guard status == "OK" else{ return }
                
                let geometry = result["geometry"]?.dictionary ?? [:]
                let location = geometry["location"]?.dictionary ?? [:]
                let lat = location["lat"]?.double ?? 0
                let long = location["lng"]?.double ?? 0
                self.pickupData["lat"] = lat
                self.pickupData["long"] = long

                self.searchTectField.text = self.matchedLocationsDict[indexPath.row]["address"] as? String ?? ""
                self.pickupData["location"] = self.matchedLocationsDict[indexPath.row]["address"] as? String ?? ""
                
                let newPosition = self.searchTectField.beginningOfDocument
                self.searchTectField.selectedTextRange = self.searchTectField.textRange(from: newPosition, to: newPosition)
                
                
            }) { (erroe) in
                
                
            }
            
            self.setHeight(35, exit: 0, time: 0)

        }else if tableView === self.nearestExityTableView{
            
            if indexPath.row != 0{
                
                self.pickupData["terminal"] = self.exitTerminal[indexPath.row]._id ?? ""
                
                self.pickupData["terminal_name"] = self.exitTerminal[indexPath.row].ploc_name ?? ""
                
                self.exitTerminalLbl.text = self.exitTerminal[indexPath.row].ploc_name

            }else{
                
                self.exitTerminalLbl.text = self.exitTerminal[indexPath.row].ploc_name

            }
            self.setHeight(0, exit: 35, time: 0)

        }else{
            
            self.timeLbl.text = self.time[indexPath.row]
            
            if indexPath.row != 0{
                
                self.pickupData["time"] = self.timeAdd[indexPath.row]
                
            }
            
            if let _ = self.pickupData["location"]{
                
                self.setHeight(35, exit: 0, time: 0)
                
            }else if let _ = self.pickupData["terminal"]{
                
                self.setHeight(0, exit: 35, time: 0)
                
            }else{
                self.setHeight(0, exit: 0, time: 0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}



