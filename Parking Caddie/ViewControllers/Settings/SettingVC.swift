//
//  SettingVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import MessageUI

class SettingVC: UIViewController {

//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------

    var client_token = ""
    var mailComposer : MFMailComposeViewController!
    var isFromEmail = false
    var contactus:String?

    
//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------
    
    
    @IBOutlet weak var settingTableview: UITableView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var seperatorview: UIView!
    
    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactus = "Support@LeslieApps.com"
        self.settingTableview.tableFooterView = UIView(frame: CGRect.zero)
    
        self.settingTableview.layer.cornerRadius = 3
        self.settingTableview.dataSource = self
        self.settingTableview.delegate = self
        self.settingTableview.separatorStyle = .none
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTapLogoutBtn(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Alert", message: myAppconstantStrings.logoutAlert, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            alertAction in self.logOutWebService()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------
    
    func logOutWebService(){
        
        CommonClass.startLoader()
        
        
        WebserviceController.logOutService({ (success, json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                AppDelegate.showToast(json["message"].stringValue)
                
                timeCount = 0.0
                progressValue = 0
                
                UserDefaults.clearUserDefaults()
                 CommonFunctions.gotoLoginPage()
                
            } else {
                
                AppDelegate.showToast(json["message"].stringValue)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
        
    }
        
    
    
    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
}





//MARK:- TableView datasoure and Delegate
//MARK:-  -------------------------------------------------------------------------------

extension SettingVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        
        switch indexPath.row{
        case 0:
            cell.settingNameLbl.text = "Payment Methods"
            cell.seperatorView.isHidden = false
            return cell
        case 1:
            cell.settingNameLbl.text = "Invite Friends"
            cell.seperatorView.isHidden = false
            return cell
        case 2:
            cell.settingNameLbl.text = "Change Password"
            cell.seperatorView.isHidden = false
            return cell
        case 3:
            cell.settingNameLbl.text = "About"
            cell.seperatorView.isHidden = false
            return cell
        case 4:
            cell.settingNameLbl.text = "Terms of Service"
            cell.seperatorView.isHidden = false
            return cell
        case 5:
            cell.settingNameLbl.text = "Privacy Policy"
            cell.seperatorView.isHidden = false
            return cell
        case 6:
            cell.settingNameLbl.text = "Refund Policy"
            cell.seperatorView.isHidden = false
            return cell
        case 7:
            cell.settingNameLbl.text = "Rate The App"
            cell.seperatorView.isHidden = false
            return cell
        case 8:
            cell.settingNameLbl.text = "Promotions"
            cell.seperatorView.isHidden = false
            return cell

        case 9:
            cell.settingNameLbl.text = "Contact Us"
            cell.seperatorView.isHidden = true
            return cell
        default:
            fatalError("SettingVC cell for row")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row{

        case 0:
            
//            let obj = mainStoryboard.instantiateViewController(withIdentifier: "ChangeDefaultPasswordPopupVC") as! ChangeDefaultPasswordPopupVC
//             obj.modalPresentationStyle = .overCurrentContext
//            APPDELEGATEOBJECT.parentNavigationController.present(obj, animated: true, completion: nil)
            //self.updateCard()
            
            let obj = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentMethodsVC") as! PaymentMethodsVC
           // obj.modalPresentationStyle = .overCurrentContext
            APPDELEGATEOBJECT.parentNavigationController.pushViewController(obj, animated: true)
            
        case 1:
            
            self.displayShareSheet("http://prod.parkingcaddie.com/")
            
            
        case 2:
            
            let obj = settingsStoryboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
            self.addSubviews(obj)

        case 3:
            let obj = settingsStoryboard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.str = "ABOUT"
            obj.termsConditiond = TermsConditionState.settings
            obj.action = "about-us"
            self.addSubviews(obj)
            
            
        case 4:
            let obj = settingsStoryboard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.str = "TERMS OF SERVICE"
            obj.termsConditiond = TermsConditionState.settings
            obj.action = "term-and-condition"
            self.addSubviews(obj)

            
        case 5:
            let obj = settingsStoryboard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.str = "PRIVACY POLICY"
            obj.termsConditiond = TermsConditionState.settings
            obj.action = "privacy-policy"
            self.addSubviews(obj)
            
        case 6:
            
            let obj = settingsStoryboard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.str = "REFUND POLICY"
            obj.termsConditiond = TermsConditionState.settings
            obj.action = "refund-policy"
            self.addSubviews(obj)

            
        case 7:
            
            let url  = URL(string: "itms-apps:https://itunes.apple.com/app/bars/id706081574?mt=8")
            if UIApplication.shared.canOpenURL(url!) == true  {
                UIApplication.shared.openURL(url!)
            }
            
        case 8:
            
            let obj = settingsStoryboard.instantiateViewController(withIdentifier: "PromotionsVC") as! PromotionsVC
            
            self.addSubviews(obj)
            
        case 9:
            let mailComposeViewController = self.configuredMailComposeViewController()
            
            if MFMailComposeViewController.canSendMail() {
                
                self.present(mailComposeViewController, animated: true, completion: nil)
            }

        default:
            fatalError("settingvc didselect")
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
        
    }
    
    
    func addSubviews(_ viewcontroller: UIViewController){
    
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
            
            self.view.addSubview(viewcontroller.view)
            self.addChildViewController(viewcontroller)
            viewcontroller.willMove(toParentViewController: self)
        })

    }
}


extension SettingVC: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    // MARK: MFMailComposeViewControllerDelegate Method
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        navigationController?.navigationBar.isHidden = true
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        if self.contactus != nil{
            mailComposerVC.setToRecipients([self.contactus!])
            mailComposerVC.setSubject("")
            mailComposerVC.setMessageBody("", isHTML: false)
        }
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
}





//MARK:- TableView Cell class
//MARK:-  -------------------------------------------------------------------------------

class SettingsCell: UITableViewCell {
    
    //MARK:- Outlets
    //MARK:-
    @IBOutlet weak var settingNameLbl: UILabel!
    @IBOutlet weak var forwordBtn: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}





