//
//  Formatters.swift
//  FoodLens
//
//  Created by Melanie Escobar on 12/1/25.
//

import Foundation

struct DateFormatterUtil {
    static let pretty: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
}
