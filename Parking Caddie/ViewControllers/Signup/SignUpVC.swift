//
//  SignUpVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum NewUser {
    case new,edit
}



class SignUpVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ShowCodeDetailDelegate,TTTAttributedLabelDelegate {
    
    //MARK: Properties
    //MARK:- ************************************
    
    var editedData: [String : String] = ["name":"", "email":"","location":"","mobile":"","password":"","code":""]
    var tapGasture: UITapGestureRecognizer!
    let imagePicker = UIImagePickerController()
    var signUpResult = UserData()
    var image:String!
    var isImage = false
    var ProfilePic = UIImageView()
    var newUser:NewUser = .new
    var terms_condition = false
    var token:String?
    
    //MARK: Outlets
    //MARK:- ************************************
    
    @IBOutlet weak var signUpTableView: UITableView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var popUpBgView: UIView!
    @IBOutlet weak var symbolimage: UIImageView!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var otplabel: UILabel!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var otpConfirmBtn: UIButton!
    @IBOutlet weak var poPupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var docBgView: UIView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var privacytextView: UITextView!
    
    var code:String!
    var country:String!
    var max_No:Int = 10
    var min_no:Int = 10
    var countryCodeInfo = ["max_No": 10, "min_no": 10]
    
    
//MARK: View life Cycle
//MARK:- ************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification:Notification!) -> Void in
            
            self.view.addGestureRecognizer(self.tapGasture)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
            
            queue: OperationQueue.main) {_ in
                
                self.view.removeGestureRecognizer(self.tapGasture)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Functions
    //MARK:- ************************************
    
    fileprivate func setupSubviews(){
        
        self.bgView.isHidden = true
        self.imagePicker.delegate = self
        self.signUpTableView.dataSource = self
        self.signUpTableView.delegate = self
        self.otpTextField.delegate = self
        self.signUpTableView.separatorStyle = .none
        self.poPupTopConstraint.constant = -185
        self.symbolimage.layer.cornerRadius = self.symbolimage.bounds.width / 2
        self.symbolimage.layer.masksToBounds = true
        
        if let _ = CurrentUser.userImage{
            
            self.image = "\(imageBaseURL)" + CurrentUser.userImage!
            
        }
        
        self.signUpTableView.register(UINib(nibName: "SignUpTableviewCell", bundle: nil), forCellReuseIdentifier: "SignUpTableviewCell_ID")
        self.signUpTableView.register(UINib(nibName: "TermsCondCell", bundle: nil), forCellReuseIdentifier: "TermsCondCell_Id")
        self.signUpTableView.register(UINib(nibName: "ProfileImageCell", bundle: nil), forCellReuseIdentifier: "ProfileImageCell")
        tapGasture = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard(_:)))
    }
    
    
    //Dismiss KeyBord
    
    func dismissKeyboard(_ sender: AnyObject)
    {
        self.view.endEditing(true)
    }
    
    func isValid() -> Bool{
    
        let name = self.editedData["name"]!
        let email = self.editedData["email"]!
        let location = self.editedData["location"]!
        let mobile = self.editedData["mobile"]!
        let password = self.editedData["password"]!

        
        if !self.isImage{
            
            AppDelegate.showToast(myAppconstantStrings.selectImage)
            return false
            
        }
        if name.isEmpty{
            
            AppDelegate.showToast(myAppconstantStrings.enterName)
            return false

        }
         if email.isEmpty{
            
            
                AppDelegate.showToast("Please Enter Email")
            return false

        }
        
        if !CommonClass.isValidEmail(email){
                
                AppDelegate.showToast(myAppconstantStrings.validEmail)
                return false
        }
        
         if location.isEmpty{
            AppDelegate.showToast(myAppconstantStrings.enterCity)
            return false
        }
        
         if mobile.isEmpty{
            AppDelegate.showToast(myAppconstantStrings.entermobile)
            return false
        }
        
         if password.characters.count < 8 || password.characters.count > 32 {
            AppDelegate.showToast(myAppconstantStrings.passLength)
            return false
        }
         if !self.terms_condition{
            
            AppDelegate.showToast(myAppconstantStrings.terms)
            return false
        }
        return true

    }
    
    
    //SignUp Button Action
    
    func onTapSignUpBtn(_ sender:UIButton){
        
        if !self.isValid() {
            
            return
            
        }else{
            
            let name = self.editedData["name"]!
            let email = self.editedData["email"]!
            let location = self.editedData["location"]!
            let mobile = self.editedData["mobile"]!
            let password = self.editedData["password"]!
            let code = self.editedData["code"]!


            var params = JSONDictionary()
            
            params["email"] = email
            params["location"] = location
            params["mobile"] = code + mobile
            params["country_code"] = code
            params["phone_no"] = mobile
            params["password"] = password
            params["full_name"] = name
            params["device_id"] = UIDevice.current.identifierForVendor!.uuidString
            params["device_token"] = APPDELEGATEOBJECT.device_Token
            params["device_model"] = UIDevice.current.model
            params["platform"] = "iOS"
            params["os_version"] = UIDevice.current.systemVersion

            
            if self.newUser == .edit
            {
                params["action"] = "edit" as AnyObject
                self.backBtn.isSelected = !self.backBtn.isSelected
            }
            else
            {
                params["action"] = "new" as AnyObject
            }
            
            print_debug(params)
            CommonClass.startLoader()
            
            WebserviceController.signUp(params, image: ["user_image":self.ProfilePic.image!], isImageAvailable: self.isImage, succesBlock: { (success, json) in
                
                if success{
                    
                    let result = json["result"].dictionary ?? [:]
                    self.token = result["token"]?.string ?? ""
                    
                    self.mobileLabel.text  =  self.editedData["code"]! + self.editedData["mobile"]!
                    self.poPupTopConstraint.constant = 20
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                        self.bgView.isHidden = false
                    })
                }else{
                
                    AppDelegate.showToast(json["message"].stringValue)
                }
                
            }, failureBlock: { (error) in
                
                
            })
        }
    }
    
    
  //Already have an account
    
    func onTapAlreddyHaveAc(_ sender:UIButton){
        
        let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        APPDELEGATEOBJECT.parentNavigationController  = UINavigationController(rootViewController: loginVc)
        APPDELEGATEOBJECT.window?.rootViewController = APPDELEGATEOBJECT.parentNavigationController
        APPDELEGATEOBJECT.window?.makeKeyAndVisible()
        APPDELEGATEOBJECT.parentNavigationController.isNavigationBarHidden = true
    }
    
    
    
 //OTP web Service
    
    func otpConfirmWebservice(){
        
        if self.otpTextField.text!.characters.count == 0{
            AppDelegate.showToast(myAppconstantStrings.enterOtp)
        }
            
        else{
            var params = JSONDictionary()
            params["action"] = "email"
            params["email"] = self.editedData["email"]
            params["otp"] = self.otpTextField.text

            
            
            WebserviceController.loginScreenOtpConfirm(params, succesBlock: { (success, json) in
                
                let msg = json["message"].string ?? ""
                AppDelegate.showToast(msg)

                if success{
                
                    self.signUpResult = UserData(withJson: json["result"])
                    self.poPupTopConstraint.constant = -185
                    
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                        
                    }, completion: { (Bool) -> Void in
                        self.bgView.isHidden = true
                        CommonFunctions.gotoLandingPage()
                    })

                    
                }
                
            }, failureBlock: { (error) in
                
                
            })
            
        }
    }
    
    
    
    
   //Get country code
    
    func getCountryCode(_ code: String!, countryName: String!, max_NSN_Length: Int!, min_NSN_Length: Int!) {
        self.editedData["code"] = code ?? ""
        self.country = countryName ?? ""
        self.max_No = max_NSN_Length ?? 0
        self.min_no = min_NSN_Length ?? 0
        self.signUpTableView.reloadData()
    }
    
    
    // validate textfield datya
    
    func validateInfo(_ textField :UITextField,string : String,range:NSRange) -> Bool {
        let  cellIndexPath = textField.tableViewIndexPath(self.signUpTableView)

        if range.length == 1 {
            return true
        }
        if cellIndexPath?.row == 4{
            let cell = textField.tableViewCell() as! MobileCell

            if textField == cell.mobiletextField {
                if let _ = textField.text {
                    if textField.text!.characters.count  > self.max_No {
                        return false
                    } else {
                        return true
                    }
                }
            }
        }

        
        if let text = textField.text {
            
            if text.characters.count  > 32 {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    //MARK:- Button Tapp Action
    //MARK:- ************************************
    
    @IBAction func onTapCountryCodeTextField(_ sender: UITextField) {
        
    }
    
//Confirm OTP button action
    
    @IBAction func otpConfirmbtn(_ sender: AnyObject) {
        self.otpTextField.endEditing(true)
        otpConfirmWebservice()
        }
 
    
//Cancel OTP  button action
    
    @IBAction func onTapCancel(_ sender: UIButton){
        self.signUpTableView.reloadData()
        self.newUser = .edit
        self.poPupTopConstraint.constant = -185
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
            }, completion: { (Bool) -> Void in
                self.bgView.isHidden = true
        }) 
    }
    
    //show password function
    
    func showPasswordTap(_ sender : UIButton){
        let point =  sender.convert(sender.bounds.origin, to: self.signUpTableView)
        let idx = self.signUpTableView.indexPathForRow(at: point)
        let cell = self.signUpTableView.cellForRow(at: idx!) as! SignUpTableviewCell
        if sender.isSelected{
            cell.nameTextField.isSecureTextEntry = true
            cell.showBtn.setImage(UIImage(named: "password_eye"), for: UIControlState())
            
            sender.isSelected = !sender.isSelected
        }
        else{
            cell.nameTextField.isSecureTextEntry = false
            cell.showBtn.setImage(UIImage(named: "active_password_eye"), for: UIControlState())
            
            sender.isSelected = !sender.isSelected
            
        }
    }
    
    @IBAction func onTapAlredyHaveAcc(_ sender: AnyObject) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    

//Resend OTP button action
    
    @IBAction func onTapResendOTP(_ sender: AnyObject) {
        
        var params = JSONDictionary()
        
        params["action"] = "email"
        
        params["email"] = self.editedData["email"]!

        
        WebserviceController.resendOTP(params, succesBlock: { (success, json) in
            
            let message = json["message"].string ?? ""
            AppDelegate.showToast(message)
            
        }) { (error) in
            
        }
    }
    
 //Accept terms & condition button action
    
    func onTapTerms_conditionBtn(_ sender : UIButton){
        self.terms_condition = !self.terms_condition
        self.signUpTableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    
    
    
 // MARK:- Upload profile image
    
    func onEditImageTap(_ sender: UIButton){
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
  
    
    //Pic image from Gallery
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertView()
            alert.title = "Warning"
            alert.message = "You don't have camera"
            alert.addButton(withTitle: "OK")
            alert.show()
        }
    }
    func openGallery(){
        
        imagePicker.isEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

    
    //imagePickerControllerdelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let cell = self.signUpTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProfileImageCell
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            cell.profileImage.image = pickedImage
            self.ProfilePic.image = pickedImage
            self.isImage = true
            self.signUpTableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    

    
    // attriuted label didselect method
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        if url.absoluteString == "abc"{
            
            let obj  = settingsStoryboard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.str = "Terms Of Service"
            obj.action = "term-and-condition"
            obj.termsConditiond = TermsConditionState.signUp
            self.navigationController?.present(obj, animated: true, completion: nil)
        }
        else if url.absoluteString == "xyz"{
            
            let obj  = settingsStoryboard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.str = "Privacy Policy"
            obj.action = "privacy-policy"
            obj.termsConditiond = TermsConditionState.signUp

            self.navigationController?.present(obj, animated: true, completion: nil)

        }
    }
}


//MARK:- TableView Datasource And Delegate
//MARK:- ************************************

extension SignUpVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row{
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as! ProfileImageCell
            cell.editImageBtn.addTarget(self, action: #selector(SignUpVC.onEditImageTap(_:)), for: .touchUpInside)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
            cell.nameLbl.text = "FULL NAME"
            cell.nameTextField.delegate = self
            cell.showBtn.isHidden = true
            cell.nameTextField.autocorrectionType = .no
            let Placeholder = NSAttributedString(string: "Enter Full Name", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
            cell.nameTextField.attributedPlaceholder = Placeholder
            
            return cell
                        
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
            cell.nameLbl.text = "EMAIL ADDRESS"
            cell.nameTextField.delegate = self
            cell.showBtn.isHidden = true
            cell.nameTextField.keyboardType = UIKeyboardType.emailAddress
            let Placeholder = NSAttributedString(string: "Enter Email Address", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
            cell.nameTextField.attributedPlaceholder = Placeholder
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
            cell.nameLbl.text = "YOUR CITY"
            cell.nameTextField.delegate = self
            cell.showBtn.isHidden = true
            cell.nameTextField.keyboardType = UIKeyboardType.emailAddress
            let Placeholder = NSAttributedString(string: "Enter Your City", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
            cell.nameTextField.attributedPlaceholder = Placeholder
            return cell

            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MobileCell", for: indexPath) as! MobileCell
            cell.mobileLbl.text = "MOBILE NUMBER"
            cell.countryCodeTextField.delegate = self
            cell.mobiletextField.delegate = self
            cell.countryCodeTextField.text = self.editedData["code"]
            cell.mobiletextField.keyboardType = UIKeyboardType.phonePad
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
            cell.nameTextField.isSecureTextEntry = true
            cell.nameTextField.delegate = self
            cell.nameLbl.text = "PASSWORD"
            cell.showBtn.isHidden = false
            let Placeholder = NSAttributedString(string: "Enter Password", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
            cell.nameTextField.attributedPlaceholder = Placeholder
            cell.showBtn.addTarget(self, action: #selector(SignUpVC.showPasswordTap(_:)), for: .touchUpInside)
            return cell
            
        case 6:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TermsCondCell_Id", for: indexPath) as! TermsCondCell
            
            cell.checkBtn.addTarget(self, action: #selector(SignUpVC.onTapTerms_conditionBtn(_:)), for: UIControlEvents.touchUpInside)
            
            cell.terms_CondLbl.delegate  = self
            
            cell.terms_CondLbl.text = myAppconstantStrings.terms_condi
            
            let subscriptionNoticeLinkAttributes = [
                NSForegroundColorAttributeName: UIColor.blue,
                NSUnderlineStyleAttributeName: NSNumber(value:true),
                ]
            
            cell.terms_CondLbl.linkAttributes = subscriptionNoticeLinkAttributes
            cell.terms_CondLbl.activeLinkAttributes = subscriptionNoticeLinkAttributes
            

            if self.terms_condition{
                
                cell.checkBtn.setImage(UIImage(named: "signup_tick"), for: UIControlState())
            }
            else{
                
                cell.checkBtn.setImage(UIImage(named: ""), for: UIControlState())
            }
            
            let str:NSString = cell.terms_CondLbl.text! as NSString
            
            let range : NSRange = str.range(of: "Terms of Service")
            cell.terms_CondLbl!.addLink(to: URL(string: "abc")!, with: range)
            let range1: NSRange = str.range(of: "Privacy Policy")
            cell.terms_CondLbl!.addLink(to: URL(string: "xyz")!, with: range1)
            
            return cell
            
        
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
                cell.signUpButton.layer.cornerRadius = 2
                
                if self.newUser == .edit{
                cell.signUpButton.setTitle("Update", for: UIControlState())
                }
                else{
                cell.signUpButton.setTitle("Sign Up", for: UIControlState())
                }
                cell.signUpButton.addTarget(self, action: #selector(SignUpVC.onTapSignUpBtn(_:)), for: .touchUpInside)
                cell.loginBtn.addTarget(self, action: #selector(SignUpVC.onTapAlreddyHaveAc(_:)), for: .touchUpInside)
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UIScreen.main.bounds.height / 4
        }
        else if indexPath.row == 6{
            return 80
        }
        else if indexPath.row == 7{
        return 172
        }
        else {
            return 73
        }
    }
}

//MARK:- TextField Delegate
//MARK:- ************************************

extension SignUpVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let  cellIndexPath = textField.tableViewIndexPath(self.signUpTableView)
        
        if cellIndexPath?.row == 4{

            let cell = textField.tableViewCell() as! MobileCell
            if textField == cell.countryCodeTextField{
                cell.countryCodeTextField.isEnabled = false
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "ShowCodeDetailVC") as! ShowCodeDetailVC
                obj.delegate = self
                if let code = self.editedData["code"]{
                    obj.codeStr = code
                    obj.countryNameStr = self.country
                    obj.Max_NSN = self.max_No
                    obj.Min_NSN = self.min_no
                }
                self.navigationController?.present(obj, animated: true, completion: nil)
                cell.countryCodeTextField.isEnabled = true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        CommonClass.delay(0.1) { () -> () in
            if let  cellIndexPath = textField.tableViewIndexPath(self.signUpTableView){
        
        
        if cellIndexPath.row == 1{
            
            self.editedData["name"] = textField.text
        }
        else if cellIndexPath.row == 2{
            self.editedData["email"] = textField.text

        }
        else if cellIndexPath.row == 3{
            self.editedData["location"] = textField.text

        }
            
        else if cellIndexPath.row == 4{
            
            let cell = textField.tableViewCell() as! MobileCell
            
            if textField == cell.countryCodeTextField{
                
                self.editedData["code"] = cell.countryCodeTextField.text
            }
            else{
                self.editedData["mobile"] = cell.mobiletextField.text
            }
        }
            
        else if cellIndexPath.row == 5{
            self.editedData["password"] = textField.text
        }
            
        }
        }
        return self.validateInfo(textField,string: string,range:range)
    }
}



//MARK:- Table view cell class
//MARK:-

class MobileCell: UITableViewCell{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var mobiletextField: UITextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}


class ButtonCell:UITableViewCell{
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
