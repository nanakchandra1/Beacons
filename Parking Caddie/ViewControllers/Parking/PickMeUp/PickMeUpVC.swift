//
//  PickMeUpVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 11/08/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit

class PickMeUpVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- ========================================
    
    @IBOutlet weak var selectDateTextfield: UITextField!
    @IBOutlet weak var selectTimeTextField: UITextField!
    @IBOutlet weak var selectLocTextField: UITextField!
    @IBOutlet weak var locationTableView: UITableView!
    
    @IBOutlet weak var bgView: UIView!
    
    var datePicker  = UIDatePicker()
    var pickupData = JSONDictionary()
    var isLocationFilled = false
    var matchedLocationsDict = JSONDictionaryArray()
    var delegate:BringMyCarDelegate!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.bgView.layer.cornerRadius = 3
        self.datePicker.datePickerMode = UIDatePickerMode.date
        self.selectDateTextfield.inputView = self.datePicker
        self.selectTimeTextField.inputView = self.datePicker
        self.selectLocTextField.delegate = self
        self.selectDateTextfield.delegate = self
        self.selectTimeTextField.delegate = self
        self.locationTableView.delegate = self
        self.locationTableView.dataSource = self
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(self.dismissPicker))
        self.locationTableView.isHidden = true

        self.selectTimeTextField.inputAccessoryView = toolBar
        self.selectDateTextfield.inputAccessoryView = toolBar

    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.locationTableView.isHidden = true
        self.selectLocTextField.resignFirstResponder()
        if let view = touches.first?.view {
            
            if view == self.view && !self.view.subviews.contains(view) {
                
                self.dismiss(animated: true, completion: nil)
            }
        }

    }
    
    //MARK:- IBActions
    //MARK:- ========================================
    
    @IBAction func crossBtnTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func submitBtnTapped(_ sender: UIButton) {
        
        guard let location = self.pickupData["location"] else{
            AppDelegate.showToast("Please select location")
            return
        }
        guard let date = self.pickupData["date"] else{
            AppDelegate.showToast("Please select Data")
            return
        }
        guard let time = self.pickupData["time"] else{
            AppDelegate.showToast("Please select time")
            return
        }
        
        var params = JSONDictionary()
        params["lat"] = self.pickupData["lat"]
        params["long"] = self.pickupData["long"]
        params["location"] = location
        params["pickup_time"] = time
        params["pickup_date"] = date
        params["api_type"] = "pickup"
        
        CommonClass.startLoader()
        WebserviceController.pickMeUpAPI(params, succesBlock: { (success, json) in
            if success{
                self.dismiss(animated: true, completion: {
                
                    AppDelegate.showToast("You will get your pickup conformation detail shortly")
                    self.delegate.getBackMyCar(true, request_for_custom_location: false)

                })
            }
        }) { (error) in
            
            
        }

    }

    
    func dismissPicker(){
    
        self.view.endEditing(true)
        let dateforematter = DateFormatter()
        self.datePicker.minimumDate = Foundation.Date()

        if self.datePicker.datePickerMode == .date{
        
            dateforematter.dateFormat = "dd MMM yyyy"
            self.selectDateTextfield.text = dateforematter.string(from: self.datePicker.date)
            dateforematter.dateFormat = "dd-MM-yyyy"
            self.pickupData["date"] = dateforematter.string(from: self.datePicker.date)
            
        }else{
            
            dateforematter.dateFormat = "hh:mm a"
            self.selectTimeTextField.text = dateforematter.string(from: self.datePicker.date)
            dateforematter.dateFormat = "HH:mm"
            self.pickupData["time"] = dateforematter.string(from: self.datePicker.date)

        }
    }
}


//MARK:- UITextfield delegate methods
//MARK:- ========================================

extension PickMeUpVC: UITextFieldDelegate{

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === self.selectDateTextfield{
            
            self.datePicker.datePickerMode = UIDatePickerMode.date
            
        }else if textField === self.selectTimeTextField{
            
            self.datePicker.datePickerMode = UIDatePickerMode.time
            
        }
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        CommonClass.delay(0.1) {
            
            if !textField.hasText{
                self.matchedLocationsDict.removeAll()
                self.locationTableView.isHidden = true
            }

            else if textField === self.selectLocTextField{
                self.locationTableView.isHidden = false

                WebserviceController.fetchData(withInput: textField.text!, success: { (success, json) in
                    
                    let status = json["status"].string ?? ""
                    let result = json["predictions"].array ?? [["" : "" ]]
                    
                    guard status == "OK" else {
                        
                        
                        self.locationTableView.reloadData()
                        
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
                        self.locationTableView.reloadData()
                    })

                    
                }, failure: { (error) in
                    
                })
            }
        }
        
        return true
    }
}


//MARK:- UItableview delegate methods
//MARK:- ========================================

extension PickMeUpVC: UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchedLocationsDict.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocCell", for: indexPath) as! SearchLocCell
        
        let data = self.matchedLocationsDict[indexPath.row]
        cell.locLbl.text = data["address"] as? String ?? ""
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = self.matchedLocationsDict[indexPath.row]
        WebserviceController.fetchcoor(withPlaceID: data["place_id"] as? String ?? "", success: { (success,json) in
            
            let status = json["status"].string ?? ""
            let result = json["result"].dictionary ?? [:]
            guard status == "OK" else{ return }

            let geometry = result["geometry"]?.dictionary ?? [:]
            let location = geometry["location"]?.dictionary ?? [:]
            self.pickupData["lat"] = location["lat"]?.double ?? 0
            self.pickupData["long"] = location["lng"]?.double ?? 0
            self.selectLocTextField.text = self.matchedLocationsDict[indexPath.row]["address"] as? String ?? ""
            self.pickupData["location"] = self.selectLocTextField.text
            
            self.isLocationFilled = true
            self.locationTableView.isHidden = true
            self.selectLocTextField.resignFirstResponder()

//            WebserviceController.getAddressForLatLng(latitude: "\(String(describing: self.pickupData["lat"]!))", longitude: "\(String(describing: self.pickupData["long"]!))", successBlock: { (success, json) in
//                
//                let status = json["status"].string ?? ""
//                let result = json["results"].array ?? [[:]]
//                guard status == "OK" else{ return }
//
//                self.selectLocTextField.text = self.matchedLocationsDict[indexPath.row]["address"] as? String ?? ""
//                self.pickupData["location"] = self.selectLocTextField.text
//
//                self.isLocationFilled = true
//                self.locationTableView.isHidden = true
//                self.selectLocTextField.resignFirstResponder()
//
//            })
//            
        }) { (erroe) in
            
            
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}


class SearchLocCell: UITableViewCell {

    @IBOutlet weak var locLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
