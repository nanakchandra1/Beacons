//
//  ViewController.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import BraintreeDropIn
import Braintree


enum ForgotEditCodeState{
    case edit,forgot,none
}




class LoginVC: UIViewController {
    
    //MARK:- properties
    //MARK:- ************************************
    
    var isEdit = true
    var forgotEditState = ForgotEditCodeState.none
    var loginResult = UserData()
    var userInfoDict = JSONDictionary()
    var braintreeClient:BTAPIClient!
    
    
    //MARK:- login screen Outlets
    //MARK:- ************************************
    
    @IBOutlet weak var editmobileLeadingConstant: NSLayoutConstraint!
    @IBOutlet weak var editMobileCodetext: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginLbl: UILabel!
    @IBOutlet weak var loginBgView: UIView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var usernameSaperator: UIView!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var passSaperator: UIView!
    @IBOutlet weak var forgotPassBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createNewAcBtn: UIButton!
    @IBOutlet weak var forgotPassBgView: UIView!
    
    //Forgot password screen outlets
    
    @IBOutlet weak var forgotPassView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var forgotPassImage: UIImageView!
    @IBOutlet weak var forgotPassLbl: UILabel!
    @IBOutlet weak var resetemailLbl: UILabel!
    @IBOutlet weak var mobileTextfield: UITextField!
    @IBOutlet weak var forgotPassView_y_contraint: NSLayoutConstraint!
    @IBOutlet weak var forgotMobileCodeField: UITextField!
    @IBOutlet weak var mobileSubmitBtn: UIButton!
    
    //OTP password screen outlets
    
    @IBOutlet weak var otpBgView: UIView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpImage: UIImageView!
    // @IBOutlet weak var mobileLbl: UILabel!
    
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var otpSeperator: UIView!
    @IBOutlet weak var popUpTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var resendOTPBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mobileEditBtn: UIButton!
    
    
//MARK:- view life cycle
//MARK:- ************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- functions
    //MARK:- ************************************
    
    fileprivate func setUpSubviews(){
        self.forgotPassView.layer.cornerRadius =  2
        self.forgotMobileCodeField.delegate = self
        self.editMobileCodetext.delegate = self
        self.editmobileLeadingConstant.constant = -40
        self.editMobileCodetext.isHidden = true
        self.mobileTF.delegate = self
        self.mobileTF.isUserInteractionEnabled = false
        self.mobileTextfield.delegate = self
        self.userNameTextField.delegate = self
        self.passwordTextField.delegate  = self
        self.otpTextField.delegate = self
        self.userNameTextField.autocorrectionType = .no
        self.userNameTextField.adjustsFontSizeToFitWidth = true
        self.userNameTextField.keyboardType = UIKeyboardType.emailAddress
        self.passwordTextField.keyboardType = UIKeyboardType.alphabet
        self.mobileTextfield.keyboardType = UIKeyboardType.phonePad
        self.mobileSubmitBtn.layer.cornerRadius = 3
        self.loginBtn.layer.cornerRadius =  3
        self.loginBgView.layer.cornerRadius = 3
        self.loginBgView.layer.shadowRadius = 5
        self.loginBgView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.loginBgView.layer.shadowOpacity = 0.8
        self.loginBgView.layer.shadowColor = UIColor.lightGray.cgColor
        self.userNameTextField.returnKeyType = UIReturnKeyType.next
        self.passwordTextField.returnKeyType = UIReturnKeyType.done
        self.mobileTextfield.returnKeyType = UIReturnKeyType.done
        self.otpTextField.returnKeyType = UIReturnKeyType.done
        self.cancelBtn.layer.cornerRadius = self.cancelBtn.bounds.width / 2
        self.popUpTopConstraint.constant = -185
        self.forgotPassBgView.isHidden  = true
        self.otpBgView.isHidden = true

    }
    
    
    //hide keybord
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let view = touches.first?.view {
                if view == self.forgotPassBgView && !self.forgotPassBgView.subviews.contains(view) {
                    self.forgotPassBgView.isHidden = true
                }
            }
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.mobileTextfield.resignFirstResponder()
        self.otpTextField.resignFirstResponder()
    }
    
    //login web service
    
    func loginWebservice(){
        
        guard let email = self.userNameTextField.text, email.characters.count > 0 && CommonClass.isValidEmail(email) else{
            AppDelegate.showToast(myAppconstantStrings.emptyUserName)
            return
        }
        guard let pass = self.passwordTextField.text, pass.characters.count > 0   else{
            AppDelegate.showToast(myAppconstantStrings.enterPass)
            return
        }
        guard pass.characters.count >= 8 && pass.characters.count <= 32 else{
            AppDelegate.showToast(myAppconstantStrings.passLength)
            return
        }
            var params = JSONDictionary()
        
            params["email"] = self.userNameTextField.text
            params["password"] = self.passwordTextField.text
            params["device_id"] = UIDevice.current.identifierForVendor!.uuidString
            params["platform"] = "iOS"
            params["os_version"] = UIDevice.current.systemVersion
        
        if APPDELEGATEOBJECT.device_Token != nil{
            
            params["device_token"] = APPDELEGATEOBJECT.device_Token
            params["device_model"] = UIDevice.current.model
            
        }

        CommonClass.startLoader()
        WebserviceController.loginAPI(params, succesBlock: { (success, json) in
            
            let msg = json["message"].string ?? ""
            if success{
            
                self.loginResult = UserData(withJson: json["result"])
                self.userInfoDict["code"]  = self.loginResult.country_code
                self.userInfoDict["mobile"]  = self.loginResult.phone_no
                
                if self.loginResult.is_mobile_verified ?? 100 == 0{
                
                    self.passwordTextField.resignFirstResponder()
                    self.userNameTextField.resignFirstResponder()
                    self.otpTextField.becomeFirstResponder()
                    self.mobileTF.text = self.loginResult.mobile
                    
                    self.popUpTopConstraint.constant = 20
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                        self.otpBgView.isHidden = false
                        self.forgotPassBgView.isHidden  = true
                    })
                    
                }else{
                
                    self.ckeckingParkingStatus()

                }
                
            }else{
                
                AppDelegate.showToast(msg)

            }
            
        }) { (error) in
            
            AppDelegate.showToast("Server Error")

        }
        
    }
    
    
  // Check parking Status before navigate landing page
    
    func ckeckingParkingStatus(){
        
        WebserviceController.checkParkingStatus({ (success, json) in
            
            if success{
            
                let result = json["result"].dictionary ?? [:]
                
                let parkingDetail = result["parking"]?.dictionary ?? [:]
                
                let p_catagory = parkingDetail["category"]?.string ?? ""
                
                userDefaults.set(p_catagory, forKey: NSUserDefaultsKeys.CATAGORY)

                let tabbarVC = tabbarStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC

                if p_catagory.lowercased() == parkingCatagories.economy || p_catagory.lowercased() == parkingCatagories.business{
                    
                    userDefaults.set(parkingState.normal, forKey: NSUserDefaultsKeys.PARKING_STAUS)

                    tabbarVC.tabBarTempState = TabBarTempState.timer
                    
                    tabbarVC.timerScreeState = TimerScreenState.normal
                    
                }else{
                
                    userDefaults.set(parkingState.valet, forKey: NSUserDefaultsKeys.PARKING_STAUS)
                    
                    tabbarVC.tabBarTempState = TabBarTempState.timer
                    
                    tabbarVC.timerScreeState = TimerScreenState.valet
                    
                }
                
                APPDELEGATEOBJECT.parentNavigationController  = UINavigationController(rootViewController: tabbarVC)
                APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
                APPDELEGATEOBJECT.window?.makeKeyAndVisible()
                APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true

                
            }else{
            
                if json["code"].intValue == 225 {
                
                    CommonFunctions.gotoLandingPage()
                }
            }
            
        }) { (error) in
            
        }
    }
    
    
    //Send OTP web service
    
    func sendOtpWebService(){
        
        self.createNewAcBtn.setTitle("Create New Account?", for: UIControlState())
        guard let code = self.forgotMobileCodeField.text, code.characters.count > 0 else{
            AppDelegate.showToast(myAppconstantStrings.enterCode)
            CommonClass.stopLoader()
            return
        }
        guard let mobile = self.mobileTextfield.text, mobile.characters.count > 0 else{
            AppDelegate.showToast(myAppconstantStrings.entermobile)
            CommonClass.stopLoader()
            return
        }
            CommonClass.startLoader()
            let mobileWithCode = "\(self.userInfoDict["code"]!)" + "\(self.userInfoDict["mobile"]!)"
        
        
        var params = JSONDictionary()
        params["mobile"] = mobileWithCode
        params["mobile"] = self.userInfoDict["code"]
        params["mobile"] = self.userInfoDict["mobile"]

        
        WebserviceController.forgotPassword(params, succesBlock: { (success, json) in
            
            let msg = json["message"].stringValue
            
            AppDelegate.showToast(msg)
            
            if success{
            
                self.mobileTF.text = mobileWithCode
                self.popUpTopConstraint.constant = 20
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.otpBgView.isHidden = false
                    self.otpTextField.becomeFirstResponder()
                    self.forgotPassBgView.isHidden  = true
                })

            }
            
        }) { (error) in
            
            
        }
        
    }
    
    
    // OTP confirm web service
    func otpconfirmwebService(){
        
        guard let otp = self.otpTextField.text, otp.characters.count > 1 else{
            AppDelegate.showToast(myAppconstantStrings.enterOtp)
            return
        }
        guard let is_mobile_verified = self.loginResult.is_mobile_verified else{return}
        
            var params = JSONDictionary()
        
            if is_mobile_verified == 0{
                
                params["action"] = "email"
                params["email"] = CurrentUser.userEmail
                params["otp"] = self.otpTextField.text

            }
            else{
                let mobileWithCode = "\(self.userInfoDict["code"]!)" + "\(self.userInfoDict["mobile"]!)"
                
                params["action"] = "mobile"
                params["mobile"] = mobileWithCode
                params["country_code"] = self.userInfoDict["code"]
                params["phone_no"] = self.userInfoDict["mobile"]
                params["otp"] = self.otpTextField.text
            }
        
        WebserviceController.loginScreenOtpConfirm(params, succesBlock: { (success, json) in
            
            if success{
                
                if is_mobile_verified == 0{
                
                    CommonFunctions.gotoLandingPage()
                    self.ckeckingParkingStatus()
                }else{
                    
                    let result = json["result"].dictionary ?? [:]

                    let obj = settingsStoryboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
                    obj.mobile = result["mobile"]?.string ?? ""
                    self.navigationController?.pushViewController(obj, animated: true)

                }

            }
            
        }) { (error) in
            
            
        }
    }
    
    
    
    //MARK:-  Button Action
    //MARK:- ************************************
    
    // show password
    
    @IBAction func showPassTapp(_ sender: UIButton) {
        
        if !sender.isSelected{
            self.passwordTextField.isSecureTextEntry = false
            self.showPassBtn.setImage(UIImage(named: "active_password_eye"), for: UIControlState())
            sender.isSelected = !sender.isSelected
        }
        else{
            self.passwordTextField.isSecureTextEntry = true
            self.showPassBtn.setImage(UIImage(named: "password_eye"), for: UIControlState())
            
            sender.isSelected = !sender.isSelected
        }
    }
    
    
    //show forgot pass view
    
    @IBAction func forgotPassTapp(_ sender: AnyObject) {
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
            
            self.forgotEditState = ForgotEditCodeState.forgot
            self.forgotPassBgView.isHidden = false
            self.createNewAcBtn.setTitle("forgot Password ?", for: UIControlState())
        }) 
    }
    
    
    
    // login confirm
    
    @IBAction func loginBtnTapp(_ sender: AnyObject) {
        
        self.loginWebservice()
        
    }
    
    
    
    // navigate to signup screen
    
    @IBAction func createNewAcTapp(_ sender: AnyObject){
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        APPDELEGATEOBJECT.parentNavigationController  = UINavigationController(rootViewController: signUpVC)
        APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
        APPDELEGATEOBJECT.window?.makeKeyAndVisible()
        APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true
    }
    
    
    // cancel or hide forgot password view
    
    @IBAction func onTapCancel(_ sender: AnyObject) {
        self.createNewAcBtn.setTitle("Create New Account?", for: UIControlState())
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.layoutIfNeeded()

        }, completion: { (Bool) -> Void in
            self.forgotPassBgView.isHidden = true
        }) 
    }
    
    
    // submit mobile number
    
    @IBAction func submitMobile(_ sender: AnyObject) {
        
        self.mobileTextfield.endEditing(true)
        CommonClass.startLoader()
        self.mobileEditBtn.isHidden = true
        sendOtpWebService()
    }
    
    // confirm otp
    
    @IBAction func otpConfirmbtn(_ sender: AnyObject) {
        self.otpTextField.endEditing(true)
        
        CommonClass.startLoader()
        
        otpconfirmwebService()
    }
    
    
    
    // resend otp
    
    @IBAction func onTapResendOTP(_ sender: UIButton) {
        
        CommonClass.startLoader()
        
        let mobileWithCode = "\(self.userInfoDict["code"]!)" + "\(self.userInfoDict["mobile"]!)"
        
        var params = JSONDictionary()
        
        if self.loginResult.is_mobile_verified == 0{
            
            params["action"] = "email"
            
            params["email"] = self.loginResult.email
            
        }
        else{
            params["action"] = "mobile"
            
            params["mobile"] = mobileWithCode
            
            params["country_code"] = self.userInfoDict["code"]
            
            params["phone_no"] = self.userInfoDict["mobile"]
        }
        
        WebserviceController.resendOTP(params, succesBlock: { (success, json) in
            
            
            let message = json["message"].string ?? ""
            
            AppDelegate.showToast(message)


        }) { (error) in
            
        }
    }
    
    
    @IBAction func onTapOtpCancel(_ sender: AnyObject) {
        self.popUpTopConstraint.constant = -185
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
        }, completion: { (Bool) -> Void in
            self.otpBgView.isHidden = true
        }) 
    }
  
    
    //edit mobile
    
    @IBAction func onTapMobileEdit(_ sender: UIButton) {
        
        if isEdit{
            self.editmobileLeadingConstant.constant = 0
            self.editMobileCodetext.isHidden = false
            self.mobileTF.isUserInteractionEnabled = true
            self.forgotEditState = ForgotEditCodeState.edit
            self.mobileEditBtn.setImage(UIImage(named: "profile_edit_tick"), for: UIControlState())
            self.mobileTF.text = ""
            self.editMobileCodetext.text = ""
            isEdit = !isEdit
            
        }
        else{
            self.editmobileLeadingConstant.constant = -40
            self.editMobileCodetext.isHidden = true
            self.mobileTF.isUserInteractionEnabled = false
            self.mobileEditBtn.setImage(UIImage(named: "profile_editpen"), for: UIControlState.selected)
            let mobile = "\(self.userInfoDict["code"]!)" + "\(self.userInfoDict["mobile"]!)"
            self.mobileTF.text = mobile
            isEdit = !isEdit
            self.mobileTF.endEditing(true)
            CommonClass.startLoader()
            sendOtpWebService()
        }
    }
}

//MARK:- textField delegate
//MARK:- ************************************

extension LoginVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.forgotMobileCodeField{
            self.forgotMobileCodeField.isEnabled = false
            
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "ShowCodeDetailVC") as! ShowCodeDetailVC
            obj.delegate = self
            if (self.userInfoDict["code"]) != nil{
                obj.codeStr = self.userInfoDict["code"] as? String ?? ""
                obj.countryNameStr = self.userInfoDict["country"] as? String ?? ""
                obj.Max_NSN = self.userInfoDict["max"] as? Int ?? 0
                obj.Min_NSN = self.userInfoDict["min"] as? Int ?? 0
            }
            
            self.navigationController?.present(obj, animated: true, completion: nil)
            self.forgotMobileCodeField.isEnabled = true
        }
            
        else if textField == self.editMobileCodetext{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "ShowCodeDetailVC") as! ShowCodeDetailVC
            self.editMobileCodetext.isEnabled = false
            obj.delegate = self
            if (self.userInfoDict["code"]) != nil{
                obj.codeStr = self.userInfoDict["code"] as! String
                obj.countryNameStr = self.userInfoDict["country"] as! String
                obj.Max_NSN = self.userInfoDict["max"] as! Int
                obj.Min_NSN = self.userInfoDict["min"] as! Int
            }
            self.navigationController?.present(obj, animated: true, completion: nil)
            self.editMobileCodetext.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.userNameTextField{
        }
        else if textField == self.passwordTextField{
            loginWebservice()
        }
        else if textField == self.mobileTextfield{
            sendOtpWebService()
        }
        else if textField == self.otpTextField{
            otpconfirmwebService()
        }
        else if textField == editMobileCodetext{
            textField.resignFirstResponder()
        }
        self.userNameTextField.endEditing(true)
        self.passwordTextField.endEditing(true)
        self.mobileTextfield.endEditing(true)
        self.otpTextField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        CommonClass.delay(0.1) { () -> () in
             if textField == self.mobileTextfield || textField == self.mobileTF{
                self.userInfoDict["mobile"] = textField.text! as AnyObject
            }
            else if textField == self.otpTextField{
                self.userInfoDict["otp"] = textField.text! as AnyObject
            }
        }
        
        return true
    }
}


//MARK:- country code delegate
//MARK:- ************************************


extension LoginVC:ShowCodeDetailDelegate{
    
    func getCountryCode(_ code: String!, countryName: String!, max_NSN_Length: Int!, min_NSN_Length: Int!) {
        self.userInfoDict["code"] = code
        self.userInfoDict["country"] = countryName
        self.userInfoDict["max"] = max_NSN_Length
        self.userInfoDict["min"] = min_NSN_Length

        if self.forgotEditState == ForgotEditCodeState.forgot{
            
            self.forgotMobileCodeField.text = code
        }
            
        else if self.forgotEditState == ForgotEditCodeState.edit{
            
            self.editMobileCodetext.text = code
        }
    }
}



