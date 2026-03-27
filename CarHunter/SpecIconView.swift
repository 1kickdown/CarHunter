//
//  SpecIconView.swift
//  CarHunter
//
//  Created by kickdown on 22.02.2026.
//

import SwiftUI

struct SpecIconView: View {
    let systemName: String
    let value: String
    let label: String
    
    init(systemName: String, value: String, label: String) {
        self.systemName = systemName
        self.value = value
        self.label = label
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            
            Text(value)
                .font(.caption)
                .bold()
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct CarSpecIconView: View {
    let iconName: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.caption)
                .bold()
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 65)
        .padding(6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    HStack {
        CarSpecIconView(iconName: "engine.combustion", value: "2.0 л", label: "Engine")
        CarSpecIconView(iconName: "bolt", value: "150 л.с.", label: "Power")
        CarSpecIconView(iconName: "fuelpump", value: "8.5 л", label: "Fuel")
    }
    .padding()
}
