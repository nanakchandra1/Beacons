//
//  SignupCompletePopupVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 12/01/18.
//  Copyright © 2018 Appinventiv. All rights reserved.
//

import UIKit

class SignupCompletePopupVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var tickImg: UIImageView!
    @IBOutlet weak var smilyImg: UIImageView!
    @IBOutlet weak var okBtn: UIButton!
    
    let msg = "Congratulations your registration is complete.\nUpon returning from your trip, collect your bags and\npress ‘Request Shuttle’ on the app to summon your pickup\nand automatically pay your parking fee.\nYour vehicle will be waiting."
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    private func initialSetup(){
    
        self.tickImg.image = UIImage(named: "ic_payment_successful_tick")
        self.smilyImg.image = UIImage(named: "icons8-happy-100")
        self.msgLbl.text = self.msg
        self.bgView.layer.cornerRadius = 3
        self.okBtn.layer.cornerRadius = 3

        
    }
    
    // dismiss with animate effect
    
    func animatedDisapper(_ complete: @escaping () -> Void){
        
        UIView.animate(withDuration: 0.5) {
            
            self.bgView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            self.view.alpha = 0
        }
        
        CommonClass.delay(0.5) {
            
            APPDELEGATEOBJECT.parentNavigationController.dismiss(animated: false, completion: nil)
            
            complete()
            
        }
    }

    
    @IBAction func okBtnTap(_ sender: UIButton) {
        
        self.animatedDisapper {}
        
    }
    
    
}
