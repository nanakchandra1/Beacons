//
//  ChangeDefaultPasswordPopupVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 14/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit

enum EyeBtnState {
    case New, Confirm
}

class ChangeDefaultPasswordPopupVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- ===============================
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var detailLbl: UILabel!
    
    //MARK:- Properties
    //MARK:- ===============================

    var eywBtnState = EyeBtnState.New
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSubView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK:- IBActions
    //MARK:- ===============================

    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        self.animatedDisapper {        }

    }
    
    @IBAction func skipBtnTapped(_ sender: UIButton) {
        
        self.animatedDisapper {        }
    }
    
    @IBAction func newPassTFAction(_ sender: UITextField) {
        
        self.eywBtnState = .New
        
    }
    
    @IBAction func confirmPassTFAction(_ sender: UITextField) {
        self.eywBtnState = .Confirm

    }
    
}

//MARK:- Private methods
//MARK:- ===============================

extension ChangeDefaultPasswordPopupVC{

    fileprivate func setUpSubView(){
    
        self.containerView.layer.cornerRadius = 3
        self.doneBtn.layer.cornerRadius = 3
        self.newPassTextField.layer.cornerRadius = 3
        self.confirmPassTextField.layer.cornerRadius = 3
        self.newPassTextField.layer.borderColor = UIColor.appBlue.cgColor
        self.confirmPassTextField.layer.borderColor = UIColor.appBlue.cgColor
        self.newPassTextField.layer.borderWidth = 1
        self.confirmPassTextField.layer.borderWidth = 1
        self.newPassTextField.isSecureTextEntry = true
        self.confirmPassTextField.isSecureTextEntry = true
        self.mskeEyeBtn()

    }
    
    fileprivate func mskeEyeBtn(){
    
        let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let eyeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        eyeBtn.setImage(#imageLiteral(resourceName: "password_eye"), for: .normal)
        eyeView.addSubview(eyeBtn)
        eyeBtn.imageView?.contentMode = .center
        self.newPassTextField.rightView = eyeView
        self.newPassTextField.rightViewMode = .whileEditing
        
        
        let eyeConfView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let eyeconfBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        eyeconfBtn.setImage(#imageLiteral(resourceName: "password_eye"), for: .normal)
        eyeConfView.addSubview(eyeconfBtn)
        eyeconfBtn.imageView?.contentMode = .center

        self.confirmPassTextField.rightView = eyeConfView
        self.confirmPassTextField.rightViewMode = .whileEditing

        eyeBtn.addTarget(self, action: #selector(self.eyeBtnTapped(sender:)), for: UIControlEvents.touchUpInside)
        eyeconfBtn.addTarget(self, action: #selector(self.eyeConfBtnTapped(sender:)), for: UIControlEvents.touchUpInside)

    }
    
    
    // dismiss with animate effect
    
   fileprivate func animatedDisapper(_ complete: @escaping () -> Void){
        
        UIView.animate(withDuration: 0.5) {
            
            self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            self.view.alpha = 0
        }
        
        CommonClass.delay(0.5) {
            
            APPDELEGATEOBJECT.parentNavigationController.dismiss(animated: false, completion: nil)
            
            complete()
            
        }
    }

    @objc fileprivate func eyeBtnTapped(sender: UIButton){
    
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            
            self.newPassTextField.isSecureTextEntry = false
            sender.setImage(#imageLiteral(resourceName: "active_password_eye"), for: .normal)

        }else{
            
            self.newPassTextField.isSecureTextEntry = true
            sender.setImage(#imageLiteral(resourceName: "password_eye"), for: .normal)
    }
}
    
    
    @objc fileprivate func eyeConfBtnTapped(sender: UIButton){
    
        sender.isSelected = !sender.isSelected

        if sender.isSelected{
            
            self.confirmPassTextField.isSecureTextEntry = false
            sender.setImage(#imageLiteral(resourceName: "active_password_eye"), for: .normal)
            
        }else{
            
            self.confirmPassTextField.isSecureTextEntry = true
            sender.setImage(#imageLiteral(resourceName: "password_eye"), for: .normal)
        }

    }

}


