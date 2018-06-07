//
//  EconomyBeaconVC.swift
//  Parking Caddie
//
//  Created by Anuj on 5/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

protocol childViewcontrollerDelegate{

    func getBeaconId(_ becon_id:String, catagory:String)
}



class EconomyBeaconVC: UIViewController,ESTBeaconManagerDelegate,CLLocationManagerDelegate {
    
//MARK:- Properties
//MARK:-  -------------------------------------------------------------------------------

    var delegate:childViewcontrollerDelegate!
    let locationManager = CLLocationManager()
    let beaconManager = ESTBeaconManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    
    var nearbybeacons = [BeaconDetailsModel]()
    var economyBecons = [BeaconDetailsModel]()
    var economy = [Int]()
    var parking_lot_catagory:ParkingLotCatagory = .none


//MARK:- IBOutlets
//MARK:-  -------------------------------------------------------------------------------

    @IBOutlet weak var economyBeaconTableView: UITableView!
    
    
//MARK:- View life cycle
//MARK:-  -------------------------------------------------------------------------------
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupSubViews()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    

    
//MARK:- Functions
//MARK:-  -------------------------------------------------------------------------------
    
    private func setupSubViews(){
    
        self.economyBeaconTableView.separatorStyle = .none
        
        self.economyBeaconTableView.delegate = self
        
        self.economyBeaconTableView.dataSource = self
        
        self.economyBeaconTableView.register(UINib(nibName: "NearByBeaconCell", bundle: nil), forCellReuseIdentifier: "NearByBeaconCell")
        
        self.getEconomyParkingBecon()
        
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
    
   private func getEconomyParkingBecon(){
        
        for res in parkingSharedInstance.selectedLotDetail.slots{
            
            matchEconomyEnteryBecon(res)
        }
    }
    
    
   private func matchEconomyEnteryBecon(_ slot: slotModel){
        
        let parkin_bn = slot.parkingbeacons
        
        for res in parkingSharedInstance.beaconsDetails{
            
            for value in parkin_bn!{
                
                if value.stringValue == res._id{
                    
                    if (res.category ?? "").lowercased() == "economy"{
                        
                        self.nearbybeacons.append(res)
                    }
                }
            }
        }
    }
    

//MARK:- CLLocation MAnager Delegate
//MARK:-  -------------------------------------------------------------------------------

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if beacons.count == 0{
            
            self.economyBecons.removeAll()
            
            self.economy.removeAll()
            
            self.economyBeaconTableView.reloadData()
            
        }
        
        for val in beacons{
            
            let minor = Int(val.minor)
            
            let major = Int(val.major)
            
            if self.nearbybeacons.count != 0{
                
                for res in self.nearbybeacons{
                    
                     let resBnMinor = res.bn_minor
                    
                     let resBnMajor = res.bn_major
                    
                    if minor == resBnMinor && major == resBnMajor{
                        
                        if self.economy.contains(minor ){
                            
                        }
                        else{
                            
                            self.economy.insert(minor , at: 0)
                            
                            self.economyBecons.insert(res, at: 0)
                            
                        }
                        
                        self.economyBeaconTableView.reloadData()
                    }
                }
            }
        }
    }
}


//MARK:- Table iew delegate and datasource
//MARK:-  -------------------------------------------------------------------------------

extension EconomyBeaconVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.economyBecons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearByBeaconCell", for: indexPath) as! NearByBeaconCell
        
        let data = economyBecons[indexPath.row]
        
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
        
        let str = self.economyBecons[indexPath.row].bn_name ?? ""
        
         let beaconName = str.uppercased()
        
        delegate.getBeaconId(self.economyBecons[indexPath.row]._id ?? "", catagory: "Economy")
        
        userDefaults.set(parkingCatagories.economy, forKey: NSUserDefaultsKeys.CATAGORY)
        
        if ((self.parent?.isKind(of: NearbyBeaconVC.self)) != nil){
            
            (self.parent as? NearbyBeaconVC)?.popUpBGView.isHidden = false
            
            (self.parent as? NearbyBeaconVC)?.welcomeLbl.text = "CAR PARKED AT BEACON \(beaconName)"
            
            (self.parent as? NearbyBeaconVC)?.locationManager.stopMonitoring(for: ((self.parent as? NearbyBeaconVC)?.region)!)
            
            (self.parent as? NearbyBeaconVC)?.beaconManager.stopMonitoring(for: ((self.parent as? NearbyBeaconVC)?.region)!)

        }
    }
}
