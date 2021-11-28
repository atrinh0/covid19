//
//  Int+Extensions.swift
//  covid19
//
//  Created by An Trinh on 28/11/2021.
//

import Foundation

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for: NSNumber(value: self)) ?? ""
    }
}
