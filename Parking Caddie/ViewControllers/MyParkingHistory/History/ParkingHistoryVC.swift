//
//  ParkingHistoryVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON


class ParkingHistoryVC: UIViewController {
    
//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------

    var parkingHistoryList = [HistoryModel]()
    
//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------

    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    
    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.historyTableView.register(UINib(nibName: "ParkingHistoryWithoutCanceWithFacility", bundle: nil), forCellReuseIdentifier: "ParkingHistoryWithoutCanceWithFacility")
        historyWebService()
        self.historyTableView.dataSource =  self
        self.historyTableView.delegate = self
        self.historyTableView.separatorStyle = .none
        //NotificationCenter.default.addObserver(self, selector: #selector(self.historyWebService), name:NSNotification.Name(rawValue: "NOTIFICATION"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NOTIFICATION"), object: nil)
//    }


//MARK:- IBActions
//MARK:-  -------------------------------------------------------------------------------

    func onTapViewBtn(_ sender: UIButton){
        
        let indexPath = sender.tableViewIndexPath(self.historyTableView)
        let obj = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "ReceiptVC") as! ReceiptVC
        //obj.receiptInfo = self.parkingHistoryList[(indexPath?.row)!]
        obj.receiptState = ReceiptState.history
        obj.p_id = self.parkingHistoryList[(indexPath?.row)!]._id
        self.navigationController?.pushViewController(obj, animated: true)
        
    }


//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------

    
func historyWebService(){
    
    WebserviceController.parkingHistoryService({ (success, json) in
        
        if success{
        
            let result = json["result"].arrayValue
                        
            for res in result{
            
                let detail = HistoryModel(res)
                
                self.parkingHistoryList.append(detail)
                
            }
            self.historyTableView.reloadData()

        }
        
    }) { (error) in
        
    }
    }
    

}


//MARK:- Table view dalega and datasourcete
//MARK:-  -------------------------------------------------------------------------------

extension ParkingHistoryVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.parkingHistoryList.isEmpty{
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            emptyLabel.textColor = UIColor.gray
            emptyLabel.text = myAppconstantStrings.noHistory
            self.historyTableView.backgroundView = emptyLabel
            self.historyTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        }
        else{
            self.historyTableView.backgroundView?.isHidden = true
        }
        return self.parkingHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let details = self.parkingHistoryList[indexPath.row]
        
        if !details.facilities.isEmpty{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingHistoryWithFacilityCell", for: indexPath) as! ParkingHistoryWithFacilityCell

            if details.is_agent{
                
                cell.agentDetailviewHeightConstant.constant = 90
                cell.detailView.isHidden = false
                cell.agentNameLbl.text = details.ag_name
                cell.agentContactLbl.text = details.ag_phone
                cell.agentEmailLbl.text = details.ag_email
                
            }else{
                cell.agentDetailviewHeightConstant.constant = 0
                cell.detailView.isHidden = true
            }

            cell.facilityData = details.facilities
            
            cell.carCareLbl.text = "Car Care Services"
            
            cell.viewReceiptbtn.addTarget(self, action: #selector(ParkingHistoryVC.onTapViewBtn(_:)), for: UIControlEvents.touchUpInside)
            
                cell.parkingNameLbl.text = details.location
                cell.reservationNoLbl.text = "Reservation No :  \(details.reservation_no!)"

                cell.paidAmountLbl.text = "\(myAppconstantStrings.paid_am):   $\(details.amount!)"
            
                cell.durationLbl.text = "\(myAppconstantStrings.duration) :   \(details.duration!)hr"
            
                cell.catagoryLbl.text = "\(myAppconstantStrings.category) :    \(details.category!.capitalized)"

            
            if details.payment_mode.lowercased() == "cash"{
                
                cell.paymentTypeLbl.text = myAppconstantStrings.paymentmode + " : " + details.payment_mode
                
            }else if details.payment_mode == "N/A"{
                
                cell.paymentTypeLbl.text = myAppconstantStrings.paymentmode + " : " + "N/A"

            }else{
                
                cell.paymentTypeLbl.text = myAppconstantStrings.paymentmode + " : " + "Card"
                
            }

            if details.type != myAppconstantStrings.history_type{
                
                cell.typeLbl.text = "\(myAppconstantStrings.type) : \(details.type!)"
                cell.typeLbl.isHidden = false

                cell.arrivalTimeLbl.text = "\(myAppconstantStrings.arrival_time) : \(CommonClass.covert_UTC_to_Local_WithTime(details.reservation_date))"
                
                cell.returnTimeLbl.text = "\(myAppconstantStrings.expected_return) : \(CommonClass.covert_UTC_to_Local_WithTime(details.reserved_until))"
                
                cell.parkingDateLbl.text = "\(myAppconstantStrings.reserved_on) :    \(CommonClass.covert_UTC_to_Local_WithTime(details.parking_date))"
                
            }else{
                
                cell.typeLbl.isHidden = true
                
                cell.arrivalTimeLbl.text = "\(myAppconstantStrings.arrival_time) : \(CommonClass.covert_UTC_to_Local_WithTime(details.reservation_date))"
                
                cell.returnTimeLbl.text = "\(myAppconstantStrings.return_time) : \(CommonClass.covert_UTC_to_Local_WithTime(details.exit_time))"
                
                cell.parkingDateLbl.text = "\(myAppconstantStrings.parked_on) :    \(CommonClass.covert_UTC_to_Local_WithTime(details.parking_date))"
                
            }
            return cell
            
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingHistoryCell", for: indexPath) as! ParkingHistoryCell
            
            if details.is_agent{
                
                cell.agentDetailviewHeightConstant.constant = 90
                cell.detailView.isHidden = false
                cell.agentNameLbl.text = details.ag_name
                cell.agentContactLbl.text = details.ag_phone
                cell.agentEmailLbl.text = details.ag_email
                
            }else{
                cell.agentDetailviewHeightConstant.constant = 0
                cell.detailView.isHidden = true
            }

            
            cell.viewReceiptbtn.addTarget(self, action: #selector(ParkingHistoryVC.onTapViewBtn(_:)), for: UIControlEvents.touchUpInside)
            
            cell.parkingNameLbl.text = details.location
            
            cell.paidAmountLbl.text = "\(myAppconstantStrings.paid_am):   $\(details.amount!)"
            
            
            if details.payment_mode.lowercased() == "cash"{
                
                cell.paymentTypeLbl.text = myAppconstantStrings.paymentmode + " : " + details.payment_mode
                
            }else if details.payment_mode == "N/A"{
                
                cell.paymentTypeLbl.text = myAppconstantStrings.paymentmode + " : " + "N/A"
                
            }else{
                
                cell.paymentTypeLbl.text = myAppconstantStrings.paymentmode + " : " + "Card"
                
            }
            
            cell.reservationNoLbl.text = "Reservation No :  \(details.reservation_no!)"

            cell.durationLbl.text = "\(myAppconstantStrings.duration) :   \(details.duration!)hr"
            
            cell.catagoryLbl.text = "\(myAppconstantStrings.category) :    \(details.category!.capitalized)"
            
            
            if details.type != myAppconstantStrings.history_type{
                
                cell.typeLbl.text = "\(myAppconstantStrings.type) : \(details.type!)"
                cell.typeLbl.isHidden = false
                
                cell.arrivalTimeLbl.text = "\(myAppconstantStrings.arrival_time) : \(CommonClass.covert_UTC_to_Local_WithTime(details.reservation_date))"
                
                cell.returnTimeLbl.text = "\(myAppconstantStrings.expected_return) : \(CommonClass.covert_UTC_to_Local_WithTime(details.reserved_until))"
                
                cell.parkingDateLbl.text = "\(myAppconstantStrings.reserved_on) :    \(CommonClass.covert_UTC_to_Local_WithTime(details.parking_date))"
                
            }else{
                
                cell.typeLbl.isHidden = true
                
                cell.arrivalTimeLbl.text = "\(myAppconstantStrings.arrival_time) : \(CommonClass.covert_UTC_to_Local_WithTime(details.reservation_date))"
                
                cell.returnTimeLbl.text = "\(myAppconstantStrings.return_time) : \(CommonClass.covert_UTC_to_Local_WithTime(details.exit_time))"
                
                cell.parkingDateLbl.text = "\(myAppconstantStrings.parked_on) :    \(CommonClass.covert_UTC_to_Local_WithTime(details.parking_date))"
                
            }
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let details = self.parkingHistoryList[indexPath.row]

            if !details.facilities.isEmpty{
                
                if details.is_agent{
                    
                    return 295 + CGFloat(details.facilities.count * 25) + 105 + 30

                    
                }else{
                    return 295 + CGFloat(details.facilities.count * 25) + 30

                }
            }
            else{
                if details.is_agent{
                    
                    return 290 + 105 + 30

                }else{
                    return 290 + 30

                }
            }
    }
}





class ParkingHistoryCell: UITableViewCell {
    
    
    //MARK:- IBOutlets
    //MARK:-  -------------------------------------------------------------------------------
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var agentImage: UIImageView!
    @IBOutlet weak var agentNameLbl: UILabel!
    @IBOutlet weak var agentContactLbl: UILabel!
    @IBOutlet weak var agentEmailLbl: UILabel!
    @IBOutlet weak var agentDetailviewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var contactbtn: UIButton!

    
    @IBOutlet weak var reservationNoLbl: UILabel!
    @IBOutlet weak var paymentTypeLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var parkingNameLbl: UILabel!
    @IBOutlet weak var paidAmountLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var parkingDateLbl: UILabel!
    @IBOutlet weak var catagoryLbl: UILabel!
    @IBOutlet weak var arrivalTimeLbl: UILabel!
    @IBOutlet weak var returnTimeLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var viewReceiptbtn: UIButton!

    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.buttonLayout()
        self.bgView.layer.cornerRadius = 2
        
    }
    
    
    func buttonLayout(){
        
        self.viewReceiptbtn.layer.borderWidth = 1
        self.viewReceiptbtn.layer.borderColor = UIColor.appBlue.cgColor
        self.viewReceiptbtn.layer.cornerRadius = 2
        self.agentImage.layer.cornerRadius = 45/2
        self.agentImage.layer.borderColor = UIColor.appBlue.cgColor
        self.agentImage.layer.borderWidth = 1

    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.parkingNameLbl.text = ""
        self.paidAmountLbl.text = ""
        self.durationLbl.text = ""
        self.catagoryLbl.text = ""
        self.catagoryLbl.text = ""
        self.arrivalTimeLbl.text = ""
        self.returnTimeLbl.text = ""
        self.typeLbl.text = ""

    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    
}




class ParkingHistoryWithFacilityCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    var facilityData = [JSON]()
    var index:Int!

    //MARK:- IBOutlets
    //MARK:-  -------------------------------------------------------------------------------
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var agentImage: UIImageView!
    @IBOutlet weak var agentNameLbl: UILabel!
    @IBOutlet weak var agentContactLbl: UILabel!
    @IBOutlet weak var agentEmailLbl: UILabel!
    @IBOutlet weak var agentDetailviewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var contactbtn: UIButton!

    @IBOutlet weak var reservationNoLbl: UILabel!

    @IBOutlet weak var paymentTypeLbl: UILabel!

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var parkingNameLbl: UILabel!
    @IBOutlet weak var paidAmountLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var parkingDateLbl: UILabel!
    @IBOutlet weak var catagoryLbl: UILabel!
    @IBOutlet weak var arrivalTimeLbl: UILabel!
    @IBOutlet weak var returnTimeLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var viewReceiptbtn: UIButton!
    @IBOutlet weak var facilityTableView: UITableView!
    @IBOutlet weak var carCareLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.parkingNameLbl.text = ""
        self.paidAmountLbl.text = ""
        self.durationLbl.text = ""
        self.catagoryLbl.text = ""
        self.catagoryLbl.text = ""
        self.arrivalTimeLbl.text = ""
        self.returnTimeLbl.text = ""
        self.typeLbl.text = ""
        
    }
    
    func setupView(){
        
        self.facilityTableView.delegate = self
        self.facilityTableView.dataSource = self
        self.facilityTableView.register(UINib(nibName: "FacilityShowCell", bundle: nil), forCellReuseIdentifier: "FacilityShowCell")
        self.bgView.layer.cornerRadius = 2

        self.viewReceiptbtn.layer.borderWidth = 1
        self.viewReceiptbtn.layer.borderColor = UIColor.appBlue.cgColor
        self.viewReceiptbtn.layer.cornerRadius = 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.facilityData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.facilityTableView.dequeueReusableCell(withIdentifier: "FacilityShowCell", for: indexPath) as! FacilityShowCell
        
        let detail = self.facilityData[indexPath.row]
        
            cell.facilityNameLbl.text = detail["facility"].stringValue
        
            cell.facilityCharge.text = "$" + "\(detail["charge"].stringValue)"
        
            cell.availedLbl.text = "\(detail["status"].stringValue)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }

}


