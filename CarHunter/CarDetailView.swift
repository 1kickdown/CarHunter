//
//  CarDetailView.swift
//  CarHunter
//
//  Created by kickdown on 19.02.2026.
//

import SwiftUI
import SwiftData
import SafariServices

struct CarDetailView: View {
    @Bindable var car: CarModel
    @Environment(\.modelContext) private var modelContext
    @State private var listings: [CarListing] = []
    @State private var isLoading = false
    @State private var showingSafari = false
    @State private var selectedURL: URL?
    
    var body: some View {
        List {
            Section("Information") {
                LabeledContent("Brand", value: car.brand)
                LabeledContent("Model", value: car.model)
                if let year = car.yearFrom {
                    LabeledContent("Year", value: "\(year)")
                }
                if let engine = car.engineSize {
                    LabeledContent("Engine", value: "\(engine) л")
                }
                if let fuel = car.fuelType {
                    LabeledContent("Fuel", value: fuel)
                }
                if let hp = car.horsepower {
                    LabeledContent("Horsepower", value: "\(hp) л.с.")
                }
                if let notes = car.notes, !notes.isEmpty {
                    LabeledContent("Notes", value: notes)
                }
            }
            


            if let specs = car.specs {
                Section("Specifications") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            if let engine = specs.engineSize {
                                SpecIconView(systemName: "engine.combustion",
                                            value: String(format: "%.1f л", engine),
                                            label: "Engine")
                            }
                            
                            if let hp = specs.horsepower {
                                SpecIconView(systemName: "bolt",
                                            value: "\(hp)",
                                            label: "HP")
                            }
                            
                            if let fuel = specs.fuelConsumptionCity {
                                SpecIconView(systemName: "fuelpump",
                                            value: String(format: "%.1f", fuel),
                                            label: "City l/100")
                            }
                            
                            if let fuelHighway = specs.fuelConsumptionHighway {
                                SpecIconView(systemName: "road.lanes",
                                            value: String(format: "%.1f", fuelHighway),
                                            label: "Highway")
                            }
                            
                            if let trans = specs.transmission {
                                let icon = trans.lowercased().contains("auto") ? "gearshape.2" : "gearshape"
                                let transmissionType = trans.prefix(4)
                                SpecIconView(systemName: icon,
                                            value: String(transmissionType),
                                            label: "Gearbox")
                            }
                            
                            if let drive = specs.driveType {
                                SpecIconView(systemName: "car",
                                            value: drive,
                                            label: "Drive")
                            }
                            
                            if let accel = specs.acceleration {
                                SpecIconView(systemName: "speedometer",
                                            value: String(format: "%.1f", accel),
                                            label: "0-100")
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            
            if let minPrice = car.minPrice, let maxPrice = car.maxPrice {
                Section("Budget") {
                    LabeledContent("From", value: "\(minPrice.formatted()) Ft")
                    LabeledContent("To", value: "\(maxPrice.formatted()) Ft")
                }
            }
            
            Section("Market") {
                if let lastUpdated = car.lastUpdated {
                    LabeledContent("Updated", value: lastUpdated.formatted(date: .abbreviated, time: .shortened))
                }
                LabeledContent("Found Ads", value: "\(car.listingCount)")
                if car.averageMarketPrice > 0 {
                    LabeledContent("Average price", value: "\(car.averageMarketPrice.formatted()) Ft")
                }
                if car.goodDealsCount > 0 {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text("\(car.goodDealsCount) good offers!")
                            .foregroundColor(.green)
                    }
                }
            }
            
            Section("Options") {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if listings.isEmpty {
                    Text("No options")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(listings) { listing in
                        ListingRowView(listing: listing)
                            .onTapGesture {
                                if let url = URL(string: listing.url) {
                                    selectedURL = url
                                    showingSafari = true
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("\(car.brand) \(car.model)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: refreshListings) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isLoading)
            }
        }
        .sheet(isPresented: $showingSafari) {
            if let url = selectedURL {
                SafariView(url: url)
            }
        }
        .onAppear {
            if listings.isEmpty {
                refreshListings()
            }
        }
    }
    
    private func refreshListings() {
        isLoading = true
        let service = MarketDataService(modelContext: modelContext)
        service.searchListings(for: car) { fetchedListings in
            listings = fetchedListings
            isLoading = false
        }
    }
}

struct ListingRowView: View {
    let listing: CarListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(listing.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(listing.source)
                    .font(.caption)
                    .padding(4)
                    .background(listing.source == "Kolesa" ? Color.blue.opacity(0.2) : Color.red.opacity(0.2))
                    .cornerRadius(4)
            }
            
            HStack {
                Text(listing.priceFormatted)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.green)
                Spacer()
                if let year = listing.year {
                    Text("\(year) y.")
                        .font(.subheadline)
                }
                if let mileage = listing.mileage {
                    Text("\(mileage.formatted()) km")
                        .font(.subheadline)
                }
            }
            
            HStack {
                if let engine = listing.engineSize, !engine.isEmpty {
                    Text(engine)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(listing.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Для отображения Safari
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}



//#Preview {
//    CarDetailView()
//}
