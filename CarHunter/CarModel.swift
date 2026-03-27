//
//  CarModel.swift
//  CarHunter
//
//  Created by kickdown on 18.02.2026.
//

import Foundation
import SwiftData


//extension CarSpecs: @unchecked Sendable {}


@Model

final class CarModel{
   
    
    var uid: UUID = UUID()

    
    var brand: String
    var model: String
    var yearFrom: Int?
    var YearTo: Int?
    var engineSize: Double?
    var fuelType: String?
    var horsepower: Int?
    var minPrice: Int?
    var maxPrice: Int?
    var isActive: Bool
    var notes: String?
    
    
    
    var averageMarketPrice: Int = 0
    var listingCount: Int = 0
    var lastUpdated: Date?
    var goodDealsCount: Int = 0
    
    var lastSource: String? {
        get {
            UserDefaults.standard.string(forKey: "lastSource_\(uid.uuidString)")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastSource_\(uid.uuidString)")
        }
    }
    

    var specsData: Data?
    
//    @Attribute(.transformable) var specsData: Data?
    
    init(brand: String,
             model: String,
             yearFrom: Int? = nil,
             engineSize: Double? = nil,
             fuelType: String? = nil,
             horsepower: Int? = nil,
             minPrice: Int? = nil,
            maxPrice: Int? = nil,
            uid: UUID = UUID()) {
            self.brand = brand
            self.model = model
            self.yearFrom = yearFrom
            self.engineSize = engineSize
            self.fuelType = fuelType
            self.horsepower = horsepower
            self.minPrice = minPrice
            self.maxPrice = maxPrice
            self.isActive = true
            self.uid = UUID()
            self.specsData = nil
        }
    
    var taxPerYear: Int? {
        guard let horsepower = horsepower else { return nil }
        let kw = Double(horsepower) * 0.736
        return Int(kw * 140)
    }
    
    var insuranceEstimate: String? {
        guard let engineSize = engineSize else { return nil }
        if engineSize < 1.4 {
            return "35 000 - 50 000 Ft/év"
        } else if engineSize < 2.0 {
            return "50 000 - 80 000 Ft/év"
        } else {
            return "80 000 - 120 000 Ft/év"
        }
    }
    

    
    var specs: CarSpecs? {
        get {
            guard let data = specsData else { return nil }
            return try? JSONDecoder().decode(CarSpecs.self, from: data)
        }
        set {
            specsData = try? JSONEncoder().encode(newValue)
        }
    }
}
