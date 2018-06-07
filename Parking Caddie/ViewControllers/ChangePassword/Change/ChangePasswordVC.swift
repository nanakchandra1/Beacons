//
//  ChangePasswordVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController{
    
//MARK:- Properties
//MARK:- ******************************************************************
  
    
//MARK:- Outlets
//MARK:- ******************************************************************
    
    @IBOutlet weak var statusBar: UIView!
    
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var contentBgView: UIView!
    @IBOutlet weak var oldPassSeperator: UIView!
    @IBOutlet weak var newPassSeperator: UIView!
    @IBOutlet weak var confermPassSeperator: UIView!
    
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    @IBOutlet weak var oldPasswordLbl: UILabel!
    @IBOutlet weak var oldPassTextField: UITextField!
    @IBOutlet weak var newPasswordLbl: UILabel!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmPasswordLbl: UILabel!
    @IBOutlet weak var confirmPassTextField: UITextField!

    
//MARK:- Outlets
//MARK:- ******************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentBgView.layer.cornerRadius = 3
        self.updateBtn.layer.cornerRadius = 3
        self.oldPassTextField.delegate = self
        self.newPassTextField.delegate  = self
        self.confirmPassTextField.delegate = self
        self.oldPassTextField.returnKeyType = UIReturnKeyType.next
        self.newPassTextField.returnKeyType = UIReturnKeyType.next
        self.confirmPassTextField.returnKeyType = UIReturnKeyType.done
        self.oldPassTextField.nextField = self.newPassTextField
        self.newPassTextField.nextField = self.confirmPassTextField
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// Calling touchesBegan Method to hide the keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
    
//MARK:- Buttion actions
//MARK:- ******************************************************************
    
    // show password
    
    @IBAction func showBtnTap(_ sender: AnyObject) {
        if !self.showPassBtn.isSelected{
        self.newPassTextField.isSecureTextEntry = false
        self.confirmPassTextField.isSecureTextEntry = false
            let newPosition = confirmPassTextField.endOfDocument
            confirmPassTextField.selectedTextRange = confirmPassTextField.textRange(from: newPosition, to: newPosition)
            self.showPassBtn.isSelected = !self.showPassBtn.isSelected
        }
        else{
            self.newPassTextField.isSecureTextEntry = true
            self.confirmPassTextField.isSecureTextEntry = true

            self.showPassBtn.isSelected = !self.showPassBtn.isSelected
        }
    }
   
    
    //Update Button Action
    
    @IBAction func updateBtnTap(_ sender: AnyObject) {
        if self.oldPassTextField.text!.characters.count == 0{
            AppDelegate.showToast(myAppconstantStrings.emptyOldPass)
            
        }
        else if self.newPassTextField.text!.characters.count == 0{
            AppDelegate.showToast(myAppconstantStrings.emptyNewPass)
            
        }
        else if self.confirmPassTextField.text!.characters.count == 0{
            AppDelegate.showToast(myAppconstantStrings.emptyConfirmPass)
            
        }
        else if self.newPassTextField.text! != self.confirmPassTextField.text!{
            AppDelegate.showToast(myAppconstantStrings.matchPass)
        }
        else if self.newPassTextField.text!.characters.count < 8 || self.confirmPassTextField.text!.characters.count > 32{
            AppDelegate.showToast(myAppconstantStrings.passLength)
            CommonClass.stopLoader()
        }
        else{
            var params = JSONDictionary()
            params["action"] = "change"
            params["email"] = CurrentUser.userEmail
            params["old_password"] = self.oldPassTextField.text
            params["new_password"] = self.newPassTextField.text
            params["confirm_password"] = self.confirmPassTextField.text
            
            
            WebserviceController.changePasswordService(params, succesBlock: { (success, json) in
                
                CommonClass.stopLoader()
                if success{
                    
                    AppDelegate.showToast(json["message"].stringValue)
                    
                    UIView.animate(withDuration: 3, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    }, completion: { (Bool) -> Void in
                        
                        self.view.removeFromSuperview()
                        self.removeFromParentViewController()
                    })
                    
                } else {
                    
                    AppDelegate.showToast(json["message"].stringValue)
                    
                }
                
            }, failureBlock: { (error) in
                
                CommonClass.stopLoader()
                
            })
            
        }
    }
    
    
    //Back Button
    
    @IBAction func onTapBackBtn(_ sender: AnyObject) {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                
                self.view.removeFromSuperview()
          self.removeFromParentViewController()
        }) 
    }
    
    
    func validateInfo(_ textField :UITextField,string : String,range:NSRange) -> Bool {
        
        if range.length == 1 {
            return true
        }
        
        if textField == self.oldPassTextField{
            if (string == " ") {
                return false
            }
            return true
        }
        if textField == self.newPassTextField{
            if (string == " ") {
                return false
            }
            return true
        }
        if textField == self.confirmPassTextField{
            if (string == " ") {
                return false
            }
            return true
        }

        return true
    }
}



//MARK:- TextField Delegate
//MARK:- **************************************************************

extension ChangePasswordVC: UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.validateInfo(textField,string: string,range:range)
        
    }
}
