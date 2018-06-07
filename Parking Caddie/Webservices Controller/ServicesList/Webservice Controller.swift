//
//  Webservice Controller.swift
//  Parking Caddie
//
//  Created by Anuj on 6/7/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias successBlock = ((Bool,JSON) -> Void)

typealias failureBlock = ((Error) -> Void)

let googleGeocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json"

class WebserviceController {
    
    class func signUp(_ params:JSONDictionary, image: [String:UIImage]?, isImageAvailable:Bool, succesBlock: @escaping successBlock,failureBlock: @escaping failureBlock) {
        
        AppNetworking.POSTWithImage(endPoint: signUpURL, parameters: params, image: image, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
                
            }else{
                
                succesBlock(false,json)
                
            }
            
            
        }, failure: { (error) in
            
            failureBlock(error)
        })
        
    }
    
    
    class func loginAPI(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: loginUrl, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    
    class func forgotPassword(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: forgotPassURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func loginScreenOtpConfirm(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POST(endPoint: verifymobileURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func getClientTokenAPI(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock) {
        
        AppNetworking.GET(endPoint: clientTokenURL, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true, json)
                
            }else{
                
                succesBlock(false, json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func payApi(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POST(endPoint: checkOutURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func resendOTP(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock) {
        
        AppNetworking.POST(endPoint: resendOtpURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func changePassword(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POST(endPoint: changePassURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func editProfile(_ params:JSONDictionary, image: [String:UIImage]?, isImageAvailable:Bool, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POSTWithImage(endPoint : editProfileURL, parameters :params, image : image, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) -> Void in
            
            failureBlock(error)
            
        }
    }
    
    
    class func changeCouponCodeService(_ params:JSONDictionary, successBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POSTWithImage(endPoint : editProfileURL, parameters :params, image : nil, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                successBlock(true,json)
                
            } else {
                
                successBlock(false,json)
            }
            
        }) { (error) -> Void in
            
            failureBlock(error)
            
        }
    }
    
    
    class func parkingLotDetailService(_ url: String, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.GET(endPoint : url, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func bringMyCarService(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.GET(endPoint : bringMycarURL, parameters : params, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func reservationService(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: reserveURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    class func ultimateValetService(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: ultimateValetURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func getParkingLots(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.GET(endPoint : parkingAreaIdURL, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func getParkingSlots(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: beaconURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func parkingHistoryService(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.GET(endPoint : historyURL, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func reservationHistoryService(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.GET(endPoint : ReservationURL, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func cancelReservation(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: cancelReservationURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func parkNowService(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: parkNowURL, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func staticPagesService(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: statcPageUrl, parameters: params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    class func logOutService(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: logOutURL , loader: true, success: { (json) in
            
            if json["code"].intValue == 200 || json["code"].intValue == 220{
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func changePasswordService(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: changePassURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func notificationService(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.GET(endPoint : notificationURL, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func promotionsService(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.GET(endPoint : promotionsURL, loader : true, success : { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func exitParkingService(_ params: JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: exitParkingURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func exitAlloewdService(_ succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.GET(endPoint : exitAllowedURL, loader : true, success : { (json) in
            
            
            if json["code"].intValue == 225 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func checkParkingStatus(_  succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: checkParkingStatusURL, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    class func verifyCoupon(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: verifyCouponURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    class func fetchData(withInput text: String,
                         success : @escaping successBlock,
                         failure : @escaping failureBlock) {
        
        let url =  "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        let param = ["input": text,"key" : googleApiKey, "type": [ "geocode", "establishment" ]] as [String : Any]
        
        
        AppNetworking.GET(endPoint: url, parameters: param, loader: false, success: { (json) in
            
            success(true, json)
            print_debug(json)
            
        }) { (error) in
            failure(error)
        }
    }
    
    class func fetchcoor(withPlaceID : String,
                         success : @escaping successBlock,
                         failure : @escaping failureBlock) {
        
        let googleGeocode = "https://maps.googleapis.com/maps/api/place/details/json"
        let placeID = withPlaceID  //"ChIJL_P_CXMEDTkRw0ZdG-0GVvw"
        
        let param = ["key" : "AIzaSyA-TmoDbBuqVgJPYZ_E0oMFX0A0f8a3Vec", "placeid" : placeID] as [String : Any]
        
        AppNetworking.GET(endPoint: googleGeocode, parameters: param, loader: true, success: { (json) in
            print_debug(json)
            
            success(true, json)
            
        }) { (error) in
            
        }
    }
    
    
    class func getAddressForLatLng(latitude: String, longitude: String, successBlock: @escaping successBlock) {
        
        let params = ["latlng": "\(latitude),\(longitude)", "key": googleApiKey]
        
        
        AppNetworking.GET(endPoint: googleGeocodeUrl, parameters: params as JSONDictionary, success: { (json: JSON) in
            print_debug(json)
            successBlock(true,json)
            
        }, failure: { (e : Error) in
            print_debug(e)
        })
        
    }
    
    
    class func pickMeUpAPI(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: requestpickupURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }

    class func addCardAPI(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: addCardURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
            print_debug(error)
        }
    }

    
    class func getCardAPI(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: listcardsURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }

    class func deleteCardAPI(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: deleteCardURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    class func makeDefaultCardAPI(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: makeDefaultCardURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }

    
    class func paymentReceiptAPI(_ params:JSONDictionary, succesBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: paymentReceiptURL, parameters : params, loader: true, success: { (json) in
            
            if json["code"].intValue == 200 {
                
                succesBlock(true,json)
                
            } else {
                
                succesBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
    }


}
