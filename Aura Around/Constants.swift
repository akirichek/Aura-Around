//
//  Constants.swift
//  Aura Around
//
//  Created by Artem Kirichek on 6/5/17.
//  Copyright © 2017 Artem Kirichek. All rights reserved.
//

import Foundation

struct K {
    struct Storyboard {
        struct SegueIdentifier {
            static let AuraIntro = "AuraIntroSegueIdentifier"
        }
    }
}

enum AuraColors: Int, CustomStringConvertible {
    case Red = 1
    case Orange = 2
    case Yellow = 3
    case Green = 4
    case Blue = 5
    case Indigo = 6
    case Violet = 7
    case Pink = 8
    case Bronze = 9
    case Silver = 11
    case Gold = 22
    
    var description : String {
        switch self {
        case .Red: return "Red"
        case .Orange: return "Orange"
        case .Yellow: return "Yellow"
        case .Green: return "Green"
        case .Blue: return "Blue"
        case .Indigo: return "Indigo"
        case .Violet: return "Violet"
        case .Pink: return "Pink"
        case .Bronze: return "Bronze"
        case .Silver: return "Silver"
        case .Gold: return "Gold"
        }
    }
}
