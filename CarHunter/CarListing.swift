//
//  CarListing.swift
//  CarHunter
//
//  Created by kickdown on 21.02.2026.
//

import Foundation


struct CarListing: Identifiable, Codable {
    let id = UUID()
    let title: String
    let price: Int
    let year: Int?
    let mileage: Int?
    let engineSize: String?
    let location: String
    let url: String
    let imageUrl: String?
    let source: String   // "Hasznaltauto" или "Kolesa"
    
    var priceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return (formatter.string(from: NSNumber(value: price)) ?? "\(price)") + " \(source == "Kolesa" ? "₸" : "Ft")"
    }
    
    var yearString: String {
        guard let year = year else { return "н/д" }
        return "\(year)"
    }
    
    var mileageString: String {
        guard let mileage = mileage else { return "н/д" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return (formatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)") + " км"
    }
}
