//
//  Weather.swift
//  Weather
//
//  Created by Sylvie on 15.09.20.
//  Copyright © 2020 SylvieLiu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

extension ViewController:CLLocationManagerDelegate{
    //OpenWeatherMap API Key -> a7a8c234ea316430d224ef858646e88a
    /*
     "https://api.openweathermap.org/data/2.5/weather?lat=33.441792&lon=-94.037689&appid=a7a8c234ea316430d224ef858646e88a&units=Metric"
     */
    
    func APISetUp(lat: Double, long: Double){
        let url:String = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=a7a8c234ea316430d224ef858646e88a&units=Metric"
        
        AF.request(url, method: .post, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let weather = json["weather"][0]["main"].string
                    let description = json["weather"][0]["description"].string
                    print("weather", weather, description)
                    //temperature = CGFloat(json["main"]["temp"].int!)
                    temperature = self.normalizeValue(val: CGFloat(json["main"]["temp"].int!), maxVal: 25, minVal: 0)
                    print("temperature", CGFloat(json["main"]["temp"].int!))
                    let windDegree = json["wind"]["deg"].float
                    let windSpeed = json["wind"]["speed"].float
                    print("wind", windDegree, windSpeed)
                    clouds = CGFloat(json["clouds"]["all"].float!)/100
                    print("clouds", clouds)
                    
                    if weatherTrue == nil{
                        weatherTrue = true
                        DispatchQueue.main.async {
                            weatherButton.setImage(UIImage.init(named: "weather_on"), for: .normal)
                        }
                    }
                    
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func initLocationManager(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.main.async {
            weatherButton.setImage( UIImage.init(named: "weather_off"), for: .normal)
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
            let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
                self.locationManager.startUpdatingLocation()
            })
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("weather updated")
        guard let currentCoord: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(currentCoord.latitude) \(currentCoord.longitude)")
        locationManager.stopUpdatingLocation()
        APISetUp(lat: currentCoord.latitude, long: currentCoord.longitude)
    }
}
