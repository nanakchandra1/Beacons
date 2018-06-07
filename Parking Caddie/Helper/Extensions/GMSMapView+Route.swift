
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
    
    func drawRoute(fromLocation : CLLocation, toLocation : CLLocation) {
        
        let mapTasks = MapTasks()
        
        mapTasks.getDirections(origin: fromLocation, destination: toLocation) { (status, success) -> Void in
            
            if success {
                
                let route = mapTasks.overviewPolyline["points"] as! String
                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                _ = GMSPolyline(path: path)
                
            }
        }
    }
    
    
    func drowPath(fromLocation : CLLocation, toLocation : CLLocation){
        
        let mapTasks = MapTasks()
        mapTasks.getDirections(origin: fromLocation, destination: toLocation) { (status, success) -> Void in
            if success {
                let route = mapTasks.overviewPolyline["points"] as! String
                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                let routePolyline = GMSPolyline(path: path)
                routePolyline.strokeWidth = 5.0
                routePolyline.map = self
                var bounds = GMSCoordinateBounds()
                bounds = bounds.includingPath(path)
                self.animate(with: GMSCameraUpdate.fit(bounds))
            }
        }
    }
}

private enum GoogleMapTravelMode {
    
    case driving
    case walking
    case bicycling
    
    var stringValue : String {
        
        switch self {
            
        case .driving : return "Driving"
        case .walking : return "Walking"
        case .bicycling : return "Bicycling"
            
        }
    }
}

private class MapTasks {
    
    var i = 0
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var lookupAddressResults: [String: AnyObject]!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    var overviewPolyline: [String: AnyObject]!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    init() {
        
    }
    
    
    
    func getDirections(origin: CLLocation, destination: CLLocation, waypoints: [String]? = nil, travelMode: GoogleMapTravelMode = .driving, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        
        var directionsURLString = baseURLDirections + "origin=\(origin.coordinate.latitude),\(origin.coordinate.longitude)&destination=\(destination.coordinate.latitude),\(destination.coordinate.longitude)"
        
        if let routeWaypoints = waypoints {
            
            directionsURLString += "&waypoints=optimize:true"
            
            for waypoint in routeWaypoints {
                directionsURLString += "|" + waypoint
            }
        }
        
        directionsURLString += "&mode=" + travelMode.stringValue
        
        directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
        let directionsURL = URL(string: directionsURLString)
        DispatchQueue.main.async(execute: { () -> Void in
            
            let directionsData = try? Data(contentsOf: directionsURL!)
            
            do {
                
                let dictionary: [AnyHashable: Any] = try JSONSerialization.jsonObject(with: directionsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [AnyHashable: Any]
                
                let status = dictionary["status"] as! String
                if status == "OK" {
                    
                    let selectedRoute = (dictionary["routes"] as! [[String: AnyObject]])[0]
                    self.overviewPolyline = selectedRoute["overview_polyline"] as! [String: AnyObject]
                    let legs = selectedRoute["legs"] as! [[String: AnyObject]]
                    let startLocationDictionary = legs[0]["start_location"] as! [String: AnyObject]
                    self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                    let endLocationDictionary = legs[legs.count - 1]["end_location"] as! [String: AnyObject]
                    self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                    self.originAddress = legs[0]["start_address"] as! String
                    self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                    self.calculateTotalDistanceAndDuration(selectedRoute)
                    completionHandler(status, true)
                }
                
            } catch let error as NSError {
                
                completionHandler(error.localizedDescription, false)
            }
        })
    }
    
    
    
    func calculateTotalDistanceAndDuration(_ selectedRoute : [AnyHashable: Any]) {
        let legs = selectedRoute["legs"] as! [[String: AnyObject]]
        var totalDurationInSeconds: UInt = 0
        var totalDistanceInMeters: UInt = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! [String: AnyObject])["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! [String: AnyObject])["value"] as! UInt
        }
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        let _ = "Total Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    

}
