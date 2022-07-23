//
//  String+Extensions.swift
//  covid19
//
//  Created by An Trinh on 23/07/2022.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}
