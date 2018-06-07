
//
//  blurImageExtension.swift
//  ActivityFeedScreen_Veme
//
//  Created by Amit Singh on 2/16/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import QuartzCore
import Accelerate

//MARK:- Extension for Blur Image
//MARK:- ************************************

final class Constants {
    
    static let screensize = UIScreen.main.bounds
    static let screenwidth = UIScreen.main.bounds.width
    static let screenheight = UIScreen.main.bounds.height
    static let Google_Map_Api_Key = "AIzaSyAfimL4BgKmUcIU1PfxkPr6lW_SEnpCKb0"
    
}


extension UIImage {
    
    class func blurEffect(_ cgImage: CGImage) -> UIImage! {
        return UIImage(cgImage: cgImage)
    }
    
    func blurEffect(_ boxSize: Float) -> UIImage! {
        return UIImage(cgImage: blurredCGImage(boxSize))
    }
    
    func blurredCGImage(_ boxSize: Float) -> CGImage! {
        return cgImage!.blurEffect(boxSize)
    }
    
    func resizeImage(_ newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func blurredImage(_ boxSize: Float, times: UInt = 1) -> UIImage {
        
        var image = self
        
        for _ in 0..<times {
            image = image.blurEffect(boxSize)
        }
        
        return image
    }
    
    func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch self.imageOrientation {
            
        case .up,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi))
            
        default: break
            
        }
        
        switch self.imageOrientation {
            
        case .upMirrored,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored,.rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default: break
            
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: (self.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (self.cgImage)!.colorSpace!, bitmapInfo: (self.cgImage)!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        switch self.imageOrientation {
            
        case .left,.leftMirrored,.right,.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
            
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)
        return img
    }
    
}

extension CGImage {
    
    func blurEffect(_ boxSize: Float) -> CGImage! {
        
        let boxSize = boxSize - (boxSize.truncatingRemainder(dividingBy: 2)) + 1
        
        let inProvider = self.dataProvider
        
        let height = vImagePixelCount(self.height)
        let width = vImagePixelCount(self.width)
        let rowBytes = self.bytesPerRow
        
        let inBitmapData = inProvider?.data
        let inData = UnsafeMutableRawPointer(mutating: CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
        
        let outData = malloc(self.bytesPerRow * self.height)
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
        
        _ = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        let context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self))
        let context = CGContext(data: outBuffer.data, width: Int(outBuffer.width), height: Int(outBuffer.height), bitsPerComponent: 8, bytesPerRow: outBuffer.rowBytes, space: colorSpace, bitmapInfo: self.bitmapInfo.rawValue)!
        let imageRef = context.makeImage()
        
        free(outData)
        
        return imageRef
    }
}


//MARK:- extension for next button in keybord
//MARK:- ************************************
private var kAssociationKeyNextField: UInt8 = 0

extension UITextField {
    var nextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField, newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}


//MARK:- extension for find indexpath of tableview cell
//MARK:- ************************************

extension UIView{
    func tableViewCell() -> UITableViewCell? {
        var tableViewcell : UIView? = self
        while(tableViewcell != nil)
        {
            if tableViewcell! is UITableViewCell {
                break
            }
            tableViewcell = tableViewcell!.superview
        }
        return tableViewcell as? UITableViewCell
    }
    
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat,rect:CGRect) {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.layer.mask = mask
    }
    
    func tableViewIndexPath(_ tableView: UITableView) -> IndexPath? {
        if let cell = self.tableViewCell() {
            return tableView.indexPath(for: cell)
        }
        else {
            return nil
        }
    }
    
    
    
    func collectionviewCell() -> UICollectionViewCell? {
        
        var collectionviewCell : UIView? = self
        
        while(collectionviewCell != nil)
        {
            
            if collectionviewCell! is UICollectionViewCell {
                break
            }
            
            collectionviewCell = collectionviewCell!.superview
        }
        
        return collectionviewCell as? UICollectionViewCell
        
    }
    
    func collectionViewIndexPath(_ collectionView: UICollectionView) -> IndexPath? {
        
        if let cell = self.collectionviewCell() {
            
            return collectionView.indexPath(for: cell)
            
        }
        else {
            
            return nil
            
        }
    }

    
    // add shadow of view
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 3
        self.layer.shouldRasterize = false
        
    }

}

//MARK:- extension for UIColor
//MARK:- ************************************

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

//MARK:- extension for Toast
//MARK:- ************************************

extension AppDelegate{
    class func showToast(_ message : String) {
        
        // Resign responder here
        
        let config: GTToastConfig = GTToastConfig(contentInsets: UIEdgeInsetsMake(5, 5, 5, 5), cornerRadius: 6.0, font: UIFont.systemFont(ofSize: 15.0), textColor: UIColor.black, backgroundColor: UIColor.white, displayInterval: 0.5, bottomMargin: 50.0)
        
        
        let toastFactory: GTToast = GTToast(config: config)
        
        toastFactory.create(message).show()
        
    }
}


//MARK:- extension for NSUserDefault
//MARK:- ************************************

extension UserDefaults {
    
    //MARK: UserDefault
    
    class func removeFromUserDefaultForKey(_ key:String) {
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    class func clearUserDefaults() {
        
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
        
    }
}

//
//extension UIImageView {
//    
//    func setImageWithStringURL(_ URL : String) {
//        
//        let URL = Foundation.URL(string: URL)!
//        
//        //        self.af_setImageWithURL(URL)
//        
//        self.setImageWith(URL)
//        
//    }
//    
//    
//    func setImageWithStringURL(_ URL : String, placeholder : UIImage, imageTransition : Bool = true) {
//        
//        if imageTransition {
//            
//            self.setImageWithStringURLWithAnimation(URL, placeholder: placeholder)
//            
//        } else {
//            
//            let URL = Foundation.URL(string: URL)!
//            
//            self.setImageWith(URL, placeholderImage: placeholder)
//            
//        }
//        
//    }
//    
//    fileprivate func setImageWithStringURLWithAnimation(_ URL : String, placeholder : UIImage) {
//        
//        let URL = Foundation.URL(string: URL)!
//        self.setImageWith(URL, placeholderImage: placeholder)
//        
//        // self.af_setImageWithURL( URL, placeholderImage: placeholder, filter: nil, imageTransition: .CrossDissolve(0.1))
//          }
//}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let val = self
        let divisor = Double(pow(10.0, Double(places)))
        return (val * divisor).rounded() / divisor
    }
}

extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}


extension Date {
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone: TimeZone = TimeZone.autoupdatingCurrent
        let seconds: TimeInterval = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone: TimeZone = TimeZone.autoupdatingCurrent
        let seconds: TimeInterval = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}



extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.barTintColor = UIColor.appBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}


extension Notification.Name {
    
    static let PayNowNotificationName = Notification.Name("PayNowNotificationName")
    static let setCardNoNotificationName = Notification.Name("NotificationIdentifier")

}
