//
//  UpdateMobileVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

protocol getMobileDelegate{
    
    func getMobile(_ code:String!,mobile:String!)
    
}


class UpdateMobileVC: UIViewController, UITextFieldDelegate ,ShowCodeDetailDelegate{
    
    //MARK:- Properties
    //MARK:- ******************************************************
    
    var delegate:getMobileDelegate!
    var buttonState = 0
    var dataDict = JSONDictionary()
    
    
    //MARK:- OUTLETS
    //MARK:- ******************************************************
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var updateMobileLbl: UILabel!
    @IBOutlet weak var showMassegeLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var countryCodeTextfield: UITextField!
    @IBOutlet weak var dashView: UIView!
    @IBOutlet weak var upgradeBtn: UIButton!
    @IBOutlet weak var mobileLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var horizontalConstraint: NSLayoutConstraint!
    //OTP View Delegate
    @IBOutlet weak var otpBgView: UIView!
    @IBOutlet weak var otpSymbolImg: UIImageView!
    @IBOutlet weak var mobileNoTextField: UITextField!
    @IBOutlet weak var showMsgLbl: UILabel!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var resendOtpBtn: UIButton!
    @IBOutlet weak var proceedOtpBtn: UIButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpViewTopConstraint: NSLayoutConstraint!
    
    
    
    //MARK:- View Life Cycle
    //MARK:- ******************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.countryCodeTextfield.isEnabled = true
    }
    
    
    
    
    //MARK:- Methods
    //MARK:- ******************************************************
    
    fileprivate func setUpSubViews(){
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        self.mobileTextField.text = CurrentUser.userPhone!
        self.countryCodeTextfield.text = CurrentUser.userCode!
        self.upgradeBtn.isUserInteractionEnabled = false
        self.bgView.layer.cornerRadius = 5
        self.otpViewTopConstraint.constant = -185
        self.otpBgView.isHidden = true
        self.mobileLeadingConstraint.constant = -67
        self.countryCodeTextfield.isHidden = true
        self.dashView.isHidden = true
        self.mobileTextField.isEnabled = false
        self.mobileTextField.delegate = self
        self.countryCodeTextfield.delegate = self
        self.otpTextField.delegate = self
        self.mobileTextField.keyboardType = UIKeyboardType.numberPad
        self.mobileTextField.returnKeyType = UIReturnKeyType.done
        
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateMobileVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateMobileVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // dismiss keybord method
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.mobileTextField.endEditing(true)
        self.otpTextField.endEditing(true)
        self.otpViewTopConstraint.constant = -185
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
        }, completion: { (Bool) -> Void in
            if self.view != self.otpBgView{
                self.otpBgView.isHidden = true
            }
        }) 
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.horizontalConstraint.constant = -80
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.horizontalConstraint.constant = 0
        }
    }
    
    
    
    //OTP Confirm webservice
    
    func otpConfirmWebservice(){
        if self.otpTextField.text!.characters.count == 0{
            AppDelegate.showToast(myAppconstantStrings.enterOtp)
        }
            
        else{
            
            var params = JSONDictionary()
            params["action"] = "email"
            params["email"] = CurrentUser.userEmail
            params["otp"] = self.otpTextField.text

            
            WebserviceController.loginScreenOtpConfirm(params, succesBlock: { (success, json) in
                
                let msg = json["message"].string ?? ""

                if success{
                
                    let userDetail = UserData(withJson: json["result"])
                    
                    self.otpViewTopConstraint.constant = -185
                    
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        
                        self.view.layoutIfNeeded()
                        
                    }, completion: { (Bool) -> Void in
                        
                        self.bgView.isHidden = true
                        self.delegate.getMobile(self.countryCodeTextfield.text!, mobile: self.mobileTextField.text!)
                        parkingSharedInstance.upgrade = 1
                        self.navigationController?.popViewController(animated: true)
                    })
                }else{
                    
                    AppDelegate.showToast(msg)

                }
                
            }, failureBlock: { (error) in
                
            })
            
        }
        
    }
    
    
    //Get country code
    
    func getCountryCode(_ code: String!, countryName: String!, max_NSN_Length: Int!, min_NSN_Length: Int!) {
        
        if let code = code{
            
            self.countryCodeTextfield.text  = code
            
            self.dataDict["max"] = max_NSN_Length
            
            self.dataDict["min"] = min_NSN_Length
            
            self.dataDict["country"] = countryName 
        }
        
    }
    
    
    // Validation
    
    func validateInfo(_ textField :UITextField,string : String,range:NSRange) -> Bool {
        
        
        if range.length == 1 {
            return true
        }
        
        
        if let text = textField.text {
            
            if text.characters.count  > self.dataDict["max"]! as! Int {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    
    
    
    
    
    //MARK:- Button Actions
    //MARK:- ******************************************************
    
    // Back button
    
    @IBAction func onTapBackBtn(_ sender: UIButton) {
        
        
        if buttonState == 1{
            
            let alert = UIAlertController(title: "Alert", message: myAppconstantStrings.updateMobileAlert, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {
                alertAction in self.ifNo()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
            
        else{
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func ifNo(){
        self.navigationController?.popViewController(animated: true)
    }
    
    // Edit mobile button
    
    @IBAction func onTapEditButton(_ sender: UIButton) {
        self.buttonState = 1
        self.upgradeBtn.isUserInteractionEnabled = true
        self.mobileLeadingConstraint.constant = 10
        self.mobileTextField.text = CurrentUser.userPhone
        self.countryCodeTextfield.isHidden = false
        self.dashView.isHidden = false
        self.countryCodeTextfield.isEnabled = true
        self.mobileTextField.isEnabled = true
        self.editBtn.isHidden = true
        
    }
    
    //uprade mobile button
    
    @IBAction func onTapUpgrade(_ sender: AnyObject) {
        
        guard let code = self.countryCodeTextfield.text, code.characters.count > 0 else{
            
            AppDelegate.showToast(myAppconstantStrings.enterCode)
            
            return
        }
        guard let mobile = self.mobileTextField.text, mobile.characters.count > 0 else{
            
            AppDelegate.showToast(myAppconstantStrings.entermobile)
            return
        }
        
        var params = JSONDictionary()
        
                params["action"] = "mobile"
                params["mobile"] = code + mobile
                params["country_code"] = code
                params["phone_no"] = mobile
        
        CommonClass.startLoader()

        WebserviceController.editProfile(params, image: nil, isImageAvailable: false, succesBlock: { (success, json) in
            
            let message = json["message"].string ?? ""

            if success{
            
                self.mobileNoTextField.text = self.countryCodeTextfield.text! + self.mobileTextField.text!
                CommonClass.stopLoader()
                self.otpViewTopConstraint.constant = 20
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.otpBgView.isHidden = false
                    self.otpTextField.becomeFirstResponder()
                })

                
            }else{
            
                AppDelegate.showToast(message)

            }
            
        }) { (error) in
            
        }
        
    }
    
    
    //resend otp button
    
    @IBAction func onTapResendOtp(_ sender: UIButton) {
        
        CommonClass.startLoader()
        
        var params = JSONDictionary()
        
        if CurrentUser.userStatus == 0{
            
            params["action"] = "email"
            params["email"] = CurrentUser.userEmail
        }
        else{
            
            params["action"] = "mobile"
            params["country_code"] = self.dataDict["code"]!
            params["phone_no"] = self.mobileTextField.text
            params["mobile"] = self.countryCodeTextfield.text! + self.mobileTextField.text!
        }
        
        
        WebserviceController.resendOTP(params, succesBlock: { (success, json) in
            
            let message = json["message"].string ?? ""
            AppDelegate.showToast(message)

        }) { (error) in
            
        }
        
    }
    
    
    // otp confirmation button
    
    @IBAction func onTapProceedOtp(_ sender: UIButton) {
        if self.otpTextField.text?.characters.count == 0{
            AppDelegate.showToast(myAppconstantStrings.enterOtp)
        }
        else{
            otpConfirmWebservice()
        }
    }
    
    
    
    
    
    
    
    
    //MARK:- Text field delegete
    //MARK:- ******************************************************************
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let y = textField.frame.origin.y
        if (y >= self.view.bounds.size.height/2 - 20) 
        {
            var frame = self.view.frame
            frame.origin.y = self.view.bounds.size.height/2 - 50 - textField.frame.origin.y
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.frame = frame
            })
        }
        
        
        if textField == self.countryCodeTextfield{
            self.countryCodeTextfield.isEnabled = false
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "ShowCodeDetailVC") as! ShowCodeDetailVC
            obj.delegate = self
            
            if let code = self.dataDict["code"] as? String{
                obj.codeStr = code
                obj.countryNameStr = self.dataDict["country"] as! String
                obj.Max_NSN = self.dataDict["max"] as! Int
                obj.Min_NSN = self.dataDict["min"] as! Int
            }
            self.navigationController?.present(obj, animated: true, completion: nil)
        }
        else{
            self.countryCodeTextfield.isEnabled = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var returnframe = self.view.frame
        returnframe.origin.y = 0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = returnframe
        })
    }
}
