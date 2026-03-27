//
//  CarHunterApp.swift
//  CarHunter
//
//  Created by kickdown on 18.02.2026.
//

import SwiftUI
import SwiftData

@main
struct CarHunterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: CarModel.self)
    }
}
