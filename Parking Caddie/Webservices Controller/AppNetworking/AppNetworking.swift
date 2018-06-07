
import Foundation
import SwiftyJSON
import Alamofire

typealias JSONArray = [JSON]
typealias JSONDict = [String:JSON]
typealias JSONDictionary = [String:Any]
typealias StringDictionary = [String:String]
typealias JSONDictionaryArray = [JSONDictionary]



extension Notification.Name {
    
    static let NotConnectedToInternet = Notification.Name("NotConnectedToInternet")
}

let loginData = "admin@parking.com:Pass@word1".data(using: String.Encoding.utf8)!
let base64LoginString = loginData.base64EncodedString(options: [])

var headers:[String:String]{
    
    if let token = CurrentUser.userToken{
        
        return ["Authorization": ("Basic "+base64LoginString),"Auth-Token":token]
    }
    return ["Authorization": ("Basic "+base64LoginString)]
    
}

enum AppNetworking {
    
    
    static func POST(endPoint : String,
                     parameters : JSONDictionary = [:],
                     loader : Bool = true,
                     success : @escaping (JSON) -> Void,
                     failure : @escaping (Error) -> Void) {
        
        
        request(URLString: endPoint, httpMethod: .post, parameters: parameters, loader: loader, success: success, failure: failure)
    }
    
    
    static func POSTWithImage(endPoint : String,
                              parameters : [String : Any] = [:],
                              image : [String:UIImage]? = [:],
                              loader : Bool = true,
                              success : @escaping (JSON) -> Void,
                              failure : @escaping (Error) -> Void) {
        
        upload(URLString: endPoint, httpMethod: .post, parameters: parameters,image: image , loader: loader, success: success, failure: failure )
    }
    
    
    static func GET(endPoint : String,
                    parameters : JSONDictionary = [:],
                    headers : HTTPHeaders = [:],
                    loader : Bool = true,
                    success : @escaping (JSON) -> Void,
                    failure : @escaping (Error) -> Void) {
        
        request(URLString: endPoint, httpMethod: .get, parameters: parameters, encoding: URLEncoding.queryString, loader: loader, success: success, failure: failure)
    }
    
    
    static func PUT(endPoint : String,
                    parameters : JSONDictionary = [:],
                    headers : HTTPHeaders = [:],
                    loader : Bool = true,
                    success : @escaping (JSON) -> Void,
                    failure : @escaping (Error) -> Void) {
        
        request(URLString: endPoint, httpMethod: .put, parameters: parameters, loader: loader, success: success, failure: failure)
    }
    
    static func DELETE(endPoint : String,
                       parameters : JSONDictionary = [:],
                       headers : HTTPHeaders = [:],
                       loader : Bool = true,
                       success : @escaping (JSON) -> Void,
                       failure : @escaping (Error) -> Void) {
        
        request(URLString: endPoint, httpMethod: .delete, parameters: parameters, loader: loader, success: success, failure: failure)
    }
    
    private static func request(URLString : String,
                                httpMethod : HTTPMethod,
                                parameters : JSONDictionary = [:],
                                encoding: URLEncoding = .httpBody,
                                loader : Bool = true,
                                success : @escaping (JSON) -> Void,
                                failure : @escaping (Error) -> Void) {
        
        if loader { () }
        
        let URLStr = URLString
        let basicAuth = headers
        print_debug(URLStr)
        print_debug(parameters)
        
        
        Alamofire.request(URLStr,
                          method: httpMethod,
                          parameters: parameters,
                          encoding: encoding,
                          headers: basicAuth).responseJSON { (response:DataResponse<Any>) in
                            
                            print_debug(basicAuth)
                            print_debug( String(data: response.data!, encoding: String.Encoding.utf8)!)
                            
                            if loader { CommonClass.stopLoader() }
                            
                            switch(response.result) {
                                
                            case .success(let value):
                                
                                let val = JSON(value)
                                
                                if val["code"].intValue == 227 {
                                    
                                    CommonClass.clearPrefrences()
                                    
                                }else{
                                
                                    print_debug(val)
                                    
                                    success(JSON(value))

                                }
                                
                                
                            case .failure(let e):
                                
                                if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                                    // Handle Internet Not available UI
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                    // showToastWithMessage(msg: "No Internet Connection")
                                    
                                }
                                
                                if (e as NSError).code == NSURLErrorNetworkConnectionLost {
                                    // Handle Internet Not available UI
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                    //showToastWithMessage(msg: "No Internet Connection")
                                    
                                }
                                
                                if (e as NSError).code == NSURLErrorTimedOut {
                                    // Handle Internet Not available UI
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                    // showToastWithMessage(msg: "No Internet Connection")
                                    
                                }
                                
                                print_debug(e)
                                failure(e)
                            }
        }
    }
    
    private static func upload(URLString : String,
                               httpMethod : HTTPMethod,
                               parameters : JSONDictionary = [:],
                               image : [String:UIImage]? = [:],
                               loader : Bool = true,
                               success : @escaping (JSON) -> Void,
                               failure : @escaping (Error) -> Void) {
        
        
        let URLStr = URLString
        let basicAuth = headers
        
        let url = try! URLRequest(url: URLStr, method: httpMethod, headers: basicAuth)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            var uploadData = parameters
            
            if let image = image {
                
                if let imgData = UIImageJPEGRepresentation(image["user_image"]!, 0.5) {
                    multipartFormData.append(imgData, withName: "user_image", fileName: "image", mimeType: "image/jpg")
                }
            }
            for (key , value) in uploadData{
                multipartFormData.append((value as AnyObject).data(using : String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        },
                         with: url, encodingCompletion: { encodingResult in
                            
                            
                            switch encodingResult{
                            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                                
                                upload.responseJSON(completionHandler: { (response:DataResponse<Any>) in
                                    switch response.result{
                                    case .success(let value):
                                        if loader { CommonClass.stopLoader() }
                                        
                                        print_debug(JSON(value))
                                        
                                        success(JSON(value))
                                        
                                    case .failure(let e):
                                        if loader { CommonClass.stopLoader() }
                                        
                                        if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                                            NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                        }
                                        
                                        print_debug(e)
                                        
                                        failure(e)
                                    }
                                })
                                
                            case .failure(let e):
                                if loader { CommonClass.stopLoader() }
                                
                                if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                }
                                
                                failure(e)
                            }
        })
        
    }
    
}




