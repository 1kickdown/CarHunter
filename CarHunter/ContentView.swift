//
//  ContentView.swift
//  CarHunter
//
//  Created by kickdown on 18.02.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<CarModel> { $0.isActive == true})
    private var cars: [CarModel]
    
    @State private var showingAddCar = false
    @State private var showingSettings = false
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(cars) { car in
                    NavigationLink{
                        CarDetailView(car: car)
                    } label: {
                        CarRowView(car: car)
                    }
                }
                .onDelete(perform: deleteCars)
            }
            .navigationTitle(Text("Car List"))
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: { showingSettings = true}){
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    HStack{
                        if isRefreshing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        Button(action: refreshAllData){
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(isRefreshing)
                        
                        Button(action: { showingAddCar = true}){
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddCar){
                AddCarView()
            }
            .sheet(isPresented: $showingSettings){
                SettingsView()
            }
        }
    }
    
    private func deleteCars(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cars[index])
        }
        updateWidgetData()
    }
    
    private func refreshAllData(){
        isRefreshing = true
        
        let service = MarketDataService(modelContext: modelContext)
        service.refreshAllCars{
            isRefreshing = false
        }
    }
    
    private func updateWidgetData() {
        let service = MarketDataService(modelContext: modelContext)
        service.updateWidgetData()
    }
    
}

struct CarRowView: View {
    let car: CarModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("\(car.brand) \(car.model)")
                    .font(.headline)
                
                Spacer()
                
                if let minPrice = car.minPrice, let maxPrice = car.maxPrice {
                    Text("\(minPrice.formatted()) - \(maxPrice.formatted()) Ft")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            

            if let specs = car.specs {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
       
                        if let engineSize = specs.engineSize {
                            SpecBadge(
                                icon: "engine.combustion",
                                value: String(format: "%.1f л", engineSize),
                                color: .blue
                            )
                        }
                        
  
                        if let hp = specs.horsepower {
                            SpecBadge(
                                icon: "bolt",
                                value: "\(hp) л.с.",
                                color: .orange
                            )
                        }
                        
     
                        if let fuel = specs.fuelConsumptionCity {
                            SpecBadge(
                                icon: "fuelpump",
                                value: String(format: "%.1f л", fuel),
                                color: .green
                            )
                        }
                        
                
                        if let transmission = specs.transmission {
                            let icon = transmission.lowercased().contains("auto") ? "gearshift.2" : "gearshift"
                            SpecBadge(
                                icon: icon,
                                value: transmission.prefix(4) == "Auto" ? "Auto" : "Manual",
                                color: .purple
                            )
                        }
                        
          
                        if let drive = specs.driveType {
                            let driveIcon = drive == "AWD" ? "4wd" : "car"
                            SpecBadge(
                                icon: driveIcon,
                                value: drive,
                                color: .indigo
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
 
                HStack {
                    Text("No specifications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Load") {
            
                        loadSpecsForCar(car)
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }
            }
            
      
            HStack {
                if car.listingCount > 0 {
                    Label("\(car.listingCount) ads", systemImage: "list.bullet")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if car.goodDealsCount > 0 {
                    Label("\(car.goodDealsCount) good deals", systemImage: "bolt.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
                
                if let lastUpdated = car.lastUpdated {
                    Text("Updated: \(lastUpdated.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func loadSpecsForCar(_ car: CarModel) {

    }
}


struct SpecBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.caption2)
                .bold()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
#Preview {
    ContentView()
}
