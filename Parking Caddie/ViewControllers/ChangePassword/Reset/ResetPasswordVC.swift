//
//  ResetPasswordVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 11/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController {
    
    //MARK:- Properties
    //MARK:-  -------------------------------------------------------------------------------
    
    var mobile = ""
    
    
    //MARK:- IBOutlets
    //MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var resetPassNavigationTitle: UILabel!
    
    @IBOutlet weak var resetPassBgView: UIView!
    @IBOutlet weak var newPassSeperator: UIView!
    @IBOutlet weak var newPassLbl: UILabel!
    @IBOutlet weak var newPassTextfield: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var confirmPassLbl: UILabel!
    @IBOutlet weak var confirmPassSeperator: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    
    @IBOutlet weak var confirmPassTextfield: UITextField!
    
    
    //MARK:- View life Cycle
    //MARK:-  -------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newPassTextfield.delegate = self
        self.confirmPassTextfield.delegate = self
        self.resetBtn.layer.cornerRadius = 2
        self.resetPassBgView.layer.cornerRadius = 3
        self.newPassTextfield.returnKeyType = UIReturnKeyType.next
        self.confirmPassTextfield.returnKeyType = UIReturnKeyType.done
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
//MARK:- IBAction
//MARK:-  -------------------------------------------------------------------------------
    
    @IBAction func onTapShowPass(_ sender: UIButton) {
        if !sender.isSelected{
            self.newPassTextfield.isSecureTextEntry = false
            self.confirmPassTextfield.isSecureTextEntry = false
            self.showPassBtn.setImage(UIImage(named: "active_password_eye"), for: UIControlState())
            
            sender.isSelected = !sender.isSelected
        }
        else{
            self.newPassTextfield.isSecureTextEntry = true
            self.confirmPassTextfield.isSecureTextEntry = true
            self.showPassBtn.setImage(UIImage(named: "password_eye"), for: UIControlState())
            
            
            sender.isSelected = !sender.isSelected
        }
    }
    
    @IBAction func onTapResetBtn(_ sender: AnyObject) {
        CommonClass.startLoader()
        guard let newPass = self.newPassTextfield.text, newPass.characters.count > 0 else{
            AppDelegate.showToast(myAppconstantStrings.emptyNewPass)
            CommonClass.stopLoader()
            return
        }
        guard newPass.characters.count >= 8 && newPass.characters.count <= 32 else{
            AppDelegate.showToast(myAppconstantStrings.passLength)
            CommonClass.stopLoader()
            return
        }
        guard let confirmPass = self.confirmPassTextfield.text, confirmPass.characters.count > 0 else{
            AppDelegate.showToast(myAppconstantStrings.emptyConfirmPass)
            CommonClass.stopLoader()
            return
        }
        guard confirmPass.characters.count >= 8 && confirmPass.characters.count <= 32 else{
            AppDelegate.showToast(myAppconstantStrings.passLength)
            CommonClass.stopLoader()
            return
        }
        
        resetPassWebService()
    }
    
    
    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------
    
    func resetPassWebService(){
        
        var params = JSONDictionary()
        
        params["action"] = "reset"
        params["mobile"] = self.mobile
        params["new_password"] = self.newPassTextfield.text
        params["confirm_password"] = self.confirmPassTextfield.text

        CommonClass.startLoader()
        
        WebserviceController.changePassword(params, succesBlock: { (success, json) in
            
            let message = json["message"].string ?? ""
            
            AppDelegate.showToast(message)

            if success{
            
                CommonFunctions.gotoLoginPage()

            }
            
        }) { (error) in
            
        }
    }
    
    
}

//MARK:- UITextField Delegate
//MARK:-  -------------------------------------------------------------------------------

extension ResetPasswordVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.newPassTextfield{
            
        }
        if textField == confirmPassTextfield{
        }
        self.newPassTextfield.endEditing(true)
        self.confirmPassTextfield.endEditing(true)
        return true
    }
}
