//
//  NotificationVC.swift
//  Parking Caddie
//
//  Created by Anuj on 5/19/16.
//  Copyright © 2016 Appinventiv. All rights reserved.

import UIKit
import UserNotifications

class PromotionsVC: UIViewController {
    
//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------
   
    var promotions = [PromotionsModel]()
    var refreshControl:UIRefreshControl!

 
//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------

    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var promotionsTableView: UITableView!
        
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setUpSubviews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
//MARK:- IBActions
//MARK:-  -------------------------------------------------------------------------------
    
    @IBAction func onTapBackButton(_ sender: UIButton) {
        
        let principalScene = tabbarStoryboard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        
        self.view.addSubview(principalScene.view)
        
        self.addChildViewController(principalScene)
        
        principalScene.willMove(toParentViewController: self)
        
        for childVC in self.childViewControllers {
            
            if childVC === principalScene {
                
            } else {
                
                childVC.view.removeFromSuperview()
                
                childVC.removeFromParentViewController()
            }
        }
    }
    
    
    
    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------
    
    private func setUpSubviews(){
    
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: " ")
        
        self.refreshControl.addTarget(self, action: #selector(PromotionsVC.refresh), for: UIControlEvents.valueChanged)
        
        self.promotionsTableView!.addSubview(refreshControl)
        
        if APPDELEGATEOBJECT.pushCount == 0{
            
            self.countLbl.isHidden = true
        }
        
        if self.promotions.count != 0{
            
            self.countLbl.isHidden = false
            
            self.countLbl.text = "\(APPDELEGATEOBJECT.pushCount)"
        }
        
        if APPDELEGATEOBJECT.pushCount != 0{
            
            self.countLbl.isHidden = false
            
            self.countLbl.text = "\(APPDELEGATEOBJECT.pushCount)"
        }
        
        APPDELEGATEOBJECT.pushCount = 0
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        self.promotionsTableView.delegate = self
        
        self.promotionsTableView.dataSource = self
        
        self.countLbl.layer.cornerRadius = self.countLbl.frame.width / 2
        
        self.countLbl.layer.masksToBounds = true

        self.getPromotions()

    }
    
   private func getPromotions(){
        
        WebserviceController.promotionsService( { (success, json) in
            
            CommonClass.stopLoader()
            if success{
                
                let result = json["result"].arrayValue
                
                self.promotions = result.map({ (promotion) -> PromotionsModel in
                    
                    PromotionsModel.init(with: promotion)
                })
                self.promotionsTableView.reloadData()
                self.refreshControl.endRefreshing()
                
                
            }else{
            
                self.promotions = []
                showNodata(self.promotions, tableView: self.promotionsTableView, msg: "No Promotions.", color: .black)

            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })

    }
    
    
    func refresh() {
    
        self.getPromotions()
    
        if APPDELEGATEOBJECT.pushCount == 0{
            
            self.countLbl.isHidden = true
            
        }
    
        if APPDELEGATEOBJECT.pushCount != 0{
            
            self.countLbl.isHidden = false
            
            self.countLbl.text = "\(APPDELEGATEOBJECT.pushCount)"
            
            APPDELEGATEOBJECT.pushCount = 0
            
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
    }
    
}


//MARK:- Tableviewdelegate and datasource
//MARK:-  -------------------------------------------------------------------------------


extension PromotionsVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.promotions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionsCell", for: indexPath) as! PromotionsCell
        
        let data = self.promotions[indexPath.row]

        cell.msgLbl.text = data.message
        
        if let promo = data.coupon_code{
            
            cell.promoCodeLbl.text = "Promocode: " + promo
            
        }else{
            
            cell.promoCodeLbl.text = "No Promocode"
        }
        
        cell.dateLbl.text = data.date_created.convertTimeWithTimeZone(formate: DateFormate.dateWithTime)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var title = CGRect()
        var prom = CGRect()
        var desc = CGRect()

        let data = self.promotions[indexPath.row]

        let date = data.date_created
        let message = data.message
        let coupons = data.coupon_code
        
        title = message!.boundingRect(with: CGSize(width: screenWidth-30, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "Avenir-Light", size: 14)!], context: nil)
        
         prom = coupons!.boundingRect(with: CGSize(width: screenWidth-30, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "Avenir-Light", size: 14)!], context: nil)
        

         desc = date!.boundingRect(with: CGSize(width: screenWidth-30, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "Avenir-Light", size: 10)!], context: nil)
        
        if let _ = data.coupon_code{

            let textHeight = title.height + desc.height + prom.height
            
            return textHeight + 35
            
        }else{
            
            let textHeight = title.height + desc.height

            return textHeight + 50
            
        }
    }
}


//MARK:- Table view cell class
//MARK:-  -------------------------------------------------------------------------------


class PromotionsCell:UITableViewCell{
    
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var promoCodeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
