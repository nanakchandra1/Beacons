//
//  NotificationVC.swift
//  Parking Caddie
//
//  Created by Anuj on 5/19/16.
//  Copyright © 2016 Appinventiv. All rights reserved.

import UIKit

class NotificationVC: UIViewController {
    
//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------
    
    var notifications = [NotificationModel]()
    var refreshControl:UIRefreshControl!


//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------

    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var notificationTableView: UITableView!
    
    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupSubViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
//MARK:- IBActions
//MARK:-  -------------------------------------------------------------------------------
   
    
    @IBAction func onTapBackButton(_ sender: UIButton) {
        let principalScene = tabbarStoryboard.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
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
    
    
    private func setupSubViews(){
    
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: " ")
        
        self.refreshControl.addTarget(self, action: #selector(NotificationVC.refresh), for: UIControlEvents.valueChanged)
        
        self.notificationTableView!.addSubview(refreshControl)
        
        if APPDELEGATEOBJECT.pushCount == 0{
            
            self.countLbl.isHidden = true
        }
        
        if self.notifications.count != 0{
            
            self.countLbl.isHidden = false
            
            self.countLbl.text = "\(APPDELEGATEOBJECT.pushCount)"
        }
        
        if APPDELEGATEOBJECT.pushCount != 0{
            
            self.countLbl.isHidden = false
            
            self.countLbl.text = "\(APPDELEGATEOBJECT.pushCount)"
        }
        
        APPDELEGATEOBJECT.pushCount = 0
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        self.notificationTableView.delegate = self
        
        self.notificationTableView.dataSource = self
        
        self.countLbl.layer.cornerRadius = self.countLbl.frame.width / 2
        
        self.countLbl.layer.masksToBounds = true

        self.getNotification()

    }
    
   private func getNotification(){
        
        WebserviceController.notificationService( { (success, json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].arrayValue
                
                self.notifications = result.map({ (savedCard) -> NotificationModel in
                    
                    NotificationModel.init(with: savedCard)
                })

                self.notificationTableView.reloadData()
                self.refreshControl.endRefreshing()

            }else{
            
                self.notifications = []
                showNodata(self.notifications, tableView: self.notificationTableView, msg: "No Notification.", color: .black)

            }
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
    }
    
    
   @objc private func refresh() {
        
        self.getNotification()
        
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


extension NotificationVC: UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let data = self.notifications[indexPath.row]
        cell.msgLbl.text = data.message
        let date = data.date_created
        cell.dateLbl.text = date?.convertTimeWithTimeZone(formate: DateFormate.dateWithTime)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let data = self.notifications[indexPath.row]
        
        let title = data.message.boundingRect(with: CGSize(width: screenWidth-30, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "Avenir-Light", size: 14)!], context: nil)
        
        let date = data.date_created.convertTimeWithTimeZone(formate: DateFormate.dateWithTime)
        
        let desc = date.boundingRect(with: CGSize(width: screenWidth-30, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: "Avenir-Light", size: 10)!], context: nil)
        
        let textHeight = title.height + desc.height
        return textHeight + 35
    }
}


//MARK:- Table view cell class
//MARK:-  -------------------------------------------------------------------------------


class NotificationCell:UITableViewCell{

    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
