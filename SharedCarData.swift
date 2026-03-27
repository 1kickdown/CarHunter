//
//  SharedCarData.swift
//  CarHunter
//
//  Created by kickdown on 19.02.2026.
//

import Foundation
import SwiftData
import WidgetKit

struct WidgetCarData: Codable, Identifiable{
    let id: String
    let brand: String
    let model: String
    let averagePrice: Int
    let listingCount: Int
    let goodDealsCount: Int
    let lastUpdated: Date
    let minPrice: Int
    let maxPrice: Int
    let platform: String // "🇭🇺", "🇰🇿", "🌍"
    
    init(id: String,
         brand: String,
         model: String,
         averagePrice: Int,
         listingCount: Int,
         goodDealsCount: Int,
         lastUpdated: Date,
         minPrice: Int,
         maxPrice: Int,
         platform: String = "🌍") {
        
        self.id = id
        self.brand = brand
        self.model = model
        self.averagePrice = averagePrice
        self.listingCount = listingCount
        self.goodDealsCount = goodDealsCount
        self.lastUpdated = lastUpdated
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.platform = platform
    }
    
    
    var progressToBudget: Double {
        guard maxPrice > minPrice else { return 0}
        
        let progress = Double (averagePrice - minPrice) / Double(maxPrice - minPrice)
        
        return min(max(progress, 0), 1)
    }
    
    var isGoodDealAvailable: Bool {
        goodDealsCount > 0
    }
    
    
    var platformIcon: String {
        switch platform {
            case "🇭🇺": return "🏰"
            case "🇰🇿": return "🏔️"
            default: return "🌍"
        }
    }
    
    var platformColor: String {
        switch platform {
            case "🇭🇺": return "красный"
            case "🇰🇿": return "голубой"
            default: return "зеленый"
        }
    }
}

struct WidgetDataStorage {
    static let appGroup = "group.com.kckdwn.CarHunter"
    
    static func save(_ cars: [WidgetCarData]) {
        guard let userDefaults = UserDefaults(suiteName: appGroup) else{
            print("❌ НЕ УДАЛОСЬ ПОЛУЧИТЬ UserDefaults для группы: \(appGroup)")
            return
        }
        
        
        do {
            let encoded = try JSONEncoder().encode(cars)
            userDefaults.set(encoded, forKey: "widgetCars")
            userDefaults.synchronize()
            print("✅ Сохранено \(cars.count) машин в UserDefaults")
                
            // Для отладки выведем первую машину
            if let first = cars.first {
                print("   Первая: \(first.brand) \(first.model), платформа: \(first.platform)")
            }
        } catch {
            print("❌ Ошибка кодирования: \(error)")
        }
        
//        if let encoded = try? JSONEncoder().encode(cars) {
//            userDefaults.set(encoded, forKey: "widgetCars")
//            
//            WidgetCenter.shared.reloadAllTimelines() 
//        }
    }
    
    static func load() -> [WidgetCarData] {
        guard let userDefaults = UserDefaults(suiteName: appGroup) else {
            print("❌ Не удалось получить UserDefaults для группы: \(appGroup)")
            return []
        }
        
        guard let data = userDefaults.data(forKey: "widgetCars") else {
            print("ℹ️ Нет данных по ключу widgetCars")
            return []
        }
        
        do {
            let cars = try JSONDecoder().decode([WidgetCarData].self, from: data)
            print("✅ Загружено \(cars.count) машин из UserDefaults")
            
            // Для отладки выведем первую машину
            if let first = cars.first {
                print("   Первая: \(first.brand) \(first.model), платформа: \(first.platform)")
            }
                
            return cars
        } catch {
            print("❌ Ошибка декодирования: \(error)")
            return []
        }
    }
    
//    static func load() -> [WidgetCarData] {
//        guard let userDefaults = UserDefaults(suiteName: appGroup),
//              let data = userDefaults.data(forKey: "widgetCars"),
//              let cars = try? JSONDecoder().decode([WidgetCarData].self, from: data) else {
//            return []
//        }
//        
//        return cars
//    }
    
    static func clear() {
        guard let userDefaults = UserDefaults(suiteName: appGroup) else { return }
        userDefaults.removeObject(forKey: "widgetCars")
        userDefaults.synchronize()
        print("🧹 Данные виджета очищены")
    }
}

