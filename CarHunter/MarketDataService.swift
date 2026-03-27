//
//  MarketDataService.swift
//  CarHunter
//
//  Created by kickdown on 19.02.2026.
//


import Foundation
import SwiftData
import WidgetKit

enum MarketPlatform: String, CaseIterable, Identifiable {
    case hasznaltauto = "🇭🇺 Használtautó"
    case kolesa = "🇰🇿 Kolesa.kz"
    case both = "🌍 Обе площадки"
    
    var id: String { self.rawValue }
}

class MarketDataService {
    private let hasznaltautoParser = HasznaltautoParser()
    private let kolesaParser = KolesaParser()
    private let modelContext: ModelContext
    
    var selectedPlatform: MarketPlatform = .both
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        if let saved = UserDefaults.standard.string(forKey: "selectedPlatform"),
           let platform = MarketPlatform(rawValue: saved) {
            selectedPlatform = platform
        }
    }
    
    // Поиск объявлений для конкретной машины
    func searchListings(for car: CarModel, completion: @escaping ([CarListing]) -> Void) {
        var allListings: [CarListing] = []
        let group = DispatchGroup()
        
        if selectedPlatform == .hasznaltauto || selectedPlatform == .both {
            group.enter()
            let url = hasznaltautoParser.searchURL(brand: car.brand, model: car.model)
            hasznaltautoParser.parseListings(from: url, brand: car.brand, model: car.model) { listings in
                allListings.append(contentsOf: listings)
                group.leave()
            }
        }
        
        if selectedPlatform == .kolesa || selectedPlatform == .both {
            group.enter()
            let url = kolesaParser.searchURL(brand: car.brand, model: car.model)
            kolesaParser.parseListings(from: url, brand: car.brand, model: car.model) { listings in
                allListings.append(contentsOf: listings)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Обновляем статистику в модели car
            let prices = allListings.map { $0.price }.filter { $0 > 0 }
            car.averageMarketPrice = prices.isEmpty ? 0 : prices.reduce(0, +) / prices.count
            car.listingCount = allListings.count
            // Хорошие предложения: цена ниже средней на 15%
            let avg = car.averageMarketPrice
            if avg > 0 {
                car.goodDealsCount = allListings.filter { $0.price < avg * 85 / 100 }.count
            } else {
                car.goodDealsCount = 0
            }
            car.lastUpdated = Date()
            
            try? self.modelContext.save()
            self.updateWidgetData()
            completion(allListings)
        }
    }
    
    // Обновить данные для всех машин (для фонового обновления)
    func refreshAllCars(completion: @escaping () -> Void) {
        let fetchDescriptor = FetchDescriptor<CarModel>(predicate: #Predicate { $0.isActive == true })
        guard let cars = try? modelContext.fetch(fetchDescriptor) else {
            completion()
            return
        }
        
        let group = DispatchGroup()
        for car in cars {
            group.enter()
            searchListings(for: car) { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func updateWidgetData() {
        let fetchDescriptor = FetchDescriptor<CarModel>(predicate: #Predicate { $0.isActive == true })
        guard let cars = try? modelContext.fetch(fetchDescriptor) else { return }
        
        let platform: String
        switch selectedPlatform {
        case .hasznaltauto: platform = "🇭🇺"
        case .kolesa: platform = "🇰🇿"
        case .both: platform = "🌍"
        }
        
        let widgetData = cars.map { car in
            WidgetCarData(
                id: car.uid.uuidString,
                brand: car.brand,
                model: car.model,
                averagePrice: car.averageMarketPrice,
                listingCount: car.listingCount,
                goodDealsCount: car.goodDealsCount,
                lastUpdated: car.lastUpdated ?? Date(),
                minPrice: car.minPrice ?? 0,
                maxPrice: car.maxPrice ?? 0,
                platform: platform
            )
        }
        
        WidgetDataStorage.save(widgetData)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
