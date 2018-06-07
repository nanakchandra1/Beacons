//
//  AgentInfoPopUpVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 21/08/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit

class AgentInfoPopUpVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- ==========================================
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var agentNameLbl: UILabel!
    @IBOutlet weak var agentImg: UIImageView!
    @IBOutlet weak var contactNoLbl: UILabel!
    @IBOutlet weak var emailidLbl: UILabel!
    @IBOutlet weak var detailView: UIView!
    
    
    //MARK:- Properties
    //MARK:- ==========================================

    var agentDetail = JSONDictionary()
    
    //MARK:- view life cycle methods
    //MARK:- ==========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        if let view = touches.first?.view {
            
            if view == self.view && !self.view.subviews.contains(view) {
                
                self.dismiss(animated: true, completion: {
                    
                })
            }
        }
    }

    
    //MARK:- private methods
    //MARK:- ==========================================

    private func initialSetup(){
    
        self.popupView.layer.cornerRadius = 3
        self.detailView.layer.cornerRadius = 3
        self.detailView.layer.borderWidth = 1
        self.detailView.layer.borderColor = UIColor.appBlue.cgColor
        self.agentImg.layer.cornerRadius = 30
        self.agentImg.layer.borderColor = UIColor.appBlue.cgColor
        self.agentImg.layer.masksToBounds = true
        self.agentImg.layer.borderWidth = 1
        self.agentDetail = parkingSharedInstance.agentInfo
        self.setupAgentDetail()
    }
    
    
    func setupAgentDetail(){
    
        guard let agent = self.agentDetail["agent"] as? JSONDictionary else{return}
        self.agentNameLbl.text = agent["name"] as? String ?? ""
        self.emailidLbl.text = agent["email"] as? String ?? ""
        self.contactNoLbl.text = agent["phone"] as? String ?? ""
        let image = agent["image"] as? String ?? ""
        let imageUrl = URL(string: imageBaseURL + image)
        
        self.agentImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "signup_placeholder"))

    }
    
    @IBAction func contactTapped(_ sender: UIButton) {
        
        dialPhoneNumer(self.contactNoLbl.text!)
    }
    
}
