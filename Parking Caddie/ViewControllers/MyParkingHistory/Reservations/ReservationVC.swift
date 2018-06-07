//
//  ReservationVC.swift
//  Parking Caddie
//
//  Created by Anuj on 5/5/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReservationVC: UIViewController {
    
//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------

    var reservationHistory = JSONDictionaryArray()
    var reservationList = [ReservationModel]()


//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var reservationTableView: UITableView!
    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reservasionService()
        self.reservationTableView.delegate = self
        self.reservationTableView.dataSource = self
        //NotificationCenter.default.addObserver(self, selector: #selector(self.reservasionService), name:NSNotification.Name(rawValue: "NOTIFICATION"), object: nil)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NOTIFICATION"), object: nil)
//    }
    
//MARK:- IBActions
//MARK:-  -------------------------------------------------------------------------------
 
    
    func cancelReservation(_ sender: UIButton){
    
        guard let indexPath = sender.tableViewIndexPath(self.reservationTableView) else{return}
        let id = self.reservationHistory[(indexPath.row)]["_id"] as! String
        let alert = UIAlertController(title: "Alert", message: "Are you sure want to cancel", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: { alertAction in self.cancelReservationServic(id)
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func contactBtnTapped(_ sender: UIButton){
    
        guard let indexPath = sender.tableViewIndexPath(self.reservationTableView) else{return}

        dialPhoneNumer(self.reservationList[indexPath.row].ag_phone)
    }
    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------
   
    
    func reservasionService(){
        CommonClass.startLoader()
        
        WebserviceController.reservationHistoryService({ (success, json) in
            
            if success{
                
                let result = json["result"].arrayValue
                self.reservationHistory = json["result"].arrayObject as? JSONDictionaryArray ?? [[:]]
                self.reservationList = []
                for res in result{
                
                    let detail = ReservationModel(res)
                    self.reservationList.append(detail)
                }
                
            }else{
                self.reservationHistory.removeAll()
                self.reservationList = []
            }
            
            self.reservationTableView.reloadData()

        }) { (error) in
            
            
        }
    }
    
    func cancelReservationServic(_ id: String){
        
        let params = ["res_id":id]
        
        WebserviceController.cancelReservation(params, succesBlock: { (success, json) in
            
            CommonClass.stopLoader()
            if success{
                
                self.reservasionService()
                
            } else {
                
                AppDelegate.showToast(json["message"].stringValue)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
    }
}


//MARK:- TableView Delegate And datasource
//MARK:-  -------------------------------------------------------------------------------

extension ReservationVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.reservationList.isEmpty{
            
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
            emptyLabel.textColor = UIColor.gray
            emptyLabel.text = myAppconstantStrings.noReservation
            self.reservationTableView.backgroundView = emptyLabel
            self.reservationTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        }
        else{
            self.reservationTableView.backgroundView?.isHidden = true
        }
        return self.reservationList.count
    }

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let details = self.reservationList[indexPath.row]

        if !details.facilities.isEmpty{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReserveCellWithFacility", for: indexPath) as! ReserveCellWithFacility
            
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

            cell.facility = details.facilities

            cell.lotNameLbl.text = details.location
            
            cell.reservationNoLbl.text = "Reservation No :  \(details.reservation_no!)"

            cell.advancePaidLbl.text = "Advance Paid :  $\(details.amount!)"
            
            cell.durationlbl.text = "Duration :  \(details.duration!)hr"
            
            
            cell.reservationDate.text = "Reservation: \(CommonClass.covert_UTC_to_Local_WithTime(details.parking_date))"
            
            cell.expectedReturnLbl.text = "Expected Return: \(CommonClass.covert_UTC_to_Local_WithTime(details.reserved_until))"

            cell.catagoryLbl.text = "\(myAppconstantStrings.category) :    \(details.category!.capitalized)"
            
            
            cell.cancelBtn.addTarget(self, action: #selector(ReservationVC.cancelReservation(_:)), for: UIControlEvents.touchUpInside)
            cell.contactbtn.addTarget(self, action: #selector(ReservationVC.contactBtnTapped(_:)), for: UIControlEvents.touchUpInside)

            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReserveCell", for: indexPath) as! ReserveCell
            
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
            
            cell.lotNameLbl.text = details.location
            cell.reservationNoLbl.text = "Reservation No :  \(details.reservation_no!)"

            cell.advancePaidLbl.text = "Advance Paid :  $\(details.amount!)"
            
            cell.durationlbl.text = "Duration :  \(details.duration!)hr"
            
            
            cell.reservationDate.text = "Reservation: \(CommonClass.covert_UTC_to_Local_WithTime(details.parking_date))"
            
            cell.expectedReturnLbl.text = "Expected Return: \(CommonClass.covert_UTC_to_Local_WithTime(details.reserved_until))"
            
            cell.catagoryLbl.text = "\(myAppconstantStrings.category) :    \(details.category!.capitalized)"
            
            cell.cancelBtn.addTarget(self, action: #selector(ReservationVC.cancelReservation(_:)), for: UIControlEvents.touchUpInside)
            cell.contactbtn.addTarget(self, action: #selector(ReservationVC.contactBtnTapped(_:)), for: UIControlEvents.touchUpInside)

            return cell

        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let details = self.reservationList[indexPath.row]

        if !details.facilities.isEmpty{
            
            if details.is_agent{
                
                return 250 + CGFloat(details.facilities.count * 25) + 105

            }else{
                
                return 250 + CGFloat(details.facilities.count * 25)

            }

    }else{
            
            if details.is_agent{
                
                return 230 + 105

            }else{
                return 230

            }

        }
}

}

//MARK:- Reservation cell class
//MARK:-  -------------------------------------------------------------------------------

class ReserveCell: UITableViewCell{

    
//MARK:- OUTLETS
    //MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var agentImage: UIImageView!
    @IBOutlet weak var agentNameLbl: UILabel!
    @IBOutlet weak var agentContactLbl: UILabel!
    @IBOutlet weak var agentEmailLbl: UILabel!
    @IBOutlet weak var agentDetailviewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var contactbtn: UIButton!
    
    @IBOutlet weak var reservationNoLbl: UILabel!

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lotNameLbl: UILabel!
    @IBOutlet weak var advancePaidLbl: UILabel!
    @IBOutlet weak var durationlbl: UILabel!
    @IBOutlet weak var catagoryLbl: UILabel!
    @IBOutlet weak var reservationDate: UILabel!
    @IBOutlet weak var expectedReturnLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.lotNameLbl.text = ""
        self.advancePaidLbl.text = ""
        self.durationlbl.text = ""
        self.catagoryLbl.text = ""
        self.reservationDate.text = ""
        self.expectedReturnLbl.text = ""

    }
    
    func setLayout(){
        
        self.bgView.layer.cornerRadius = 2
        self.cancelBtn.layer.borderWidth = 1
        self.cancelBtn.layer.borderColor = UIColor.appBlue.cgColor
        self.cancelBtn.layer.cornerRadius = 3
        self.agentImage.layer.cornerRadius = 45/2
        self.agentImage.layer.borderColor = UIColor.appBlue.cgColor
        self.agentImage.layer.borderWidth = 1

    }
    
    
    
}

class ReserveCellWithFacility: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    var facility = [JSON]()
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var agentImage: UIImageView!
    @IBOutlet weak var agentNameLbl: UILabel!
    @IBOutlet weak var agentContactLbl: UILabel!
    @IBOutlet weak var agentEmailLbl: UILabel!
    @IBOutlet weak var agentDetailviewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var contactbtn: UIButton!
    @IBOutlet weak var reservationNoLbl: UILabel!

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lotNameLbl: UILabel!
    @IBOutlet weak var advancePaidLbl: UILabel!
    @IBOutlet weak var durationlbl: UILabel!
    @IBOutlet weak var catagoryLbl: UILabel!
    @IBOutlet weak var reservationDate: UILabel!
    @IBOutlet weak var expectedReturnLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var facilityTableView: UITableView!

    override func awakeFromNib() {
        
    
        super.awakeFromNib()
        
        self.setLayout()
        
        self.facilityTableView.register(UINib(nibName: "FacilityShowCell", bundle: nil), forCellReuseIdentifier: "FacilityShowCell")
        
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.lotNameLbl.text = ""
        self.advancePaidLbl.text = ""
        self.durationlbl.text = ""
        self.catagoryLbl.text = ""
        self.reservationDate.text = ""
        self.expectedReturnLbl.text = ""

    }


    func setLayout(){
        
        self.facilityTableView.delegate = self
        self.facilityTableView.dataSource = self
        self.bgView.layer.cornerRadius = 2
        self.cancelBtn.layer.borderWidth = 1
        self.cancelBtn.layer.borderColor = UIColor.appBlue.cgColor
        self.cancelBtn.layer.cornerRadius = 3
        self.agentImage.layer.cornerRadius = 45/2
        self.agentImage.layer.borderColor = UIColor.appBlue.cgColor
        self.agentImage.layer.borderWidth = 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.facility.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FacilityShowCell", for: indexPath) as! FacilityShowCell
        
        let detail = self.facility[indexPath.row]

        
        cell.facilityNameLbl.text = detail["facility"].stringValue
        
        let charge = detail["charge"].stringValue
        
        cell.facilityCharge.text = "$" + "\(charge)"
        
        cell.availedLbl.text =  detail["status"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 21
    }

}
