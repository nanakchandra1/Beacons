//
//  GMSMapView+Route.swift
//  PileIn
//
//  Created by Gurdeep Singh on 24/12/15.
//  Copyright © 2015 Appinventiv. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps


extension GMSMapView {
    
    func drawRoute(fromLocation fromLocation : CLLocation, toLocation : CLLocation) {
        
        let mapTasks = MapTasks()
        
        mapTasks.getDirections(origin: fromLocation, destination: toLocation) { (status, success) -> Void in
            
            if success {
                
                let route = mapTasks.overviewPolyline["points"] as! String
                
                let path: GMSPath = GMSPath(fromEncodedPath: route)
                
                let routePolyline = GMSPolyline(path: path)
                routePolyline.strokeWidth = 3.0
                routePolyline.strokeColor = AppColor
                routePolyline.map = self
            }
        }
    }
}

private enum GoogleMapTravelMode {
    
    case Driving
    case Walking
    case Bicycling
    
    var stringValue : String {
        
        switch self {
            
        case .Driving : return "Driving"
        case .Walking : return "Walking"
        case .Bicycling : return "Bicycling"
            
        }
    }
}

private class MapTasks {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    init() {
        
    }
    
    func getDirections(origin origin: CLLocation, destination: CLLocation, waypoints: [String]? = nil, travelMode: GoogleMapTravelMode = .Driving, completionHandler: ((status: String, success: Bool) -> Void)) {
        
        var directionsURLString = baseURLDirections + "origin=\(origin.coordinate.latitude),\(origin.coordinate.longitude)&destination=\(destination.coordinate.latitude),\(destination.coordinate.longitude)"
        
        if let routeWaypoints = waypoints {
            
            directionsURLString += "&waypoints=optimize:true"
            
            for waypoint in routeWaypoints {
                directionsURLString += "|" + waypoint
            }
        }
        
        directionsURLString += "&mode=" + travelMode.stringValue
        
        directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let directionsURL = NSURL(string: directionsURLString)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            let directionsData = NSData(contentsOfURL: directionsURL!)
            
            do {
                
                let dictionary: [NSObject:AnyObject] = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! [NSObject:AnyObject]
                
                let status = dictionary["status"] as! String
                
                if status == "OK" {
                    
                    let selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                    self.overviewPolyline = selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                    
                    let legs = selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    let startLocationDictionary = legs[0]["start_location"] as!Dictionary<NSObject, AnyObject>
                    self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                    
                    let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                    self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                    
                    self.originAddress = legs[0]["start_address"] as! String
                    self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                    
                    //                            self.calculateTotalDistanceAndDuration(selectedRoute)
                    
                    completionHandler(status: status, success: true)
                    
                }
                
            } catch let error as NSError {
                
                completionHandler(status: error.localizedDescription, success: false)
            }
            
        })
        
    }
    
    
    func calculateTotalDistanceAndDuration(selectedRoute : [NSObject:AnyObject]) {
        
        let legs = selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        var totalDurationInSeconds: UInt = 0
        var totalDistanceInMeters: UInt = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        let _ = "Total Distance: \(distanceInKilometers) Km"
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        let _ = "Total Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
}
