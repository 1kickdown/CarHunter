//
//  CarHunterWidget.swift
//  CarHunterWidget
//
//  Created by kickdown on 19.02.2026.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
            SimpleEntry(date: Date(), cars: [
                WidgetCarData(
                    id: "1",
                    brand: "Skoda",
                    model: "Octavia",
                    averagePrice: 3_200_000,
                    listingCount: 12,
                    goodDealsCount: 2,
                    lastUpdated: Date(),
                    minPrice: 2_500_000,
                    maxPrice: 4_000_000
                )
            ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
            let cars = WidgetDataStorage.load()
            let entry = SimpleEntry(date: Date(), cars: cars)
            completion(entry)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
            let cars = WidgetDataStorage.load()
            let entry = SimpleEntry(date: Date(), cars: cars)
            
            // Обновляем каждый час
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cars: [WidgetCarData]
}

struct CarHunterWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            mediumWidget
        }
    }
    
    var smallWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("🚗 My cars")
                    .font(.caption)
                    .bold()
                    
                Spacer()
                    
                if let first = entry.cars.first {
                    Text(first.platform)
                        .font(.caption2)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
                
            if let first = entry.cars.first {
                Text("\(first.brand) \(first.model)")
                    .font(.headline)
                    
                if first.averagePrice > 0 {
                    Text("\(first.averagePrice.formatted()) Ft")
                        .font(.caption)
                        .bold()
                }
                    
                    // Прогресс бюджет
                ProgressView(value: first.progressToBudget)
                    .tint(first.progressToBudget > 1 ? .red : .green)
                    
                HStack {
                    if first.isGoodDealAvailable {
                        Label("\(first.goodDealsCount) 🔥", systemImage: "bolt.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                        
                    Spacer()
                        
                    Text(first.platformIcon)
                        .font(.caption2)
                }
                    
                if entry.cars.count > 1 {
                    Text("и еще \(entry.cars.count - 1)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No cars")
                Text("Add in app")
                    .font(.caption2)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
        
    var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🚗 My future cars")
                    .font(.headline)
                    
                Spacer()
                    
                if let first = entry.cars.first {
                    Text(first.platform)
                        .font(.caption2)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
                
            ForEach(entry.cars.prefix(3)) { car in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(car.brand) \(car.model)")
                            .font(.subheadline)
                            .bold()
                            
                        Spacer()
                            
                            // Иконка платформы
                        Text(car.platformIcon)
                            .font(.caption2)
                            
                        if car.averagePrice > 0 {
                            Text("\(car.averagePrice.formatted()) Ft")
                                .font(.caption)
                        }
                            
                        if car.isGoodDealAvailable {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                        
                    HStack {
                        ProgressView(value: car.progressToBudget)
                            .tint(car.progressToBudget > 1 ? .red : .green)
                            
                        Text("\(car.listingCount) ads")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            
                        Spacer()
                            
                        // Показываем площадку цветом
                        Circle()
                            .fill(car.platform == "🇭🇺" ? .red :
                                    car.platform == "🇰🇿" ? .blue : .green)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 2)
            }
            
            if entry.cars.isEmpty {
                Text("Open CarHunter app")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct CarHunterWidget: Widget {
    let kind: String = "CarHunterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CarHunterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My cars")
        .description("Keep an eye on the prices of tracked cars")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemMedium) {
    CarHunterWidget()
} timeline: {
    SimpleEntry(date: .now, cars: [])
}
