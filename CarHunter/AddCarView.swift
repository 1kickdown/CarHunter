//
//  AddCarView.swift
//  CarHunter
//
//  Created by kickdown on 18.02.2026.
//

import SwiftUI
import SwiftData

struct AddCarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var brand = ""
    @State private var model = ""
    @State private var minPrice: Int? = nil
    @State private var maxPrice: Int? = nil
    @State private var notes = ""
    
    
    ////////////////////////
    @State private var year = Calendar.current.component(.year, from: Date()) - 5
    @State private var isLoadingSpecs = false
    @State private var loadedSpecs: CarSpecs? = nil
    ///////////////////////
    
    
    
    var body: some View {
        NavigationStack{
            Form{
                Section("Brand and Model"){
                    TextField("Brand (BMW, Mercedes...", text: $brand)
                    TextField("Model (e60, S class...", text: $model)
                }
                
                
                Section("Price (Ft) - Optional"){
                    HStack{
                        Text("From")
                        TextField("Min", value: $minPrice, format: .number)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack{
                        Text("To")
                        TextField("Max", value: $maxPrice, format: .number)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Notes") {
                    TextField("E.g. year, engine...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                
                Section("Year (for specs)") {
                    Picker("Year", selection: $year) {
                        ForEach(1990...Calendar.current.component(.year, from: Date()), id: \.self) { y in
                            Text(String(y)).tag(y)
                        }
                    }
                }

                Section("Specifications") {
                    if isLoadingSpecs {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if let specs = loadedSpecs {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                if let engineSize = specs.engineSize {
                                    SpecIconView(
                                        systemName: "engine.combustion",
                                        value: String(format: "%.1f l", engineSize),
                                        label: "Engine"
                                    )
                                }
                                
                                if let hp = specs.horsepower {
                                    SpecIconView(
                                        systemName: "bolt",
                                        value: "\(hp)",
                                        label: "Horsepower"
                                    )
                                }
                                
                                if let fuelCity = specs.fuelConsumptionCity {
                                    SpecIconView(
                                        systemName: "fuelpump",
                                        value: String(format: "%.1f", fuelCity),
                                        label: "City l/100"
                                    )
                                }
                                
                                if let fuelHighway = specs.fuelConsumptionHighway {
                                    SpecIconView(
                                        systemName: "road.lanes",
                                        value: String(format: "%.1f", fuelHighway),
                                        label: "Highway"
                                    )
                                }
                                
                                if let transmission = specs.transmission {
                                    let icon = transmission.lowercased().contains("auto") ? "gearshape.2" : "gearshape"
                                    SpecIconView(
                                        systemName: icon,
                                        value: transmission,
                                        label: "Transmission"
                                    )
                                }
                                
                                if let driveType = specs.driveType {
                                    SpecIconView(
                                        systemName: "car",
                                        value: driveType,
                                        label: "Drive"
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    } else {
                        Text("No specs loaded")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Load from Internet") {
                        loadSpecs()
                    }
                    .disabled(brand.isEmpty || model.isEmpty)
                }

                
            }
            .navigationTitle("NEW Car")
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction){
                    Button("Add"){
                        saveCar()
                    }
                }
            }
        }
    }
    
    private func saveCar() {
        let car = CarModel(
            brand: brand,
            model: model,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
        
        if let specs = loadedSpecs {
            car.specs = specs
        }
        
        car.notes = notes.isEmpty ? nil : notes
        modelContext.insert(car)
        dismiss()
    }
    
    private func loadSpecs() {
        isLoadingSpecs = true
        print("🔍 Loading specs for \(brand) \(model) \(year)")
        
        let service = CarSpecsAPIService()
        service.fetchSpecs(for: brand, model: model, year: year) { specs in
            DispatchQueue.main.async {
                if let specs = specs {
                    print("✅ Successfully loaded specs")
                    self.loadedSpecs = specs
                } else {
                    print("❌ Failed to load specs")

//                    self.createTestSpecs()
                }
                self.isLoadingSpecs = false
            }
        }
    }

//    //////////////////////// TEST
//    private func createTestSpecs() {
//        let testSpecs = CarSpecs(
//            engineType: "Gasoline",
//            engineSize: 2.0,
//            horsepower: 150,
//            fuelConsumptionCity: 9.5,
//            fuelConsumptionHighway: 6.2,
//            fuelConsumptionCombined: 7.8,
//            transmission: "Manual",
//            driveType: "FWD",
//            acceleration: 8.5,
//            maxSpeed: 220,
//            weight: 1450,
//            co2Emissions: 160,
//            imageUrl: nil,
//            year: year,
//            make: brand,
//            model: model
//        )
//        self.loadedSpecs = testSpecs
//    }
}

#Preview {
    AddCarView()
}
