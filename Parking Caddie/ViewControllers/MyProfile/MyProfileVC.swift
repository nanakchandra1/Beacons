//
//  MyProfileVC.swift
//  Parking Caddie
//
//  Created by Appinventiv on 01/03/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import Photos
import SDWebImage

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum addDeleteVehicles{
    
  case noVehicle,firstLoad,none

}
enum textfieldEditingState{

    case enable,disable
}

enum ProfileState {
    case norma,selectVehicle
}


class MyProfileVC: UIViewController,getMobileDelegate,UITextFieldDelegate {
    
    //MARK:- Properties
    //MARK:- ****************************************************
    
    
    var picker = UIImagePickerController()
    var tapGasture: UITapGestureRecognizer!
    var ProfilePic = UIImageView()
    var isImage = false
    var imageCache = ""

    var blurredImage : UIImage?
    
    var car_nameArr = [String]()
    var car_noArr = [String]()
    var userInfo = JSONDictionary()
    
    var vehicleAddDelete:addDeleteVehicles = .none
    var textfieldstate:textfieldEditingState = .disable
    var profileState:ProfileState = .norma
    
    
    //MARK:- OUTLETS
    //MARK:- ****************************************************
    
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var myProfileTableView: UITableView!
    @IBOutlet weak var profileEdidtBtn: UIButton!
    @IBOutlet weak var myProfileLbl: UILabel!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var notificationLbl: UILabel!
    @IBOutlet weak var myprofileTableBottomConst: NSLayoutConstraint!
    
    
    
    //MARK:- View LifeCycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getUserDataFromDataBase()
        if APPDELEGATEOBJECT.pushCount == 0{
            self.notificationLbl.isHidden = true
        }
        self.notificationLbl.text = "\(APPDELEGATEOBJECT.pushCount)"
        self.notificationLbl.layer.cornerRadius = 20 / 2
        self.notificationLbl.layer.masksToBounds = true
        self.picker.delegate = self
        self.myProfileTableView.delegate = self
        self.myProfileTableView.dataSource = self
        self.myProfileTableView.separatorStyle = .none
        tapGasture = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.dismissKeyboard(_:)))
        self.myProfileTableView.layer.cornerRadius = 3
        
        if self.profileState == ProfileState.selectVehicle{
            
            self.myprofileTableBottomConst.constant = 0
            self.notificationBtn.isHidden = true
            self.profileEdit()
        }
        else{
           // CommonClass.startLoader()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if parkingSharedInstance.upgrade == 1{
            let indexPath = IndexPath(row: 2, section: 0)
            self.myProfileTableView.reloadRows(at: [indexPath], with: .fade)
            parkingSharedInstance.upgrade = 0
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification:Notification!) -> Void in
            
            self.view.addGestureRecognizer(self.tapGasture)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
                                                                
                                                                queue: OperationQueue.main) {_ in
                                                                    
                                                                    self.view.removeGestureRecognizer(self.tapGasture)
        }
        
        self.car_nameArr.removeAll()
        self.car_noArr.removeAll()
        if CurrentUser.vehicles?.count > 0{
            for key in (CurrentUser.vehicles?.keys)!{
                self.car_nameArr.append(key)
            }
            
            for value in (CurrentUser.vehicles?.values)!{
                self.car_noArr.append(value as! String)
            }
            self.vehicleAddDelete = .firstLoad
        }
        else{
            self.vehicleAddDelete = .noVehicle
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Methods
    //MARK:- *************************************************************
    
    func dismissKeyboard(_ sender: AnyObject){
        self.view.endEditing(true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    func getUserDataFromDataBase(){
        
        self.userInfo["mobile"] = CurrentUser.mobile! as AnyObject
        self.userInfo["name"] = CurrentUser.fullName as AnyObject
        self.userInfo["lacation"] = CurrentUser.userLocation as AnyObject
        self.textfieldstate = .disable
        if let _ = CurrentUser.userImage{
            self.userInfo["imageurl"] = "\(imageBaseURL)\(CurrentUser.userImage!)" as AnyObject
            self.isImage = false
        }
    }
    
    // Delegate method for get mobile no. and country code
    
    func getMobile(_ code: String!, mobile: String!) {
        self.userInfo["mobile"] = mobile as AnyObject
        self.userInfo["code"] = code as AnyObject
        let indexPath = IndexPath(row: 2, section: 0)
        self.myProfileTableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    
    //on tap delete vehicle button
    
    func onTapDeleteBtn(_ sender: UIButton){
        
        let indexPah = sender.tableViewIndexPath(self.myProfileTableView)
        
        let alert = UIAlertController(title: "Alert", message: myAppconstantStrings.deleteVehicle, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            alertAction in self.deletRow(indexPah!)
            self.myProfileTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // delete vehicles method
    
    func deletRow(_ indexPath:IndexPath){
        
        self.car_nameArr.remove(at: indexPath.row)
        self.car_noArr.remove(at: indexPath.row)
        
        if self.car_nameArr.count == 0{
            self.vehicleAddDelete = .noVehicle
        }
    }
    
    
    
    //on tap add vehecles button
    
    func onTapAddBtn(_ sender: UIButton){
        self.view.endEditing(true)
        if self.vehicleAddDelete == .noVehicle{
            self.car_nameArr.append("")
            self.car_noArr.append("")
            self.vehicleAddDelete = .firstLoad
        }
        else{
            if self.car_nameArr.last == "" || self.car_noArr.last == ""{
                AppDelegate.showToast(myAppconstantStrings.carName_plate)
            }
            else{
                if  self.matchCarname(self.car_nameArr.last!) > 1 || self.matchCarNo(self.car_noArr.last!) > 1{
                    if self.matchCarname(self.car_nameArr.last!) > 1{
                        AppDelegate.showToast(myAppconstantStrings.diff_carName)
                        self.car_nameArr.removeLast()
                        self.car_nameArr.append("")
                    }
                    else if self.matchCarNo(self.car_noArr.last!) > 1{
                        AppDelegate.showToast(myAppconstantStrings.diff_carNo)
                        self.car_noArr.removeLast()
                        self.car_noArr.append("")
                    }
                }
                else{
                    self.car_nameArr.append("")
                    self.car_noArr.append("")
                }
            }
        }
        self.myProfileTableView.reloadData()    }
    
    
    func matchCarname(_ str:String) -> Int{
        
        var no_duplicate = 0
        for res in self.car_nameArr{
            
            if res == str{
                no_duplicate += 1
            }
        }
        return no_duplicate
        
    }
    
    func matchCarNo(_ str:String) -> Int{
        var no_duplicate = 0
        for res in self.car_noArr{
            if res == str{
                no_duplicate += 1
            }
        }
        return no_duplicate
        
    }
    
    
    
    // validation of text field
    
    func validateInfo(_ textField :UITextField,string : String,range:NSRange) -> Bool {
        let  cellIndexPath = textField.tableViewIndexPath(self.myProfileTableView)
        
        if range.length == 1 {
            return true
        }
        if cellIndexPath?.section == 1{
            let cell = self.myProfileTableView.cellForRow(at: cellIndexPath!) as! AddVehecles
            
            if textField == cell.plateNoTextField || textField == cell.myCarTextField{
                if (string == " ") {
                    return false
                }
                return true
            }
        }
        return true
    }
    
    
    
    
    
    //MARK:- Button Actions
    //MARK:- ******************************************************
    
    
    @IBAction func onTapNotificationBtn(_ sender: UIButton) {
        
        let obj = settingsStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
            
            self.view.addSubview(obj.view)
            self.addChildViewController(obj)
            obj.willMove(toParentViewController: self)
        }) 
    }
    
    
    @IBAction func onTapEditProfilePen(_ sender: UIButton) {
        self.profileEdit()
    }
    
    
    func profileEdit(){
        self.view.endEditing(true)
        if CurrentUser.parkingStaus == nil{
            if self.textfieldstate == .disable{
                self.profileEdidtBtn.setImage(UIImage(named: "profile_edit_tick"), for: UIControlState())
                self.textfieldstate = .enable
                self.myProfileTableView.reloadData()
            }
            else
            {
                if String(describing: self.userInfo["name"]).characters.count == 0{
                    AppDelegate.showToast(myAppconstantStrings.enterName)
                    self.setProfileEditButtnImage()
                    return
                }
                else if String(describing: self.userInfo["lacation"]).characters.count == 0{
                    AppDelegate.showToast(myAppconstantStrings.enterCity)
                    self.setProfileEditButtnImage()
                    return
                }
                else if self.car_nameArr.count > 0{
                    if self.car_nameArr.last!.characters.count == 0{
                        AppDelegate.showToast(myAppconstantStrings.entercarName)
                        self.setProfileEditButtnImage()
                        return
                    }
                    else if self.car_noArr.last!.characters.count == 0{
                        AppDelegate.showToast(myAppconstantStrings.enterPlateNo)
                        self.setProfileEditButtnImage()
                        return
                    }
                    else if  self.matchCarname(self.car_nameArr.last!) > 1 || self.matchCarNo(self.car_noArr.last!) > 1{
                        if self.matchCarname(self.car_nameArr.last!) > 1{
                            AppDelegate.showToast(myAppconstantStrings.diff_carName)
                            self.car_nameArr.removeLast()
                            self.car_nameArr.append("")
                            self.myProfileTableView.reloadRows(at: [IndexPath(row: self.car_nameArr.count - 1, section: 1)], with: UITableViewRowAnimation.none)
                            self.setProfileEditButtnImage()
                            return
                        }
                        else if self.matchCarNo(self.car_noArr.last!) > 1{
                            AppDelegate.showToast(myAppconstantStrings.diff_carNo)
                            self.car_noArr.removeLast()
                            self.car_noArr.append("")
                            self.myProfileTableView.reloadRows(at: [IndexPath(row: self.car_nameArr.count - 1, section: 1)], with: UITableViewRowAnimation.none)
                            self.setProfileEditButtnImage()
                            return
                        }
                    }
                    else{
                        self.editProfileWebService()
                    }
                }
                else{
                    self.editProfileWebService()
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "You can not edit profile", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func editProfileWebService(){
        
        var vehicleDetail = [String:AnyObject]()
        
        for (index,_) in self.car_nameArr.enumerated(){
            vehicleDetail[self.car_nameArr[index]] = self.car_noArr[index] as AnyObject
        }
        var data = Data()
        do {
            
            data = try JSONSerialization.data(
                withJSONObject: vehicleDetail ,
                options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        catch{
            
           // print_debug("error")
        }
        
        let paramData = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        var params = JSONDictionary()
        
        
                params["action"]    = "profile"
                params["full_name"] = self.userInfo["name"]
                params["location"]  = self.userInfo["lacation"]
                params["vehicles"]  = paramData
        
        var image:[String: UIImage]?

        if self.isImage{
        
            image = ["user_image": self.ProfilePic.image!]
        }
        
        CommonClass.startLoader()
        WebserviceController.editProfile(params, image: image, isImageAvailable: self.isImage, succesBlock: { (success, json) in
            
            let msg = json["message"].stringValue
            
            AppDelegate.showToast(msg)

            if success{
            
                let userDetail = UserData(withJson: json["result"])
                
                if let image = userDetail.image{
                    
                    self.userInfo["imageurl"] = "\(imageBaseURL)\(image)" as AnyObject
                    let imageUrl = URL(string: self.userInfo["imageurl"] as! String)

                    self.ProfilePic.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "signup_placeholder"))
                    self.isImage = true
                }
                else{
                    self.ProfilePic.sd_setImage(with: nil, placeholderImage: UIImage(named: "signup_placeholder"))
                }
                self.textfieldstate = .disable
                self.profileEdidtBtn.setImage(UIImage(named: "profile_editpen"), for: UIControlState())
                self.myProfileTableView.reloadData()
                if self.profileState == ProfileState.selectVehicle{
                    self.navigationController?.popViewController(animated: true)
                }

            }
            
        }) { (error) in
            
            
        }
}
    
    
    func setProfileEditButtnImage(){
        
        self.profileEdidtBtn.setImage(UIImage(named: "profile_edit_tick"), for: UIControlState())
    }
    
    
    
    func onTapChangeBtn(_ sender:UIButton){
        if sender.isSelected{
            sender.isSelected = !sender.isSelected
            guard let code =  self.userInfo["couponcCode"] as? String, code.characters.count > 0 else{
                AppDelegate.showToast("Enter coupon code")
                return
            }
            self.varifyCouponCode()
        }
        else{
            sender.isSelected = !sender.isSelected
            self.myProfileTableView.reloadData()
        }
        
        
    }
    
    func varifyCouponCode(){
        
        var params = JSONDictionary()
        
        params["coupon"] = self.userInfo["couponcCode"]
        params["pa_id"] =  ""
        
        WebserviceController.verifyCoupon(params, succesBlock: { (success, json) in
            
            if success{
            
                let result = json["result"].dictionary ?? [:]
                let id = result["_id"]?.stringValue
                userDefaults.set(id, forKey: NSUserDefaultsKeys.COUPON_ID)
            }
            
        }) { (error) in
            
        }
  
    }
    
    
    
    func updateCoupunCode(){
        
        var params = JSONDictionary()
        
        params["action"] = "coupon"
        params["coupon_code"] = self.userInfo["couponcCode"]
        params["coupon_id"] = CurrentUser.coupon_id
        
        WebserviceController.changeCouponCodeService(params, successBlock: { (success, json) in
            
            if success{
            
                let result = json["result"].dictionary ?? [:]
                let coupon = result["coupon_code"]?.stringValue
                userDefaults.set(coupon, forKey: NSUserDefaultsKeys.COUPONCODE)
                
            }
            
        }) { (error) in
            
        }
        
        self.myProfileTableView.reloadData()
    }
    
    // on tap change mobile button
    
    func onTapChangeMobile(_ sender:UIButton){
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "UpdateMobileVC") as! UpdateMobileVC
        obj.delegate = self
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    
    //MARK:- Pick image from gallery
    //MARK:- ****************************************************
    
    func onTapProfilepic(_ sender:UIButton){
        
        self.OpenActionSheet(sender: sender)
    }
    
    
    
    // fix image if image rotate automatically
    
    func fixOrientationforImage(_ image: UIImage) -> UIImage {
        
        if image.imageOrientation == UIImageOrientation.up {
            return image
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch image.imageOrientation {
            
        case .up,.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi))
            
        default:
            print_debug("")
        }
        switch image.imageOrientation {
        case .upMirrored,.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored,.rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            print_debug("")
        }
        let ctx: CGContext = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: (image.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (image.cgImage)!.colorSpace!, bitmapInfo: (image.cgImage)!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        switch image.imageOrientation {
        case .left,.leftMirrored,.right,.rightMirrored:
            ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)
        return img
    }
    
    
    
    
    
    //MARK:- Tetfield delegate
    //MARK:- *******************************************************
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let  cellIndexPath = textField.tableViewIndexPath(self.myProfileTableView){
            if cellIndexPath.section == 1{
                let cell = self.myProfileTableView.cellForRow(at: cellIndexPath) as! AddVehecles
                
                if cell.myCarTextField == textField{
                    if !self.car_nameArr.isEmpty{
                        self.car_nameArr.removeLast()
                        self.car_nameArr.append(textField.text!)
                    }
                }
                else if cell.plateNoTextField == textField{
                    if !self.car_noArr.isEmpty{
                        self.car_noArr.removeLast()
                        self.car_noArr.append(textField.text!)
                    }
                }
            }
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        CommonClass.delay(0.1) { () -> () in
            if let  cellIndexPath = textField.tableViewIndexPath(self.myProfileTableView){
                if cellIndexPath.section == 0{
                    if cellIndexPath.row == 1{
                        self.userInfo["name"] = textField.text! as AnyObject
                    }
                    if cellIndexPath.row == 4{
                        self.userInfo["lacation"] = textField.text! as AnyObject
                    }
                    if cellIndexPath.row == 5{
                        self.userInfo["couponcCode"] = textField.text! as AnyObject
                    }
                }
            }
        }
        return self.validateInfo(textField,string: string,range:range)
    }
    
}



//MARK:- UIImage pickerview delegate Methods
//MARK:- ===================================

extension MyProfileVC :UIImagePickerControllerDelegate , UIAlertViewDelegate , UINavigationControllerDelegate , UIPopoverControllerDelegate {
    
    
    func OpenActionSheet(sender : UIButton){
        
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default){
            
            UIAlertAction in
            
            self.openCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default){
            
            UIAlertAction in
            
            self.openGallary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel){
            
            UIAlertAction in
        }
        
        alert.addAction(cameraAction)
        
        alert.addAction(galleryAction)
        
        alert.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            
            self.present(alert, animated: true, completion: nil)
            
        }else{
            
            if let popoverController = alert.popoverPresentationController {
                
                popoverController.sourceView = sender
                
                popoverController.sourceRect = sender.bounds
                
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus){
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            
        }else{
            
            alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
        }
    }
    
    
    //MARK:- CAMERA & GALLERY NOT ALLOWING ACCESS - ALERT
    func alertToEncourageCameraAccessWhenApplicationStarts(){
        //Camera not available - Alert
        let internetUnavailableAlertController = UIAlertController (title: "", message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            
            if let url = settingsUrl {
                
                UIApplication.shared.openURL(url as URL)
                
            }
        }
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        internetUnavailableAlertController .addAction(settingsAction)
        
        internetUnavailableAlertController .addAction(cancelAction)
        
        self.present(internetUnavailableAlertController, animated: true, completion: nil)
        
        
    }
    
    func alertToEncouragePhotoLibraryAccessWhenApplicationStarts(){
        
        //Photo Library not available - Alert
        let cameraUnavailableAlertController = UIAlertController (title: "Not Available", message: nil , preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            
            if let url = settingsUrl {
                
                UIApplication.shared.openURL(url as URL)
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        cameraUnavailableAlertController .addAction(settingsAction)
        
        cameraUnavailableAlertController .addAction(cancelAction)
        
        self.present(cameraUnavailableAlertController, animated: true, completion: nil)
        
        
    }
    
    
    
    func openCamera(){
        
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch authorizationStatus {
            
        case .notDetermined:
            
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { (granted:Bool) -> Void in
                                            if granted {
                                            }
                                            else {
                                            }
            })
            
        case .authorized:
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                
                picker.sourceType = UIImagePickerControllerSourceType.camera
                
                picker.allowsEditing = true
                
                self.present(picker, animated: true, completion: nil)
                
            }else{
                
                openGallary()
            }
            
        case .denied, .restricted:
            
            alertToEncourageCameraAccessWhenApplicationStarts()
            
        default: break
            
        }
        
    }
    
    
    
    func openGallary() {
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
            
        }else{
            
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let cell = self.myProfileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProfilePicCell

        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            self.ProfilePic.image = fixOrientationforImage(pickedImage)
            cell.profileImage.image = self.ProfilePic.image
            cell.coverImage.image = self.ProfilePic.image!.blurredImage(4,times: 100)
            self.blurredImage = cell.coverImage.image

            cell.bgView.backgroundColor = UIColor(red: 96.0/255.0, green: 96.0/255.0, blue: 96.0/255.0, alpha: 0.5)
            self.isImage = true
            self.myProfileTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
        }
        self.dismiss(animated: true, completion: nil)

    }
    
}


//MARK:- Tableview datasource and delegate
//MARK:- *******************************************************

extension MyProfileVC: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            
            if self.textfieldstate == .disable{
                
                return 7
            }
            else{
            
                return 6
            }
        }
        else{
            return  self.car_nameArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        self.myProfileTableView.register(UINib(nibName: "ProfilePicCell", bundle: nil), forCellReuseIdentifier: "ProfilePicCell")
                self.myProfileTableView.register(UINib(nibName: "SignUpTableviewCell", bundle: nil), forCellReuseIdentifier: "SignUpTableviewCell_ID")
                self.myProfileTableView.register(UINib(nibName: "MyVehicleCell", bundle: nil), forCellReuseIdentifier: "MyVehicleCell")
        
        if self.textfieldstate == .disable{
            if indexPath.section == 0{
                switch indexPath.row{
                    
                case 0:
                    let cell  = tableView.dequeueReusableCell(withIdentifier: "ProfilePicCell", for: indexPath) as! ProfilePicCell
                    cell.setupSubviews()
                    

                    
                    if let imageUrl = URL(string: imageBaseURL + CurrentUser.userImage!) {
                        
                        print_debug(imageUrl)
                        cell.profileImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "signup_placeholder"), options: [], completed: { (image, error, _, url) in
                            
                            if error == nil {
                                
                                let cacheKey = ("userBlurredImage" + (CurrentUser.userImage ?? ""))
                                self.imageCache = (CurrentUser.userImage ?? "")
                                
                                SDImageCache.shared().queryCacheOperation(forKey: cacheKey, done: { (cachedImage, data, _) in
                                    
                                    if cachedImage != nil {
                                        
                                        cell.coverImage.image = cachedImage
                                        
                                    } else {
                                        
                                        SDImageCache.shared().store(image?.blurEffect(60), forKey: cacheKey)
                                        cell.coverImage.image = image?.blurEffect(60)
                                    }

                                })
                            }
                        })
                    }
                    else{
                        cell.coverImage.backgroundColor = UIColor.black
                    }

                    cell.profilePicEditBtn.isUserInteractionEnabled = false
                    cell.profilePicEditBtn.addTarget(self, action: #selector(MyProfileVC.onTapProfilepic(_:)), for: .touchUpInside)
                    return cell
                    
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.containerView.roundCorners([.topLeft,.topRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 73))

                    cell.nameLbl.text = "FULL NAME"
                    cell.nameTextField.text = CurrentUser.fullName
                    cell.nameTextField.isEnabled = false
                    cell.showBtn.isHidden = true
                    return cell
                    
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.nameLbl.text = "MOBILE NUMBER"
                    cell.nameTextField.text = self.userInfo["mobile"] as? String
                    cell.nameTextField.isEnabled = false
                    cell.showBtn.isHidden = false
                    cell.showBtnTrailingContraint.constant = 7
                    cell.nameTextField.delegate = self
                    cell.showBtn.setImage(UIImage(named: "profile_editpen"), for: UIControlState())
                    cell.showBtn.addTarget(self, action: #selector(MyProfileVC.onTapChangeMobile(_:)), for: .touchUpInside)
                    return cell
                    
                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.nameLbl.text = "EMAIL ADDRESS"
                    cell.nameTextField.text = CurrentUser.userEmail

                    cell.nameTextField.isEnabled = false
                    cell.showBtn.isHidden = true
                    return cell
                    
                case 4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.nameLbl.text = "YOUR CITY"
                    cell.nameTextField.text = CurrentUser.userLocation
                    
                    cell.nameTextField.isEnabled = false
                    cell.showBtn.isHidden = true
                    
                    return cell
    
                case 5:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "codeCell", for: indexPath) as! codeCell
                    cell.discountCodeLbl.text = "DISCOUNT CODE"
                    cell.changeBtn.addTarget(self, action: #selector(MyProfileVC.onTapChangeBtn(_:)), for: UIControlEvents.touchUpInside)
                    
                    if  !cell.changeBtn.isSelected{
                        cell.codeLbl.isEnabled = false
                        cell.codeLbl.delegate = self
                        if let coupon_code = CurrentUser.couponCode, !coupon_code.isEmpty{
                            cell.codeLbl.text = coupon_code
                        }
                        else{
                            cell.codeLbl.placeholder = "No Discount Coupon"

                        }

                         cell.changeBtn.setTitle("CHANGE", for: UIControlState())
                         cell.changeBtn.setImage(UIImage(named: ""), for: UIControlState())
                        
                         cell.changeBtn.layer.borderColor = UIColor.appBlue.cgColor
                         cell.changeBtn.layer.borderWidth = 1
                         cell.changeBtn.layer.cornerRadius = 2
                        
                        
                    }
                    else{
                        cell.codeLbl.isEnabled = true
                        cell.codeLbl.delegate = self

                        if let coupon_code = CurrentUser.couponCode{
                            cell.codeLbl.text = coupon_code
                        }
                        else{
                            cell.codeLbl.placeholder = "No Discount Coupon"
                            
                        }

                         cell.changeBtn.setImage(UIImage(named: "profile_edit_tick"), for: UIControlState())
                         cell.changeBtn.setTitle("", for: UIControlState())
                         cell.changeBtn.layer.borderColor = UIColor.clear.cgColor
                         cell.changeBtn.layer.borderWidth = 0
                         cell.changeBtn.layer.cornerRadius = 0
                    }
                    return cell
                case 6:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MyVehecles", for: indexPath) as! MyVehecles
                    cell.addVeheclesBtn.isHidden = true
                    cell.containerView.roundCorners([.bottomLeft,.bottomRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 50))
                    return cell
                default:
                    fatalError("Invalid Cell")
                }
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddVehecles", for: indexPath) as! AddVehecles
                cell.myCarTextField.text = self.car_nameArr[indexPath.row]
                cell.plateNoTextField.text = self.car_noArr[indexPath.row]
                cell.deleteVeheclesBtn.isHidden = true
                cell.myCarTextField.isEnabled = false
                cell.plateNoTextField.isEnabled = false
                cell.contentView.roundCorners([.topLeft,.topRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 40))
                if indexPath.row == self.car_nameArr.count - 1{
                    cell.seperator.isHidden = true
                }
                else{
                    cell.seperator.isHidden = false
                }
                return cell
            }
        }
        else{
            if indexPath.section == 0{
                switch indexPath.row{
                case 0:
                    let cell  = tableView.dequeueReusableCell(withIdentifier: "ProfilePicCell", for: indexPath) as! ProfilePicCell
                    cell.profilePicEditBtn.isUserInteractionEnabled = true
                    if self.ProfilePic.image != nil{
                        cell.profileImage.image = self.ProfilePic.image
                        if self.blurredImage != nil{
                            cell.coverImage.image = self.blurredImage
                        }
                        else{
                            cell.coverImage.image = cell.profileImage.image!.blurredImage(4,times: 100)
                            self.blurredImage = cell.coverImage.image
                        }
                    }

                    cell.profilePicEditBtn.addTarget(self, action: #selector(MyProfileVC.onTapProfilepic(_:)), for: .touchUpInside)
                    return cell
                    
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.nameLbl.text = "FULL NAME"
                    cell.nameTextField.text = self.userInfo["name"] as? String
                    cell.nameTextField.isEnabled = true
                    cell.nameTextField.delegate = self
                    cell.showBtn.isHidden = true
                    return cell
                    
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.nameLbl.text = "MOBILE NUMBER"
                    cell.nameTextField.text = self.userInfo["mobile"] as? String
                    cell.nameTextField.isEnabled = false
                    cell.showBtn.isHidden = false
                    cell.showBtnTrailingContraint.constant = 7
                    cell.nameTextField.delegate = self
                    cell.showBtn.setImage(UIImage(named: "profile_editpen"), for: UIControlState())
                    cell.showBtn.addTarget(self, action: #selector(MyProfileVC.onTapChangeMobile(_:)), for: .touchUpInside)
                    return cell
                    
                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.nameLbl.text = "EMAIL ID"
                    cell.nameTextField.isEnabled = false
                    cell.nameTextField.text = CurrentUser.userEmail
                    cell.nameTextField.delegate = self
                    cell.showBtn.isHidden = true
                    return cell
                    
                case 4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpTableviewCell_ID", for: indexPath) as! SignUpTableviewCell
                    cell.nameLbl.text = "YOUR CITY"
                    cell.nameTextField.text = CurrentUser.userLocation
                    cell.nameTextField.isEnabled = true
                    cell.nameTextField.delegate = self
                    cell.showBtn.isHidden = true
                    return cell
                case 5:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MyVehecles", for: indexPath) as! MyVehecles
                    if self.car_nameArr.count == 5{
                        cell.addVeheclesBtn.isHidden = true
                    }
                    else{
                        cell.addVeheclesBtn.isHidden = false
                    }
                    if self.car_nameArr.count == 0{
                        cell.containerView.roundCorners([.bottomLeft,.bottomRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 50))
                    }
                    cell.addVeheclesBtn.addTarget(self, action: #selector(MyProfileVC.onTapAddBtn(_:)), for: .touchUpInside)
                    return cell
                default:
                    fatalError("Invalid Cell")
                }
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddVehecles", for: indexPath) as! AddVehecles
                cell.deleteVeheclesBtn.addTarget(self, action: #selector(MyProfileVC.onTapDeleteBtn(_:)), for: .touchUpInside)
                    cell.myCarTextField.delegate = self
                    cell.plateNoTextField.delegate = self
                cell.deleteVeheclesBtn.isHidden = false
                cell.myCarTextField.text = self.car_nameArr[indexPath.row]
                cell.plateNoTextField.text = self.car_noArr[indexPath.row]
                cell.contentView.roundCorners([.topLeft,.topRight], radius: 3.0,rect: CGRect(x: 0, y: 0, width: Constants.screenwidth - 20, height: 40))
                if self.car_noArr[indexPath.row] == "" && self.car_nameArr[indexPath.row] == ""{
                    cell.myCarTextField.becomeFirstResponder()
                    cell.plateNoTextField.resignFirstResponder()
                }
                if self.car_noArr[indexPath.row] == "" || self.car_nameArr[indexPath.row] == ""{
                    if self.car_nameArr.last == ""{
                        cell.myCarTextField.becomeFirstResponder()
                        cell.plateNoTextField.resignFirstResponder()
                    }
                    else{
                        cell.myCarTextField.resignFirstResponder()
                        cell.plateNoTextField.becomeFirstResponder()
                    }
                    cell.myCarTextField.isEnabled = true
                    cell.plateNoTextField.isEnabled = true
                }
                else{
                    cell.myCarTextField.isEnabled = false
                    cell.plateNoTextField.isEnabled = false
                }
                if indexPath.row == self.car_nameArr.count - 1{
                    cell.seperator.isHidden = true
                }
                else{
                    cell.seperator.isHidden = false
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.textfieldstate == .disable{
            if indexPath.section == 0{
                switch indexPath.row{
                case 0:
                    return UIScreen.main.bounds.height / 3
                    
                case 1,2,3,4:
                    return 73
                case 5:
                    return 73
                    
                default :
                    return 50
                }
            }
            else{
                return 40
            }
        }
        else{
            if indexPath.section == 0{
                switch indexPath.row{
                case 0:
                    return UIScreen.main.bounds.height / 3
                    
                case 1,2,3,4:
                    return 73
                default :
                    return 50
                }
            }
            else{
                return 40
            }

        
        }
    }
    
}



//MARK:- Table View cell class
//MARK:- *******************************************************

class MyVehecles: UITableViewCell{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var myVeheclesLbl: UILabel!
    @IBOutlet weak var addVeheclesBtn: UIButton!
    
}


class AddVehecles: UITableViewCell{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var myCarTextField: UITextField!
    @IBOutlet weak var plateNoTextField: UITextField!
    @IBOutlet weak var deleteVeheclesBtn: UIButton!
    @IBOutlet weak var seperator: UIView!
    
}

class codeCell:UITableViewCell{

    @IBOutlet weak var discountCodeLbl: UILabel!
    
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var codeLbl: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var seperatorView: UIView!

}
