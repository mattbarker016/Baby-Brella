//
//  DataPointIcon.swift
//  Forecast.io
//
//  Created by Satyam Ghodasara on 7/18/15.
//  Copyright (c) 2015 Satyam. All rights reserved.
//

import Foundation

/**
    Types of weather conditions. Additional values may be defined in the future, so be sure to use a default.
*/
public enum Icon: String {
    /// A clear day.
    case ClearDay = "clear-day"
    
    /// A clear night.
    case ClearNight = "clear-night"
    
    /// A rainy day or night.
    case Rain = "rain"
    
    /// A snowy day or night.
    case Snow = "snow"
    
    /// A sleety day or night.
    case Sleet = "sleet"
    
    /// A windy day or night.
    case Wind = "wind"
    
    /// A foggy day or night.
    case Fog = "fog"
    
    /// A cloudy day or night.
    case Cloudy = "cloudy"
    
    /// A partly cloudy day.
    case PartlyCloudyDay = "partly-cloudy-day"
    
    /// A partly cloudy night.
    case PartlyCloudyNight = "partly-cloudy-night"
    
    /// No Icon
    case Nil = ""
    
    /** Returns desired string for Description Label based on enum value */
    public func iconFormat() -> String {
        let text = self.rawValue
        switch text {
            case "clear-day", "clear-night": return "CLEAR"
            case "rain": return "RAIN"
            case "snow": return "SNOW"
            case "sleet": return "SLEET"
            case "wind": return "WINDY"
            case "fog": return "FOGGY"
            case "cloudy": return "CLOUDY"
            case "partly-cloudy-day", "partly-cloudy-night": return "PARTLY CLOUDY"
            default: return "ERROR"
        }
    }
    
}
