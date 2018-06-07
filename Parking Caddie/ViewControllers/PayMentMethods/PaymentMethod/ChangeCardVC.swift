//
//  ChangeCardVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 07/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit

class ChangeCardVC: UIViewController {

    
    @IBOutlet weak var cardLbl: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var cardBgView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popUpView.layer.cornerRadius = 3
        self.cardBgView.layer.cornerRadius = 3

        self.getCardDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getCardDetail), name: .setCardNoNotificationName, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func changeBtnTapped(_ sender: UIButton) {
        
        CommonFunctions.getclientToken(self)
        
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
    
    func getCardDetail(){
    
        var params = JSONDictionary()
        params["bt_customer_id"] = CurrentUser.customer_id ?? ""
        
        WebserviceController.getCardAPI(params, succesBlock: { (success, json) in
            print_debug(json)
            let result = json["result"].dictionaryValue
            let cards = result["paymentMethods"]?.arrayValue.first
            let cardNo = cards?["maskedNumber"].stringValue
            self.cardLbl.text = cardNo
            
        }) { (error) in
            
        }
    }
}
