//
//  ReceiptPopUpVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 07/12/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit
import KILabel

protocol AllowExitDelegate {
    
    func allowExitParking()
}

enum ReceiptStatus {
    case Fail, Success
}

class ReceiptPopUpVC: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var receiptHeightConst: NSLayoutConstraint!
    @IBOutlet weak var warningImgHeight: NSLayoutConstraint!
    @IBOutlet weak var receiptBGView: UIView!
    @IBOutlet weak var warningImg: UIImageView!
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var paymentstateLbl: KILabel!

    var delegate: AllowExitDelegate!
    var recieptDetail = ExitParkingModel()
    var isPush = false
    var pushType = ""
    
    //MARK:- View life cycle methods
    //MARK:- =================================

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.receiptHeightConst.constant = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getReceiptWithAnimation()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        if let view = touches.first?.view {
            
            if view == self.view && !self.view.subviews.contains(view) {
                
                if self.isPush{
                    
                    self.animatedDisapper {
                        
                        CommonFunctions.gotoLandingPage()
                    }
                        
                }else{
                    
                    if self.recieptDetail.payment_success{
                        
//                        self.animatedDisapper {
//                            
//                            self.delegate.allowExitParking()
//
//                        }

                    }
                }
            }
        }
    }
}


//MARK:- IBActions
//MARK:- =================================

extension ReceiptPopUpVC{
    
    @IBAction func proceedBtnTap(_ sender: UIButton) {
        
        if self.isPush{
            
            self.animatedDisapper({

                self.showReceipt(APPDELEGATEOBJECT.pushData?.parking_id ?? "")
                
            })

        }else{
        
            if self.recieptDetail.payment_success{
                
                self.animatedDisapper({
                    
                    self.delegate.allowExitParking()
                })
                
            }else{
                
                self.animatedDisapper({
                    
                    let obj = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentMethodsVC") as! PaymentMethodsVC
                    obj.state = .Pay
                    APPDELEGATEOBJECT.parentNavigationController.pushViewController(obj, animated: true)
                    
                })
            }

        }
        
    }
}

//MARK:- Private Methods
//MARK:- =================================

extension ReceiptPopUpVC{

    func setupView(){
        
        self.receiptBGView.isHidden = true
        self.warningImg.isHidden = true
        self.warningLbl.isHidden = true
        self.paymentstateLbl.isHidden = true
        self.proceedBtn.layer.cornerRadius = 3
        self.bgView.layer.cornerRadius = 3
        self.proceedBtn.layer.cornerRadius = 3
        
        self.paymentstateLbl.text = self.recieptDetail.message
        
        if self.isPush{
            
            self.paymentstateLbl.text = APPDELEGATEOBJECT.pushData?.alert

            if self.pushType == PushType.PaymentCash{
                
                self.proceedBtn.isHidden = false
                self.warningLbl.text = "PAYMENT SUCCESSFUL"

            }else{
                
                self.proceedBtn.isHidden = true
                self.warningLbl.text = "PAYMENT PENDING"

            }
            
            self.proceedBtn.setTitle("VIEW RECEIPT", for: .normal)
            
            self.warningImg.image = #imageLiteral(resourceName: "ic_payment_successful_tick")
            
        }else{
            
            if self.recieptDetail.payment_success{
                self.proceedBtn.isHidden = true

                self.warningLbl.text = "PAYMENT SUCCESSFUL"
                self.proceedBtn.setTitle("VIEW RECEIPT", for: .normal)
                self.warningImg.image = #imageLiteral(resourceName: "ic_payment_successful_tick")
                
                CommonClass.delay(10, closure: {
                    
                    self.animatedDisapper({
                        
                        self.delegate.allowExitParking()
                        
                    })
                })
                
            }else{
                
                self.proceedBtn.isHidden = false
                self.warningLbl.text = "PAYMENT FAILED!"
                self.proceedBtn.setTitle("MAKE PAYMENT", for: .normal)
                self.warningImg.image = #imageLiteral(resourceName: "ic_payment_error")
                
            }
        }
        
    
        self.paymentstateLbl.urlLinkTapHandler = { label, url, range in
            NSLog("URL \(url) tapped")
           CommonFunctions.openUrlLink(url)
        }
        
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
    
    
    //show payment full receipt
    
    func showReceipt(_ p_id: String){
    
        let obj = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "ReceiptVC") as! ReceiptVC
        
        obj.p_id = p_id
        
        obj.receiptState = .exit
        
        APPDELEGATEOBJECT.parentNavigationController.pushViewController(obj, animated: true)

    
    }


    // show receipt with animation
    
    func getReceiptWithAnimation(){
        
        if self.isPush{
            
            if self.pushType == PushType.PaymentWeb{
                
                self.receiptHeightConst.constant = 300

            }else{
                
                self.receiptHeightConst.constant = 270
            }
        }else{
            self.receiptHeightConst.constant = 270

        }
        
        UIView.animate(withDuration: 1, animations: {
            
            self.view.layoutIfNeeded()
            
            self.receiptBGView.isHidden = false
            
        }) { (true) in
            
            self.warningImg.isHidden = false
            self.warningLbl.isHidden = false
            self.paymentstateLbl.isHidden = false
            
        }
    }
}
