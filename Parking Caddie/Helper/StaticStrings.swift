//
//  StaticStrings.swift
//  Parking Caddie
//
//  Created by Appinventiv on 06/07/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation

//MARK:- Static strings
//MARK:-


struct myAppconstantStrings{
    static let selectImage = "Please select image"

    static let noInternet = "No Internet Connection"
    static let enterName = "Please enter your name"
    static let enterPass = "Please enter password"
    static let emptyNewPass = "Please enter new password"
    static let emptyConfirmPass = "Please enter confirm password"
    static let emptyOldPass = "Please enter old password"
    static let passLength = "Password length should be between 8 to 32 characters"
    static let emptyUserName = "Please enter email"
    static let validEmail = "Please enter valid email"
    static let nearBy = "Near By Suggestions"
    static let noResult = "No result found"
    static let entermobile = "Please enter mobile number"
    static let enterCode = "Please select country code"
    static let enterOtp = "Please enter OTP"
    static let enterCity = "Please enter city name"
    static let entercarName = "Enter Car Name"
    static let enterPlateNo = "Enter plate no."
    static let terms = "Accept terms & conditions"
    static let emptyCoupon = "Enter Coupon Code"
    static let terms_condi = "I Accept Terms of Service & Privacy Policy"
    static let carName_plate = "Please Enter Car Name Or Plate No"
    static let diff_carName = "Please Add Different Car Name "
    static let diff_carNo = "Please Add Different Car Number"
    static let matchPass = "New Password & confirm Password not match"
    static let addvehicle = "Please add vehicles in your profile"
    static let selectVehicle = "Please Select Vehicle"
    static let parkingTime = "No Prking Time Available"
    static let updateMobileAlert = "Do you want to save Changes"
    static let not_available = ""
    static let exit_parking = "Are you sure want to exit?"
    static let bluetoothON = "Please turn on bluetooth"
    static let locationService = "Please Enable Location Service"
    static let agentApproval = "WAITING FOR AGENT APPROVAL"
    static let thanks = "THANK YOU FOR VISITING"
    static let agentContact = "Please contact agent"
    static let normal = "N"
    static let valet = "V"
    static let startOver = "Are you sure to start over again?"
    static let deleteVehicle = "Do you want to delete vehicle"
    static let airportName = "Please Enter Airport Name"
    static let terminalName = "Please select Terminal Name"

    static let selectDate = "Please Select date"
    static let selectTime = "Please Select time"
    static let selectDuration = "Please Select Duration"
    static let serverError = "Server Error"
    static let timeOut = "request timed out"
    static let welcome = "WELCOME YOU"
    static let noHistory = "No History."
    static let noReservation = "No Reservation."
    static let facilityWarn = "Select Car Care Services from previous page"
    static let logoutAlert = "Are you sure want to Logout?"
    static let parketAt = " YOUR CAR PARKED AT "
    static let carCare = "CAR CARE SERVICES"
    static let real_Time_navigate_URL = "https://itunes.apple.com/in/app/google-maps-real-time-navigation/id585027354?mt=8"
    static let uuid_string = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
    static let per_day = "per_day"
    static let per_hr = "per_hour"
    static let history_type = "left"
    static let paid_am = "Paid Amount"
    static let duration = "Duration"
    static let type = "Type"
    static let arrival_time = "Arrival Time"
    static let expected_return = "Expected Return"
    static let reserved_on = "Reserved On"
    static let parked_on = "Parked On"
    static let return_time = "Return Time"
    static let category = "Category"
    static let paymentmode = "Payment Mode"

}

struct PushType {
    
    static let notification = "notification"
    static let ultimate_valet = "Ultimate Valet"
    static let RequestApproval = "RequestApproval"
    static let Request_Pickup = "Request Pickup"
    static let park_Now = "Parked Now"
    static let exit_Now = "Exit Now"
    static let bring_my_car = "Request for custom location"
    static let Reserved = "Reserved"
    static let PaymentCash = "PaymentCash"
    static let PaymentWeb = "PaymentWeb"


}

struct  parkingCatagories{
    
    static let economy = "economy"
    static let business = "business"
    static let indoor = "indoor"
    static let outdoor = "outdoor"
    static let ultimatevalet = "ultimatevalet"

}

struct  parkingState{

    static let valet = "V"
    static let normal = "N"
    static let Processing = "P"
    
}

struct ParkingCatagoryStrings {
    
    static let economy = "Economy: $"
    static let business = "Business: $"
    static let premium = "Valet(Premium): $"
    static let ultimate = "Ultimate Valet: $"
    
    static let economyE = "Economy: "
    static let businessE = "Business: "
    static let premiumE = "Valet(Premium): "
    static let ultimateE = "Ultimate Valet: "

    static let perDay = "/day"
    static let perHour = "/hr"
    static let not_Avail = "N/A"

}
