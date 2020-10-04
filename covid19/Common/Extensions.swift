//
//  Extensions.swift
//  covid19
//
//  Created by An Trinh on 4/10/20.
//

import Foundation

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for:  NSNumber(value: self)) ?? ""
    }
}
