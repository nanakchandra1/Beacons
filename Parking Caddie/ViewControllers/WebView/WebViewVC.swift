//
//  WebViewVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 22/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

enum TermsConditionState{
    
    case signUp,settings,none
}


class WebViewVC: UIViewController {
    

//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------

    var action = ""
    var str = ""
    var termsConditiond = TermsConditionState.none
    
//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var policyLbl: UILabel!
    @IBOutlet weak var tickBtn: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backBtn: UIButton!

    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------
   
    override func viewDidLoad() {
        super.viewDidLoad()
          CommonClass.startLoader()
        webView.scrollView.showsHorizontalScrollIndicator = false
        self.policyLbl.text = self.str
        showTermAndConditions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
//MARK:- IBActions
//MARK:-  -------------------------------------------------------------------------------
    
    @IBAction func onTaptickBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func onTapBackBtn(_ sender: AnyObject) {
        if termsConditiond == TermsConditionState.signUp{
            self.dismiss(animated: true, completion: nil)
        }
        else{
            UIView.animate(withDuration: 3, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }) 
        }
    }

    
    
//MARK:- Functions
//MARK:- ***************************************************
    
    func showTermAndConditions() {
        var  params = JSONDictionary()
        params["action"] = self.action
        
        WebserviceController.staticPagesService(params, succesBlock: { (success, json) in
            
            CommonClass.stopLoader()
            if success{
                
                let result = json["result"].dictionary ?? [:]

                let html = result["pg_content"]?.string ?? ""
                let str1 = html.replacingOccurrences(of: "&lt;", with: "<")
                let str2 = str1.replacingOccurrences(of: "&gt;", with: ">")
                let str3 = str2.replacingOccurrences(of: "&amp;nbsp;", with: " ")
                let str4 = str3.replacingOccurrences(of: "&amp;rsquo;", with: "'")
                self.webView.loadHTMLString(str4, baseURL: nil)
                
            } else {
                
                AppDelegate.showToast(json["message"].stringValue)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
            
        })
        
        /*
         WebserviceController.staticPagesService(params as JSONDictionary) { (result) in
         let html = result["pg_content"] as! String
         let str1 = html.replacingOccurrences(of: "&lt;", with: "<")
         let str2 = str1.replacingOccurrences(of: "&gt;", with: ">")
         let str3 = str2.replacingOccurrences(of: "&amp;nbsp;", with: " ")
         let str4 = str3.replacingOccurrences(of: "&amp;rsquo;", with: "'")
         self.webView.loadHTMLString(str4, baseURL: nil)
         }*/
    }
}
