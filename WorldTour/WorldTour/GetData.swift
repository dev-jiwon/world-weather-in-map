//
//  GetDataViewController.swift
//  WorldTour
//
//  Created by Jo JANGHUI on 2018. 7. 20..
//  Copyright © 2018년 JhDAT. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let complete = Notification.Name.init("kComplete")
    static let localComplete = Notification.Name.init("Complete")
}


final class Citynames {
    static let shared = Citynames()
    private init() {}
    var cityname : [String : [Double]] = [:]
    var parsignCheck = false
    var sortArr: [String]!
}

final class LocalCitynames {
    static let shared = LocalCitynames()
    private init() {}
    var localCityname : [String : [Double]] = [:]
}

class GetData {
    
    init() {
        let cityArr: [CityName.location] = [.seoul, .sapporo, .tokyo, .sydney, .hawaii, .vladivostok,
                                            .zagreb, .bangkok, .london, .yellowknife, .paris, .taipei,
                                            .dubai, .roma, .madrid, .okinawa, .swis, .cairns, .uluru,
                                            .uluru, .newYork, .alaska, .boracay, .maldives, .kotaKinabalu,
                                            .bali, .malta, .hoiAn, .hongKong, .iceland, .mongolia, .greece]
//                let cityArr: [CityName.location] = [.seoul, .sapporo, .tokyo, .sydney, .hawaii, .vladivostok]
        apiload(city: cityArr)
    }
    
    func apiload(city: [CityName.location]) {
        let globalDefault = DispatchQueue.global()
        let myGroup = DispatchGroup()
        
        for idx in 0..<city.count {
            globalDefault.async(group: myGroup) {
                let kelvin: Double = 273.15
                let cityStringName = city[idx].rawValue
                
                let position = "https://api.openweathermap.org/data/2.5/weather?q=\(cityStringName)&appid=23993687fb69bfa2e960340ec8d72b27"
                let apiURL = URL(string: position)!
                
                let dataTask = URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
                    guard error == nil else { return print("error")}
                    guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                        print("status error")
                        return
                    }
                    
                    guard let data = data else { return print("Parsing error")}
                    let jsonObject = try? JSONDecoder().decode(OpenWeatherMap.self, from: data)
                    
                    guard let name = jsonObject?.name,
                        let currentTemp = jsonObject?.temp,
                        let maxTemp = jsonObject?.tempMax,
                        let minTemp = jsonObject?.tempMin,
                        let humidity = jsonObject?.humidity,
                        let lon = jsonObject?.lon,
                        let lat = jsonObject?.lat
                        else { return print("parsing error")}
                    
                    let currentKelbinToTemp = ceil(currentTemp - kelvin)
                    let maxKelbinToTemp = ceil(maxTemp - kelvin)
                    let minKelbinToTemp = ceil(minTemp - kelvin)
                    
                    Citynames.shared.cityname[name] = [
                        currentKelbinToTemp,
                        maxKelbinToTemp,
                        minKelbinToTemp,
                        ceil(humidity),
                        lon,
                        lat
                    ]
                    Citynames.shared.parsignCheck = true
                    NotificationCenter.default.post(name: .complete, object: nil)
                }
                dataTask.resume()
            }
            
        }
    }
    
    
    func apiloadInName(lon: Double, lat: Double)  {
        let kelvin: Double = 273.15
        let position = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=23993687fb69bfa2e960340ec8d72b27"
        let apiURL = URL(string: position)!
        
        let dataTask = URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
            guard error == nil else { return print("error")}
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                print("status error")
                return
            }
            
            guard let data = data else { return print("Parsing error")}
            let jsonObject = try? JSONDecoder().decode(OpenWeatherMap.self, from: data)
            
            guard let name = jsonObject?.name,
                let currentTemp = jsonObject?.temp,
                let maxTemp = jsonObject?.tempMax,
                let minTemp = jsonObject?.tempMin,
                let humidity = jsonObject?.humidity,
                let lon = jsonObject?.lon,
                let lat = jsonObject?.lat
                else { return print("parsing error")}
            
            let currentKelbinToTemp = ceil(currentTemp - kelvin)
            let maxKelbinToTemp = ceil(maxTemp - kelvin)
            let minKelbinToTemp = ceil(minTemp - kelvin)
            
            LocalCitynames.shared.localCityname[name] = [
                currentKelbinToTemp,
                maxKelbinToTemp,
                minKelbinToTemp,
                ceil(humidity),
                lon,
                lat
            ]
            
        }
        dataTask.resume()
        NotificationCenter.default.post(name: .localComplete, object: nil)
    }
    
}
