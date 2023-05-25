//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "dfa833e5d65822515074a3b4fc396c2f"
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(para:[String:String]) {
//        AF.request(<#T##convertible: URLConvertible##URLConvertible#>, method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>, interceptor: <#T##RequestInterceptor?#>, requestModifier: <#T##Session.RequestModifier?##Session.RequestModifier?##(inout URLRequest) throws -> Void#>)
        
        AF.request(WEATHER_URL, method: .get, parameters: para).response { response in
//            print(response)
            if let statusCode = response.response?.statusCode {
                if statusCode == 200 {
                    let weatherJson: JSON = JSON(response.data)
                    print(weatherJson)
                    self.updateWeatherData(json: weatherJson)
                }
                else {
                    
                }
            }
        }
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "气象信息不可以用"
        }
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)+"°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }

    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations)
        if let location = locations.last {
            if location.horizontalAccuracy > 0 {
                locationManager.stopUpdatingLocation()
                print("经度=\(location.coordinate.longitude) \n纬度=\(location.coordinate.latitude)")
            
                let lon = location.coordinate.longitude
                let lat = location.coordinate.latitude
                
                let params: [String: String] = ["lat": String(lat), "lon": String(lon), "appid": APP_ID];
                getWeatherData(para: params)
            }
        }
        
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "定位失败"
    }
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
        let params: [String: String] = ["q":city, "appid":APP_ID]
        getWeatherData(para: params)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
}


