//
//  SelectVehicleVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 10/08/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

protocol SetSelectedVehicleDelegate {
    
    func setSelectedVehicle(_ selectedIndex: IndexPath)
    func pushView()
}


import UIKit

class SelectVehicleVC: UIViewController {

    
    //MARK:- IBOutlets
    //MARK:-  ====================================
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var selectVehicleCollectionView: UICollectionView!
    @IBOutlet weak var vehicleSelectBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var selectVehicleLbl: UILabel!

    //MARK:- Properties
    //MARK:-  ====================================

    
    var selectedIndexPath:IndexPath?
    var delegate: SetSelectedVehicleDelegate!
    var carName = [String]()

    
    //MARK:- View life cycles methods
    //MARK:-  ====================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.selectVehicleCollectionView.dataSource = self
        self.selectVehicleCollectionView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let view = touches.first?.view {
            if view == self.popUpView && !self.popUpView.subviews.contains(view) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    
    
    //MARK:- IBActions
    //MARK:-  ====================================

    
    @IBAction func onTapPopUpCancelBtn(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    
    @IBAction func onTapSelectVehicleBtn(_ sender: UIButton) {
        
        if self.selectedIndexPath != nil{
        self.dismiss(animated: true) {
            
            self.delegate.setSelectedVehicle(self.selectedIndexPath!)
            self.delegate.pushView()

        }
        }else{
            AppDelegate.showToast(myAppconstantStrings.selectVehicle)
        }
    }

}


//MARK:- Collection View Delegate And Datasource
//MARK:- ************************************************

extension SelectVehicleVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if CurrentUser.vehicles != nil{
            return (CurrentUser.vehicles?.count)!
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectVehicleCell", for: indexPath) as! SelectVehicleCell
        cell.viewImage.layer.borderWidth = 1
        cell.viewImage.layer.borderColor = UIColor.black.cgColor
        cell.viewImage.layer.cornerRadius = cell.viewImage.frame.width / 2
        cell.carNameLbl.text = self.carName[indexPath.item]
        cell.countLbl.text = "0" + String(indexPath.item + 1)
        
        if indexPath == self.selectedIndexPath{
            cell.viewImage.backgroundColor = UIColor.appBlue
            cell.carNameLbl.isHidden = false
            cell.sliderImgeView.isHidden = false
            
        }
        else{
            cell.viewImage.backgroundColor = UIColor.clear
            cell.carNameLbl.isHidden = true
            cell.sliderImgeView.isHidden = true
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedIndexPath = indexPath
        self.selectVehicleCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize
    {
        let cellSize:CGSize = CGSize(width: 70,height: self.selectVehicleCollectionView.frame.height)
        return cellSize
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewWidth: Int = Int(self.selectVehicleCollectionView.bounds.width)
        var totalCellWidth: Int = 0
        var totalSpacingWidth: Int = 0
        
        if CurrentUser.vehicles != nil{
            totalCellWidth = 70 * (CurrentUser.vehicles?.count)!
            totalSpacingWidth = 1 * ((CurrentUser.vehicles?.count)! - 1)
            
        }
        else{
            totalCellWidth =  0
            totalSpacingWidth = 1
        }
        
        let leftInset: Int = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2
        let rightInset: Int = leftInset
        return UIEdgeInsetsMake(0, CGFloat(leftInset) , 0, CGFloat(rightInset))
    }
}




//MARK:- Collection view cell classess
//MARK:- ********************************************************

class SelectVehicleCell: UICollectionViewCell{
    
    @IBOutlet weak var preView: UIView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var sliderImgeView: UIImageView!
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    
}
