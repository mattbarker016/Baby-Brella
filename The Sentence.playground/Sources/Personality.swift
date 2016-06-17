//
// Personality.swift
// Project Icicle
//
// Created by Matt Barker on 6/13/16.
// Copyright © 2016 Matt Barker. All rights reserved.
//

import Foundation

public struct Personality {
    
    /** Lines used before a fragment of selected items for today.
     End with "your" for best results */
    public let wearToday: [String] =
        ["You should wear your",
         "Today's a great day to wear your",
         "I'd throw on your",
         "It's a good day to wear your",
         "Your wardrobe for today is your",
         "My fashion algorithms suggest wearing your",
         "Today's ravishing robot-created outfit is your",
         "Today's fabulous outfit selection is your",
         "You're going to save the world wearing your",
         "You'll be amazing today wearing your",
         "Strut that catwalk wearing your",
         "Your superhero costume for today is your"
    ]
    
    /** Lines used before a fragment of selected items for tomorrow.
     End with "your" for best results */
    public let wearTomorrow : [String] =
        ["Tomorrow, you should wear your",
         "Tomorrow's a great day to wear your",
         "Tomorrow, I'd throw on your",
         "tomorrow is a good day to wear your",
         "Your wardrobe for tomorrow is your",
         "Tomorrow, my fashion algorithms suggest wearing your",
         "Tomorrow's ravishing robot-created outfit is your",
         "Tomorrow's fabulous outfit selection is your",
         "Tomorrow, you're going to save the world wearing your",
         "You'll be amazing tomorrow wearing your",
         "Strut that catwalk tomorrow wearing your",
         "Your superhero costume for tomorrow is your"
    ]
    
    /** Verbs equivalent to "bring" */
    public let bring: [String] = ["bring", "take", "pack"]
    
    /** Lines used when the temperature equals or is above the user's definition of chot.
     Must end with "wear your" */
    public let wearHot: [String] =
        ["Phew, it's hot! Stay cool and wear your",
         "Whew, it's hot! Get a cold drink and wear your",
         "Make sure you fry an egg on the sidewalk and wear your",
         "It's so darn hot that milk is a bad choice. You should wear your"
    ]
    
    /** Lines used when the temperature equals or is below the user's definition of cold.
     Must end with "wear your" */
    public let wearCold: [String] =
        ["Brr, it's cold! Stay warm and wear your",
         "Brr, it's cold! Make some hot cocoa and wear your",
         "Frosty might even shiver! You should wear your",
         "It's colder than your ex's heart, so wear your"
    ]
    
    /** Lines used BEFORE an umbrella reccomendation. Must end with either "you" or "You" */
    public let rainBefore: [String] =
        ["Unfortunately, water is still wet. You",
         "Rihanna already has one, but you",
         "Rain, rain, go away. You",
         "You shouldn't need an ark, but you",
         "I stuck my virtual hand out the window, and you",
         "H2-Oh no! You",
         "I detect trace amounts of H2O in the atmosphere. You",
         "Like Singin' in the Rain? Great news, because you",
         "It's rainin' men (or water), hallelujah! You",
         "The rain drops keep fallin' on my head, so you"
    ]
    
    /** Lines used AFTER an umbrella reccomendation. Needs period to begin,
     and a single space at the end after punctuation */
    public let rainAfter: [String] =
        [". Hope there's no parade today. ",
         ". Make sure you keep me dry too! ",
         ". The forecast didn't mention cats or dogs. ",
         ". Classic water cycle. ",
         ". Let the itsy bitsy spider know! ",
         ". You probably won't need a canoe. "
    ]
    
    public init() { }
    
}
