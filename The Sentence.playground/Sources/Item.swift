//
//  Item.swift
//  Matt Barker
//  06/8/16
//

import Foundation

/**
 A class that stores something the user may or may not use based on the temperature. Specialized items like
 an umbrella and sunglasses are handled directly by the algorithm.
 
 - parameter name: The name of the item
 - paramter type: ItemType - Upper, Lower, Foot, Other
 - parameter lowTemp: the lowest temperature the user would wear this item
 - parameter highTemp: the highest temperature the user would wear this item
 - parameter rain: optional (nil by default) true if specifically worn in rain, false if never worn in rain
 */
public class Item: NSObject {
    public var name: String
    public var type: ItemType?
    public var lowTemp: Int = 0
    public var highTemp: Int = 0
    public var rain: Bool? = nil
    
    var weatherType: Icon = .Nil
    var precipIntensity: Float = 0.0
    var windSpeed: Float = 0.0
    var cloudCover: Float = 0.0
    var humidity: Float = 0.0
    
    
    /** Standard Intializer, with optional rain boolean */
    public init(name: String, type: ItemType, lowTemp: Int, highTemp: Int, rain: Bool? = nil) {
        self.name = name
        self.type = type
        self.lowTemp = lowTemp
        self.highTemp = highTemp
        self.rain = rain
    }
    
    /** Advanced Intializer, with several weather paramters */
    public init(name: String, type: ItemType, base: Bool = false,
         lowTemp: Int, highTemp: Int,
         weatherType: Icon,
         rain: Bool?, precipIntensity: Float,
         windSpeed: Float,
         cloudCover: Float,
         humidity: Float) {
        
        self.name = name; self.type = type; self.lowTemp = lowTemp; self.highTemp = highTemp
        self.weatherType = weatherType; self.rain = rain; self.precipIntensity = precipIntensity
        self.windSpeed = windSpeed; self.cloudCover = cloudCover; self.humidity = humidity
    }
    
    /** Initalizer for specialized items, e.g. an umbrella, some shades (see bring function) */
    public init(_ name: String) { self.name = name; self.type = nil }
    
    //minimum and maximum values for Fahrenheit and Celcius temperatures
    public func minMax(_ data: Forecast) -> (Int, Int) {
        if let units = data.flags?.units {
            if units == "us" { return (0, 100) }
            else { return (-18, 38) }
        } else { print("\nerror: minMax - flags doesn't exist"); return (0, 0) }
    }
}

/// The kind of item, based on body locations for clothing
public enum ItemType: String {
    case Upper, Lower, Foot, Other
}
