
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
    
    static let screensize = UIScreen.mainScreen().bounds
    static let screenwidth = UIScreen.mainScreen().bounds.width
    static let screenheight = UIScreen.mainScreen().bounds.height
    static let Google_Map_Api_Key = "AIzaSyAfimL4BgKmUcIU1PfxkPr6lW_SEnpCKb0"
    
}


extension UIImage {
    
    class func blurEffect(cgImage: CGImageRef) -> UIImage! {
        return UIImage(CGImage: cgImage)
    }
    
    func blurEffect(boxSize: Float) -> UIImage! {
        return UIImage(CGImage: blurredCGImage(boxSize))
    }
    
    func blurredCGImage(boxSize: Float) -> CGImageRef! {
        return CGImage!.blurEffect(boxSize)
    }
    
    func resizeImage(newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func blurredImage(boxSize: Float, times: UInt = 1) -> UIImage {
        
        var image = self
        
        for _ in 0..<times {
            image = image.blurEffect(boxSize)
        }
        
        return image
    }
    
    func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch self.imageOrientation {
            
        case .Up,.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case .Left,.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case .Right,.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            
        default: break
            
        }
        
        switch self.imageOrientation {
            
        case .UpMirrored,.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        case .LeftMirrored,.RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        default: break
            
        }
        
        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage).rawValue)!
        
        CGContextConcatCTM(ctx, transform)
        
        switch self.imageOrientation {
            
        case .Left,.LeftMirrored,.Right,.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage)
        }
        
        let cgimg: CGImageRef = CGBitmapContextCreateImage(ctx)!
        let img: UIImage = UIImage(CGImage: cgimg)
        return img
    }
    
}

extension CGImage {
    
    func blurEffect(boxSize: Float) -> CGImageRef! {
        
        let boxSize = boxSize - (boxSize % 2) + 1
        
        let inProvider = CGImageGetDataProvider(self)
        
        let height = vImagePixelCount(CGImageGetHeight(self))
        let width = vImagePixelCount(CGImageGetWidth(self))
        let rowBytes = CGImageGetBytesPerRow(self)
        
        let inBitmapData = CGDataProviderCopyData(inProvider)
        let inData = UnsafeMutablePointer<Void>(CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
        
        let outData = malloc(CGImageGetBytesPerRow(self) * CGImageGetHeight(self))
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
        
        _ = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        let context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self))
        let context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self).rawValue)!
        let imageRef = CGBitmapContextCreateImage(context)
        
        free(outData)
        
        return imageRef
    }
}


//MARK:- extension for net button in keybord
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
    
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat,rect:CGRect) {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        
        mask.path = path.CGPath
        
        self.layer.mask = mask
    }
    
    func tableViewIndexPath(tableView: UITableView) -> NSIndexPath? {
        if let cell = self.tableViewCell() {
            return tableView.indexPathForCell(cell)
        }
        else {
            return nil
        }
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
    class func showToast(message : String) {
        
        // Resign responder here
        
        let config: GTToastConfig = GTToastConfig(contentInsets: UIEdgeInsetsMake(5, 5, 5, 5), cornerRadius: 6.0, font: UIFont.systemFontOfSize(15.0), textColor: UIColor.blackColor(), backgroundColor: UIColor.whiteColor(), displayInterval: 0.5, bottomMargin: 50.0)
        
        
        let toastFactory: GTToast = GTToast(config: config)
        
        toastFactory.create(message).show()
        
    }
}


//MARK:- extension for NSUserDefault
//MARK:- ************************************

extension NSUserDefaults {
    //MARK: UserDefault
    
    class func save(value:AnyObject,forKey key:String)     {
        
        NSUserDefaults.standardUserDefaults().setObject(value, forKey:key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func userDefaultForKey(key:String) -> AnyObject? {
        
        if let value: AnyObject =  NSUserDefaults.standardUserDefaults().objectForKey(key) {
            
            return value
            
        } else {
            
            return nil
            
        }
    }
    
    class func userdefaultStringForKey(key:String) -> String? {
        
        if let value =  NSUserDefaults.standardUserDefaults().objectForKey(key) as? String {
            
            return value
            
        } else {
            
            return nil
            
        }
    }
    
    class func removeFromUserDefaultForKey(key:String) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    class func clearUserDefaults() {
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
}


extension UIImageView {
    
    func setImageWithStringURL(URL : String) {
        
        let URL = NSURL(string: URL)!
        
        //        self.af_setImageWithURL(URL)
        
        self.setImageWithURL(URL)
        
    }
    
    
    func setImageWithStringURL(URL : String, placeholder : UIImage, imageTransition : Bool = true) {
        
        if imageTransition {
            
            self.setImageWithStringURLWithAnimation(URL, placeholder: placeholder)
            
        } else {
            
            let URL = NSURL(string: URL)!
            
            self.setImageWithURL(URL, placeholderImage: placeholder)
            
        }
        
    }
    
    private func setImageWithStringURLWithAnimation(URL : String, placeholder : UIImage) {
        
        let URL = NSURL(string: URL)!
        self.setImageWithURL(URL, placeholderImage: placeholder)
        
        // self.af_setImageWithURL( URL, placeholderImage: placeholder, filter: nil, imageTransition: .CrossDissolve(0.1))
          }
}
