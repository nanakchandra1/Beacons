//
//  BusinessBeaconVC.swift
//  Parking Caddie
//
//  Created by Anuj on 5/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class BusinessBeaconVC: UIViewController,ESTBeaconManagerDelegate,CLLocationManagerDelegate {

//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------

    var delegate:childViewcontrollerDelegate!
    let locationManager = CLLocationManager()
    let beaconManager = ESTBeaconManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    var businessNearbybeacons = [BeaconDetailsModel]()
    var businessBecons = [BeaconDetailsModel]()
    var parking_lot_catagory:ParkingLotCatagory = .none
    var business = [Int]()

    
//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------
    
    @IBOutlet weak var businessBeaconTableView:    UITableView!
    

    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSubview()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        self.getBusinessParkingBecon()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------
    
    private func setupSubview(){
        
        self.businessBeaconTableView.separatorStyle = .none
        
        self.businessBeaconTableView.delegate = self
        self.businessBeaconTableView.dataSource = self
        
        self.businessBeaconTableView.register(UINib(nibName: "NearByBeaconCell", bundle: nil), forCellReuseIdentifier: "NearByBeaconCell")

        self.setLocationPermission()

    }

    
    private func setLocationPermission(){
    
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()

    }
    
    
   private func getBusinessParkingBecon(){
        
    
        for res in parkingSharedInstance.selectedLotDetail.slots{
            matchBusinessEnteryBecon(res)
        }
    }
    
    
   private func matchBusinessEnteryBecon(_ slot: slotModel){
    
        let parkin_bn = slot.parkingbeacons
    
        for res in parkingSharedInstance.beaconsDetails{
            
            for value in parkin_bn!{
                
                if value.stringValue == res._id{
                    
                    if res.category  == "business"{
                        
                        self.businessNearbybeacons.append(res)
                    }
                }
            }
        }
    }
    
    
//MARK:- CLLocation MAnager Delegate
//MARK:-  -------------------------------------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if beacons.count == 0{
            
            self.businessBecons.removeAll()
            
            self.business.removeAll()
            
            self.businessBeaconTableView.reloadData()
            
        }
        
        for val in beacons{
            
            let minor = val.minor
            
            let major = val.major
            
            if businessNearbybeacons.count != 0{
                
                for res in self.businessNearbybeacons{
                    
                     let resBnMinor = res.bn_minor
                    
                     let resBnMajor = res.bn_major
                    
                    if minor.intValue == resBnMinor && major.intValue == resBnMajor{
                        
                        if self.business.contains(Int(minor)){
                            
                        }
                        else{
                            
                            self.business.insert(minor as! Int, at: 0)
                            
                            self.businessBecons.insert(res, at: 0)
                        }
                        self.businessBeaconTableView.reloadData()
                    }
                }
            }
        }
    }


}


//MARK:- Table iew delegate and datasource
//MARK:-  -------------------------------------------------------------------------------

extension BusinessBeaconVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return businessBecons.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearByBeaconCell", for: indexPath) as! NearByBeaconCell
        
        let data = businessBecons[indexPath.row]
        
        if let p_name = CurrentUser.pa_detail!["pa_name"] as? String{
            
            cell.lotNameLbl.text = p_name
            
        }
        
            cell.beaconIdLbl.text = data.bn_name
        
            cell.beconTypeLbl.text = data.bn_type

            cell.beaconCatagoryLbl.text = data.category

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 122
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let str = self.businessBecons[indexPath.row].bn_name ?? ""
        
        let beaconName = str.uppercased()
        
        delegate.getBeaconId(self.businessBecons[indexPath.row]._id ?? "", catagory: "Business")
        
        userDefaults.set(parkingCatagories.business, forKey: NSUserDefaultsKeys.CATAGORY)

        
        if ((self.parent?.isKind(of: NearbyBeaconVC.self)) != nil){
            
            (self.parent as? NearbyBeaconVC)?.popUpBGView.isHidden = false
            
            (self.parent as? NearbyBeaconVC)?.welcomeLbl.text = "CAR PARKED AT BEACON \(beaconName)"
        }
        
        
    }
    
    
}



