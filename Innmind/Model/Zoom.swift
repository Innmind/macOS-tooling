//
//  Zoom.swift
//  Innmind
//
//  Created by Baptouuuu on 13/11/2021.
//

import Foundation

enum Zoom {
    case min
    case middle
    case max

    func name() -> String {
        switch self {
        case .min:
            return "25%"
        case .middle:
            return "50%"
        case .max:
            return "100%"
        }
    }

    func toCGFloat() -> CGFloat {
        switch self {
        case .min:
            return 0.25
        case .middle:
            return 0.5
        case .max:
            return 1.0
        }
    }
}
