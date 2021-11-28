//
//  Double+Extensions.swift
//  covid19
//
//  Created by An Trinh on 4/10/20.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
