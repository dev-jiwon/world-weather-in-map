//
//  WeatherData.swift
//  WorldTour
//
//  Created by Jo JANGHUI on 2018. 7. 20..
//  Copyright © 2018년 JhDAT. All rights reserved.
//

import Foundation


struct CityName {
    enum location: String {
        case seoul, sapporo, tokyo, sydney, hawaii, vladivostok, zagreb, bangkok, london, yellowknife
        case paris, taipei, dubai, roma, madrid
        case okinawa = "kaganji"
        case swis = "stockholm"
        case cairns = "cairns"
        case uluru = "yulara"
        case newYork = "new%20york"
        case alaska = "Anchorage"
        case boracay = "Balabag"
        case maldives = "Male,mv"
        case kotaKinabalu = "kota%20kinabalu"
        case bali = "banjar%20Keraman"
        case malta = "attard"
        case hoiAn = "hoi%20an"
        case hongKong = "hong%20kong"
        case iceland = "reykjavik"
        case mongolia = "ulaanbaatar"
        case greece = "Athens,gr"
    }
}

struct OpenWeatherMap: Decodable {
    let base : String
    let name : String
    let temp : Double
    let tempMin : Double
    let tempMax : Double
    let humidity : Double
    let lon : Double
    let lat : Double
    
    enum CodingKeys: String, CodingKey {
        case base, name, main, coord
    }
    
    enum MainInfoKey: String, CodingKey {
        case temp, humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    enum CoordInfoKey: String, CodingKey {
        case lon, lat
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        base = try value.decode(String.self, forKey: .base)
        name = try value.decode(String.self, forKey: .name)
        
        let mainInfo = try value.nestedContainer(keyedBy: MainInfoKey.self, forKey: .main)
        temp = try mainInfo.decode(Double.self, forKey: .temp)
        tempMin = try mainInfo.decode(Double.self, forKey: .tempMin)
        tempMax = try mainInfo.decode(Double.self, forKey: .tempMax)
        humidity = try mainInfo.decode(Double.self, forKey: .humidity)
        
        let coordInfo = try value.nestedContainer(keyedBy: CoordInfoKey.self, forKey: .coord)
        lat = try coordInfo.decode(Double.self, forKey: .lat)
        lon = try coordInfo.decode(Double.self, forKey: .lon)
    }
    
}
