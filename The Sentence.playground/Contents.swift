import UIKit
import CoreLocation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//////// DO NOT CHANGE ANYTHING ABOVE THIS LINE //////////

/* CONTROL PANEL */

//USING YOUR CURRENT LOCATION

//Instructions: Find your location's decimal latitude and longitude (without minutes or seconds)
//              You can look it up at http://www.latlong.net, or find it in Google Maps. Paste the
//              appropriate values below

// IMPORTANT: ºN and ºE are positive numbers, ºS and ºW are negative numbers

let latitude: Double = 41.2638
let longitude: Double = -74.3822

//Recent Locations
//Ithaca - Lat: 42.457, Long: -76.4778
//Seattle - Lat: 47.6062, Long: -122.3321
//Fargo - Lat: 46.8772, Long: -96.7898
//Chicago - Lat: 41.8781, Long: -87.6298
//Warwick - Lat: 41.2638, Long: -74.3822
//Philadelphia - Lat: 39.9526, Long: -75.1652
//Atlanta - Lat: 33.748995, Long: -84.387892
//London - Lat: 51.5074, Long: 0.1278


//ADDING AND CUSTOMIZING ITEMS

//Note: This is the user's collection of items. Any type of item a user might wear
//based on the weather should be added. However, Items like an umbrella and sunglasses
//are handled directly by the algorithm

//Instructions:
//              1) Replace the red strings with the name of your item, keeping quotation marks

//              2) Change the type to the correct one: .Upper (for shirts and jackets), .Lower (pants and shorts),
//                  .Foot (for shoes), or .Other (any other item, will always appear if suitable for weather)
//                  This field ensures the sentence doesn't instruct users to wear multiple items, but rather
//                  (randomly) chooses one of each type if needed.

//              3) Replace the blue numbers with the maximum and minimum temperature you would use the item.
//                  Note: The algorithm allows for some leeway above and below the temperature

//              4) (Optional) If you wear an item because of rain, add ", rain: true" between the highTemp
//                  number and the closing ')'. If don't wear an item because of rain, add ", rain: false"
//                  in the same location

//              If you wish to add more items, copy and paste an exisitng itemX variable and change X to
//              a new number. Change the appropriate values, and add ", [new variable name]" between the 
//              last item and ']' in the items variable.

let item1 = Item(name: "stylish WWDC jacket", type: .Upper, lowTemp: 40, highTemp: 65)
let item2 = Item(name: "plaid shirt", type: .Upper, lowTemp: 46, highTemp: 58)
let item3 = Item(name: "shorts", type: .Lower, lowTemp: 62, highTemp: 100)
let item4 = Item(name: "winter coat", type: .Upper, lowTemp: 0, highTemp: 35)
let item5 = Item(name: "t-shirt", type: .Upper, lowTemp: 55, highTemp: 100)
let item6 = Item(name: "flip flops", type: .Foot, lowTemp: 80, highTemp: 100, rain: false)
let item7 = Item(name: "rain jacket", type: .Upper, lowTemp: 35, highTemp: 100, rain: true)
let item8 = Item(name: "jeans", type: .Lower, lowTemp: 0, highTemp: 62)

let items = [item1, item2, item3, item4, item5, item6, item7, item8]


//CHANGING THE TIME RANGE

//Note: This is the range that algorithm will check the weather in. If outside the range, the algorithm will
//calculate the next day's range's data

//Instructions: Enter desired times in 24H format (e.g. 11AM = 11, 11PM = 23) below
//              in each set of parantheses in this format: (HH, MM)

let range = timeInitializer(start: (9, 00), end: (23, 00))


//TEMPERATURE PREFERENCES - UNITS AND HOT / COLD

//Instructions: Change the Units suffix and temperatures to your liking. Consider hot to be decently warm.

let units = Units.US
// .US - ºF, mph, mi
// .CA - ºC, kmph, km
// .UK2 - ºC, mph, mi
// .SI - ºC, m/s, km

let coldTemperature: Float = 36
let hotTemperature: Float = 82
let tempPref = (coldTemperature, hotTemperature)


//ADVANCED SETTINGS

let wiggle: Int = 4
//the amount of leeway the algorithm uses. The algorithm will still reccomend an item
//even if the temperature is X degrees above or below the item's low and high temperature

let rainTolerance: Float = 0.06
//changes the amount of rain that triggers "definetly" instead "might" for reccomending the
//umbrella, API provides a *very* rough guide below (must be between 0 and 1)
//  `0.002` - very light precipitation    `0.017` - light precipitation
//  `0.1` - moderate precipitation         0.4` - heavy precipitation

let windTolerance: Float = 12
//changes the speed of the wind that triggers the reccomendation of a kite

let sunTolerance: Float = 0.2
//changes the percentage of cloud cover that triggers the reccomendation of sunglasses

let feelsLike: Bool = true
// while true, The Sentence's temperatures are apparent ("feels like") temperatures
// while false, The Sentence's temperatures are actual temperatures
// Note: The Sentence will always use apparent temperatures when calculating items to wear / bring

let weatherPref: (Float, Float, Float) = (rainTolerance, windTolerance, sunTolerance)


//////// DO NOT CHANGE ANYTHING BELOW THIS LINE //////////

let forecastCall = APIClient(apiKey: "b814e799b5f8d7e173b46d0fac28bd0f")
forecastCall.units = units
var sentence: String = ""

forecastCall.getForecast(latitude: latitude, longitude: longitude) { (currentForecast, error) -> Void in
    if let currentForecast = currentForecast {
        currentForecast.flags!.feelsLike = feelsLike
        sentence = theSentence(items: items, forecast: currentForecast, range: range, temp: true, constants: (tempPref, wiggle, weatherPref))
        print("\(sentence)")
    } else if let error = error {
        print("\nerror: forecast didn't load\n\(error)")
    }
}
