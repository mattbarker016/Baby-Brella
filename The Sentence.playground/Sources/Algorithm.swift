// 
// Algorithm.swift
// Project Icicle
//
// Created by Matt Barker on 5/2/16.
// Copyright © 2016 Matt Barker. All rights reserved.
//

import UIKit
import CoreLocation

/**
 Create a sentence that greets the user, tells them what they should wear or bring for the day's weather
 based on when their day starts and ends, and provides a forecast summary for the day.
 
 - parameter items: an array of all of the user's items
 - parameter forecast: the current forecast
 - parameter range: the times with which to check the weather between
 - parameter temp: Boolean indicating whether to include temperatures in The Sentence
 - parameter constants: (tempPref, wiggle, miscPref) constants that adjust the sentence.
 
 - parameter tempPref: tuple with user preferences for hot and cold temperature
 - parameter wiggle: the amount of lee-way the algorithm uses when comparing temperature values
 - parameter miscPref: tuple with user preferences for rain, wind, and sun (used in bring function)
 
 - returns: The Sentence
 */
public func theSentence(items: [Item], forecast: Forecast, range: (Date, Date), temp: Bool = false,
                 constants: ((Float, Float), Int, (Float, Float, Float))) -> String {
    
    let cal = Calendar.current()
    var startTime = range.0; var endTime = range.1
    let tempPref = constants.0; let wiggle = constants.1; let weatherPref = constants.2
    var rangeForecast: [DataPoint] = []
    var rangeTemp: [Float?] = []
    var timeOfDay = ("today", "Today")
    
    //calculate temperatures for the next day if at / past endTime
    if (Date().compare(endTime as Date) != .orderedAscending) {
        startTime = cal.date(byAdding: .day, value: 1, to: startTime as Date, options: Calendar.Options())!
        endTime = cal.date(byAdding: .day, value: 1, to: endTime as Date, options: Calendar.Options())!
        timeOfDay = ("tomorrow", "Tomorrow")
    }
    
    //store temperatures for every hour in user's desired timeframe
    for point in forecast.hourly!.data! {
        if point.time.compare(startTime as Date) != .orderedAscending &&
            point.time.compare(endTime as Date) != .orderedDescending {
            rangeForecast.append(point)
            rangeTemp.append(point.apparentTemperature)
        }
    }
    
    //print out temperatrues in range for testing
    if rangeForecast.count == 0 { print("\nerror: rangeForecast is empty, so forecast.hourly.data is likely empty\n") }
    var accum = ""; for temp in rangeTemp { accum += "\(temp!), " }; print("Hourly Temperatures in Range: \n"+accum+"\n")
    //print("\nrangeTemp: [40, 45, 50, 55, 60, 65, 70, 75, 65, 55, 45]\n")
    
    //calculate appropriate greeting for time of day
    //Morning: 3AM - 11:59AM, Afternoon: 12PM - 4:59PM, Evening: 5PM - 2:59AM
    var greeting = "Good morning! "
    let currentHour = Calendar.current().components([.hour, .minute], from: Date()).hour
    if currentHour >= 12 && currentHour < 17 { greeting = "Good afternoon! " }
    if currentHour >= 17 || (0 <= currentHour && currentHour < 3) { greeting = "Good evening! " }
    
    //personality (arr1 is wear, arr2 is bring)
    var arr1 = (timeOfDay.0 == "today") ? Personality().wearToday : Personality().wearTomorrow
    var arr2 = Personality().bring
    
    //change personality array if above or below user's hot / cold temperatures
    var high = -1 * Float.infinity; var low = Float.infinity
    for temp in rangeTemp { low = min(low, temp!) }
    if low <= tempPref.0 { arr1 = Personality().wearCold }
    for temp in rangeTemp { high = max(high, temp!) }
    if high >= tempPref.1 { arr1 = Personality().wearHot }
    
    //calculate arrays of items needed, store into variables
    var calculateTuple = calculate(items, forecast: forecast, rangeTemp: rangeTemp, wiggle: wiggle)
    let bringResult = bring(forecast, rangeForecast: rangeForecast, constants: weatherPref)
    var calculateTupleZero = calculateTuple.0; var calculateTupleOne = calculateTuple.1
    var bringResultZero = bringResult.0; let rainBody = bringResult.1;
    
    //remove items worn for rain when it's not raining and items not worn in rain when it is raining
    for item in calculateTupleZero { if item.rain != nil {
        if (item.rain! && rainBody == "") || (!item.rain! && rainBody != "") {
            calculateTupleZero.remove(at: calculateTupleZero.index(of: item)!) }
        }
    }; for item in calculateTupleOne { if item.rain != nil {
        if (item.rain! && rainBody == "") || (!item.rain! && rainBody != "") {
            calculateTupleOne.remove(at: calculateTupleOne.index(of: item)!)
        } else { bringResultZero.append(item) } //group all "bring" items (overallMay + bring())
        }
    }
    
    //randomly select each type of item
    calculateTuple = randoSelect(calculateTupleZero, may: calculateTupleOne, rain: rainBody != "")
    calculateTupleZero = calculateTuple.0; calculateTupleOne = calculateTuple.1
    let rand1 = Int(arc4random_uniform(UInt32(arr1.count)))
    let rand2 = Int(arc4random_uniform(UInt32(arr2.count)))
    //introduce line variable (subject to change based on null) for body2
    var line = ", plus \(arr2[rand2])"
    
    //parse items into readable sentences, finalize punctuation depending on null
    let body1 = grammar(calculateTupleZero, line: (rainBody == "") ? arr1[rand1] : "You should wear your", conjunction: "and")
    if body1 == "" { line = "You should \(arr2[rand2])" }
    var body2 = grammar(bringResultZero, line: line, conjunction: "and") + ". "
    if body1 == "" && body2 == ". " { body2 = "" }
    
    //create and format weatherSummary
    var weatherSummary: String = ""
    if let string = forecast.daily?.data?.first?.summary {
        //let char =  string.substring(to: string.startIndex.advancedBy(n: 1)).lowercaseString
        let char = "\(string.characters.first!)".lowercased()
        weatherSummary = "The forecast\(((timeOfDay.0 == "tomorrow") ? " for tomorrow" : "")) is " + char +
            string.substring(from: string.index(string.startIndex, offsetBy: 1))
        // + string.substringFromIndex(string.startIndex.advancedBy(1))
        if temp { //calculate high and low temprature for entire day (will do next day if appropriate)
            weatherSummary.remove(at: weatherSummary.index(before: weatherSummary.endIndex))
            //weatherSummary = weatherSummary.substring(to: weatherSummary.endIndex.advancedBy(n: -1))
            let day = (timeOfDay.0 == "tomorrow") ? forecast.daily!.data![1] : forecast.daily!.data![0]
            let high = (forecast.flags?.feelsLike == true) ? day.apparentTemperatureMax! : day.temperatureMax!
            let low = (forecast.flags?.feelsLike == true) ? day.apparentTemperatureMin! : day.temperatureMin!
            let unit = (forecast.flags?.units == "us") ? "ºF" : "ºC"
            weatherSummary += ", with a high of \(Int(round(high)))\(unit) and low of \(Int(round(low)))\(unit)."
        }
    } else { print("\nerror: forecast.daily.data.first isn't behaving\n") }
    
    return greeting + rainBody + body1 + body2 + weatherSummary
}


/**
 Calculate which items are suitable for the user's range.
 
 First, A formula calculates a value (0, 1] to approproately weight the importance
 of the specific hour's temperature. The exact middle of the range always has a weight of 1,
 while hours before and after parabolically decrease (but never below 0). All of these values
 are averaged to obtain a weightedValue, including potential nil weights. If the weightedValue
 exceeds a programmatically calculated acceptedValue, the item is deemed suitable.
 
 Then, any item that is suitable for at least one DataPoint is added to a secondary array,
 which is suggest to be "brought along"
 
 Equation: ( -1 / (size/2)^2 + 1 ) * ( (x + 1) * (x - size) ), size = number of DataPoints (hours) in range
 
 - Remark:
 
 The programmatically calculated acceptedValue is the average of every weighted value in the range. That is,
 a so-called "perfect" item passes the temperature test for every point in range. This number is then divided
 by a constant, currently 2, or 50% of a "perfect" weightedValue
 
 - parameter items: a list of all of the user's items
 - parameter forecast: the current forecast
 - parameter rangeTemp: an array of all the hourly temperatures in the user's range
 - parameter wiggle: the amount of lee-way the algorithm uses when comparing temperature values
 
 - returns: tuple with an array of items to wear and an array of items to bring
 
 */
func calculate(_ items: [Item], forecast: Forecast, /*var*/ rangeTemp: [Float?], wiggle: Int) -> ([Item],[Item]) {
    
    var parsedOverallItems: [Item] = []
    var parsedMayItems: [Item] = []
    let MIN = Item("").minMax(forecast).0
    let MAX = Item("").minMax(forecast).1
    
    //rangeTemp = [40, 45, 50, 55, 60, 65, 70, 75, 65, 55, 45]
    var acceptedValue: Double = 0 //for print statement below
    
    for item in items {
        var weightedValue: Double = 0.0
        var totalWeight = 0.0
        
        for x in 0..<rangeTemp.count {
            
            if rangeTemp[x] == nil { print("\nerror: a value in rangeTemp is nil, either skip or count as 0\n") }
            
            //checks if each hourly temperature is within the item's range
            let standard: Bool = item.lowTemp <= Int(rangeTemp[x]!) && item.highTemp >= Int(rangeTemp[x]!)
            
            //checks if item is with Int WIGGLE distance of each hourly temperature
            let wiggle: Bool = abs(Int(rangeTemp[x]!) - item.lowTemp) <= wiggle ||
                abs(item.highTemp - Int(rangeTemp[x]!)) <= wiggle
            
            //check if item has a min/max value AND the hourly temperature surpassses one of them
            let extreme: Bool = Int(rangeTemp[x]!) < MIN && item.lowTemp == MIN || Int(rangeTemp[x]!) > MAX && item.highTemp == MAX
            
            //applying weighted quadratic formula
            let square = Double(Double(rangeTemp.count - 1) / 2.0 + 1)
            let weight = Double(-1 / pow(square, 2)) * Double((x+1) * (x - rangeTemp.count))
            totalWeight += weight
            
            //add to may if it ever passes standard / extreme once
            if (standard || wiggle || extreme) {
                weightedValue += weight
                if !parsedMayItems.contains(item) && (!wiggle || standard) {
                    parsedMayItems.append(item)
                }
            }
        }
        
        acceptedValue = (totalWeight / Double(rangeTemp.count)) / 2.0
        
        //if weight is at or above acceptedValue, remove from May if there and add to Overall
        if weightedValue / Double(rangeTemp.count) >= acceptedValue {
            if parsedMayItems.contains(item) { parsedMayItems.remove(at: parsedMayItems.index(of: item)!) }
            parsedOverallItems.append(item)
        }
        
        //don't bring items if their weight is too low - BETA
        if weightedValue / Double(rangeTemp.count) < (acceptedValue / 3.0) {
            if parsedMayItems.contains(item) { parsedMayItems.remove(at: parsedMayItems.index(of: item)!) }
        }
        
        print("\(item.name) - weightedValue: \(weightedValue / Double(rangeTemp.count))")
    }
    
    print("\nacceptedValue: \(acceptedValue)\n")
    
    return (parsedOverallItems, parsedMayItems)
}

//randomly select items
func randoSelect(_ overall: [Item], may: [Item], rain: Bool) -> ([Item], [Item]) {
    
    //randomize items
    var parsedOverallItems = overall; var parsedMayItems = may
    for x in 0..<parsedOverallItems.count {
        let random = Int(arc4random_uniform(UInt32(parsedOverallItems.count)))
        parsedOverallItems.insert(parsedOverallItems.remove(at: x), at: random)
    }
    for x in 0..<parsedMayItems.count {
        let random = Int(arc4random_uniform(UInt32(parsedMayItems.count)))
        parsedMayItems.insert(parsedMayItems.remove(at: x), at: random)
    }
    
    var upper = true; var lower = true; var foot = true;
    var selectedOverallItems: [Item] = []
    
    //check if items are affected by rain and add / remove appropriately
    if rain {
        //prioritize items worn in rain
        for item in parsedOverallItems {
            if item.rain == true {
                if upper && item.type == .Upper { selectedOverallItems.append(item); upper = false }
                if lower && item.type == .Lower { selectedOverallItems.append(item); lower = false }
                if foot && item.type == .Foot { selectedOverallItems.append(item); foot = false }
                if item.type == .Other { selectedOverallItems.append(item) }
            }
        }
        //remove items that shouldn't be worn in rain
        for item in parsedMayItems {
            if item.rain == false { parsedMayItems.remove(at: parsedMayItems.index(of: item)!) }
        }
    }
    
    //add one of each type of item
    for item in parsedOverallItems {
        if upper && item.type == .Upper { selectedOverallItems.append(item); upper = false }
        if lower && item.type == .Lower { selectedOverallItems.append(item); lower = false }
        if foot && item.type == .Foot { selectedOverallItems.append(item); foot = false }
        if item.type == .Other { selectedOverallItems.append(item) }
    }
    
    return (selectedOverallItems, parsedMayItems)
}


/**
 Create a grammatically appropriate sentence
 
 - parameter parsedItems: [Items] to put in sentence
 - parameter line: begininng line pasted in front of sentence
 - parameter conjunction: the conjunction used to chain items together
 
 - returns: a String, but with no punctuation at the end
 */
func grammar(_ parsedItems: [Item], line: String, conjunction: String) -> String {
    
    var itemNames: [String] = []
    for item in parsedItems { itemNames.append(item.name) }
    
    var funcLine = line + " "
    if itemNames.count == 0 { return "" }
    if itemNames.count >= 3 { //"x1, ... , xN-1, [conjunction] xN"
        for index in 0...itemNames.count - 2 { funcLine = funcLine + itemNames[index] + ", " }
        return funcLine + conjunction + " " + itemNames[itemNames.count - 1]
    }
    if parsedItems.count == 2 {// x1 [conjunction] x2
        return funcLine + itemNames[0] + " " + conjunction + " " + itemNames[1]
    }
    
    return funcLine + itemNames.first!
}


/**
 Parse the weather to calculate whether an umbrella and any other items should be brought
 
 - parameter forecast: the current forecast
 - parameter rangeForecast: an array of hourly temperatures based on the user's startTime and endTime
 - parameter constants: (rainTolerance, windTolerance, sunTolerance) constants that adjust the sentence
 
 - parameter rainTolerance: amount of rain intensity deemed significant
 - parameter windTolerance: speed of the wind deemed significant
 - parameter sunTolerance: percentage of cloud cover deemed significant
 
 - returns: [Item] of specialized items to bring; String descrbing how needed an umbrella is (empty if not needed)
 */
func bring(_ forecast: Forecast, rangeForecast: [DataPoint], constants: (Float, Float, Float)) -> ([Item], String) {
    
    let rainTolerance = constants.0; let windTolerance = constants.1; let sunTolerance = constants.2
    var precipitation = false; var significantPrecipitation = false; var wind = false;
    
    //check weather conditions for every dataPoint in range
    for data in rangeForecast {
        //note: snow is not counted as precipitation
        if data.icon?.rawValue == "rain" || data.icon?.rawValue == "sleet" { precipitation = true }
        if data.precipIntensity >= rainTolerance { significantPrecipitation = true }
        if data.icon?.rawValue == "wind" || data.windSpeed >= Float(windTolerance) { wind = true }
    }
    
    //create rainBody, with personality
    var rainBody: String = ""
    if significantPrecipitation || precipitation {
        
        //randomly choose either a string before or after the umbrella reccomendation
        let arrBefore = Personality().rainBefore; var before: String = ""
        let arrAfter = Personality().rainAfter; var after: String = ""
        let arrSum = arrBefore.count + arrAfter.count
        let randX = Int(arc4random_uniform(UInt32(arrSum)))
        if randX >= arrBefore.count { before = "You"; after = arrAfter[randX - arrBefore.count] }
        else { before = arrBefore[randX]; after = ". " }
        let arr2 = ["bring", "take", "pack"]
        let rand2 = Int(arc4random_uniform(UInt32(arr2.count)))
        
        if significantPrecipitation { rainBody = "\(before) should definetly \(arr2[rand2]) an umbrella\(after)" }
        else { rainBody = "\(before) might want to \(arr2[rand2]) an umbrella\(after)" }
    }
    
    //append relevant conditions
    var parsedConditions: [Item] = []
    if wind { parsedConditions.append(Item("a kite")) }
    
    //check that it is daytime before reccomending sunglasses, but allow if before startTime for new day
    let afterSunrise: Bool = forecast.daily!.data!.first?.sunriseTime?.compare(Date()) != .orderedDescending
    let beforeSunset: Bool = forecast.daily!.data!.first?.sunsetTime?.compare(Date()) != .orderedAscending
    let beforeSunrise: Bool = rangeForecast.first!.time.compare(Date()) != .orderedAscending
    
    //double check logic
    if forecast.daily?.data?.first?.cloudCover < sunTolerance && (afterSunrise && beforeSunset || beforeSunrise) {
        parsedConditions.append(Item("some shades")) }
    
    return (parsedConditions, rainBody)
}


/**
 Sets the user's startTime and endTime correctly to define a range with which to check the weather in.
 
 - parameter start: the starting time in 24H format (HH, MM)
 - parameter end: the ending time in 24H format (HH, MM)
 - returns: two NSDate values rounded and formatted logically
 */
public func timeInitializer(start: (Int, Int), end: (Int, Int)) -> (Date, Date) {
    
    //convert minutes and hours into NSDate()
    let cal = Calendar.current()
    var startTime = cal.date(bySettingHour: start.0, minute: start.1, second: 00, of: Date(), options: Calendar.Options())
    var endTime = cal.date(bySettingHour: end.0, minute: end.1, second: 00, of: Date(), options: Calendar.Options())
    
    //round startTime and endTime (>= 30 minutes rounds up, otherwise down)
    if cal.component(.minute, from: startTime!) >= 30 {
        startTime = cal.date(byAdding: .hour, value: 1, to: startTime!, options: Calendar.Options())
    }
    if cal.component(.minute, from: endTime!) >= 30 {
        endTime = cal.date(byAdding: .hour, value: 1, to: endTime!, options: Calendar.Options())
    }
    startTime = cal.date(bySettingHour: cal.component(.hour, from: startTime!), minute: 00,
                                      second: 00, of: Date(), options: Calendar.Options())
    endTime = cal.date(bySettingHour: cal.component(.hour, from: endTime!), minute: 00,
                                    second: 00, of: Date(), options: Calendar.Options())
    
    //change day to next day if endTime goes to next day (causes same time to make entire next day the range)
    if endTime!.compare(startTime!) != .orderedDescending {
        endTime = cal.date(bySettingHour: cal.component(.hour, from: endTime!), minute: 00,
                                        second: 00, of: cal.date(byAdding: .day, value: 1,
                                            to: Date(), options: Calendar.Options())!,
                                        options: Calendar.Options())
    }
    
    return (startTime!, endTime!)
}
