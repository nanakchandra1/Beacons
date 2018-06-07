//
//  MyParkingVC.swift
//  Parking Caddie
//
//  Created by Anuj on 5/5/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class MyParkingVC: UIViewController ,UIScrollViewDelegate{
    
    
    
    //MARK:- IBOUTLETS
    //MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationLbl: UILabel!
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var reservationBtn: UIButton!
    @IBOutlet weak var historySlider: UIView!
    @IBOutlet weak var myParkingScrollView: UIScrollView!
    @IBOutlet weak var sliderLeadingConstraint: NSLayoutConstraint!
    
    var isAdded = false
    
    //MARK:- View life cycle
    //MARK:-  -------------------------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myParkingScrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isAdded{
            self.addChildView()
            self.isAdded = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION"), object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- IBActions
    //MARK:-  -------------------------------------------------------------------------------
    
    
    @IBAction func onTapHistoryBtn(_ sender: AnyObject) {
        
        
        self.sliderLeadingConstraint.constant = 0
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3) {
            self.myParkingScrollView.contentOffset.x = 0
            
        }
        
    }
    
    
    
    @IBAction func onReserveBtn(_ sender: AnyObject) {
        
        self.view.layoutIfNeeded()
        self.sliderLeadingConstraint.constant = screenWidth / 2

        UIView.animate(withDuration: 0.3) {
            
            
            self.myParkingScrollView.contentOffset.x = self.view.frame.width
        }
    }
    
    
    func addChildView(){
        
        //set up scroll view
        self.myParkingScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.myParkingScrollView.contentSize.width = screenWidth * 2
        self.myParkingScrollView.isPagingEnabled = true
        
        let historyController = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "ParkingHistoryVC") as! ParkingHistoryVC
        historyController.view.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: self.myParkingScrollView.frame.height)
        self.myParkingScrollView.addSubview(historyController.view)
        self.addChildViewController(historyController)
        
        self.myParkingScrollView.contentOffset.x = 0
        
        let reservationController = parkingHistoryStoryboard.instantiateViewController(withIdentifier: "ReservationVC") as! ReservationVC
        reservationController.view.frame = CGRect(x: self.view.frame.width , y: 0, width: self.view.frame.width, height: self.myParkingScrollView.frame.height)
        
        self.myParkingScrollView.addSubview(reservationController.view)
        self.addChildViewController(reservationController)
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.sliderLeadingConstraint.constant = self.myParkingScrollView.contentOffset.x/2
        
    }
    
}
