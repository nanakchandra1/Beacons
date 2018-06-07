//
//  ReceiptVC.swift
//  Parking Caddie
//
//  Created by Anuj on 5/19/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ReceiptState {
    case history,exit,none
}
class ReceiptVC: UIViewController {

//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------
    var receiptInfo :ReceiptModel!
    
    var receiptState:ReceiptState = .none
    var p_id: String?
    var noOfSec = 0
    
//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var receiptTableView: UITableView!
    
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationTitlelbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var latNameLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paidAmount: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var paidViaLbl: UILabel!
    @IBOutlet weak var paidViaValueLbl: UILabel!
    @IBOutlet weak var careCareServiceChargeLbl: UILabel!
    
 
    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.receiptTableView.estimatedRowHeight = 30
    
        self.receiptTableView.delegate = self
        self.receiptTableView.dataSource = self
        self.getPaymentReceiptDetail()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

//MARK:- IBActions
//MARK:-  -------------------------------------------------------------------------------

    @IBAction func onTapBackBtn(_ sender: UIButton) {
        
        if self.receiptState == ReceiptState.exit{
            CommonFunctions.gotoLandingPage()
//            let obj = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
//            //obj.state = "search"
//            obj.tabBarTempState = TabBarTempState.search
//            self.navigationController?.pushViewController(obj, animated: true)
        }
        else if self.receiptState == ReceiptState.history{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------
    
    
    func setDateFormat() -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = self.receiptInfo.parking_date
        let data = date?.components(separatedBy: "T")
        let dateformat = dateFormatter.date(from: data!.first!)
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let strTime = dateFormatter.string(from: dateformat!)
        return strTime
    }
    
    
    private func getPaymentReceiptDetail(){
    
        var params = JSONDictionary()
        
        params["parking_id"] = self.p_id ?? ""
        
        CommonClass.startLoader()
        WebserviceController.paymentReceiptAPI(params, succesBlock: { (success, json) in
            
            print_debug(json)
            self.receiptInfo = ReceiptModel(json["result"])

            self.noOfSec = 5
            self.receiptTableView.reloadData()
            
        }) { (error) in
            
        }
        
    }

}

//MARK:- TableView Delegate datasource methods
//MARK:- =====================================

extension ReceiptVC: UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.noOfSec

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if section == 3{
                
                return self.receiptInfo.facilities.count
                
            }else{
                
                return 1

            }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            
        case 0:
            
            return UITableViewAutomaticDimension

        case 1:
            
            return 105
            
        case 2:
            
            if self.receiptInfo.facilities.isEmpty{
                return 0

            }else{
                
                return UITableViewAutomaticDimension

            }


        case 3:
            if self.receiptInfo.facilities.isEmpty{
                return 0
                
            }else{
                return 43
                
            }

        case 4:
            
            return 121


        default:
            
            return 0

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            switch indexPath.section {
                
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptlotNameCell", for: indexPath) as! ReceiptlotNameCell
                cell.lotNameLbl.text = self.receiptInfo.location
                return cell

            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptlotCell", for: indexPath) as! ReceiptlotCell
                cell.populateData(data: self.receiptInfo)
                return cell

            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptAdditionalCell", for: indexPath) as! ReceiptAdditionalCell

                return cell

            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptAdditionalAmntCell", for: indexPath) as! ReceiptAdditionalAmntCell
                if !self.receiptInfo.facilities.isEmpty{
                    cell.populateData(data: self.receiptInfo.facilities[indexPath.row])

                }

                return cell

            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptAmountCell", for: indexPath) as! ReceiptAmountCell
                cell.populateData(data: self.receiptInfo)

                return cell

            default:
                fatalError("")
            }
    }
}


//MARK:- Cell Classess
//MARK:- =====================================

class ReceiptlotNameCell: UITableViewCell{
    
    @IBOutlet weak var lotNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ReceiptlotCell: UITableViewCell{

    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var reservationNoLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populateData(data: ReceiptModel){
        
        self.categoryLbl.text = data.category.capitalized
        self.reservationNoLbl.text = data.reservation_no

        self.durationLbl.text = data.duration + "hr"
        self.dateLbl.text = self.setDateFormat(data.parking_date)

    }

    func setDateFormat(_ p_data:String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = p_data
        let data = date.components(separatedBy: "T")
        let dateformat = dateFormatter.date(from: data.first!)
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let strTime = dateFormatter.string(from: dateformat!)
        return strTime
    }

}


class ReceiptAmountCell: UITableViewCell{
    
    @IBOutlet weak var paidAmount: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var paidViaValueLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populateData(data: ReceiptModel){
    
        self.paidAmount.text = "$" + data.paid
        
        self.remainingAmount.text = "$" + data.pending
        
        
        if data.payment_mode.lowercased() == "cash"{
            
            self.paidViaValueLbl.text = data.payment_mode
            
        }else if data.payment_mode == "N/A"{
            
            self.paidViaValueLbl.text = "N/A"

        }else{
            
            self.paidViaValueLbl.text = "Card"
        }

    }
}


class ReceiptAdditionalCell: UITableViewCell{
    
    @IBOutlet weak var additionalLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class ReceiptAdditionalAmntCell: UITableViewCell{
    
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populateData(data: ViewReceiptFacililiesModel){
        
        self.serviceNameLbl.text = data.facility + ":"
        
        self.valueLbl.text = "$" + data.charge

    }
}


