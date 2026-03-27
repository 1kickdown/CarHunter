//
//  CarSpecs.swift
//  CarHunter
//
//  Created by kickdown on 22.02.2026.
//
import Foundation

struct CarSpecs: Codable, Sendable {
    let engineType: String?
    let engineSize: Double?
    let horsepower: Int?
    let fuelConsumptionCity: Double?
    let fuelConsumptionHighway: Double?
    let fuelConsumptionCombined: Double?
    let transmission: String?
    let driveType: String?
    let acceleration: Double?
    let maxSpeed: Int?
    let weight: Int?
    let co2Emissions: Int?
    let imageUrl: String?
    
    let year: Int
    let make: String
    let model: String
    
    // В структурах init создается автоматически, но мы можем оставить статическое свойство для удобства
    static var empty: CarSpecs {
        CarSpecs(
            engineType: nil,
            engineSize: nil,
            horsepower: nil,
            fuelConsumptionCity: nil,
            fuelConsumptionHighway: nil,
            fuelConsumptionCombined: nil,
            transmission: nil,
            driveType: nil,
            acceleration: nil,
            maxSpeed: nil,
            weight: nil,
            co2Emissions: nil,
            imageUrl: nil,
            year: 0,
            make: "",
            model: ""
        )
    }
}
