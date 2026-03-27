//
//  SettingsView.swift
//  CarHunter
//
//  Created by kickdown on 20.02.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedPlatform") private var selectedPlatformRaw = MarketPlatform.both.rawValue
    @Environment(\.dismiss) private var dismiss
    
    private var selectedPlatform: Binding<MarketPlatform> {
        Binding(
            get: { MarketPlatform(rawValue: selectedPlatformRaw) ?? .both},
            set: { selectedPlatformRaw = $0.rawValue }
        )
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Searching sites") {
                    Picker("Platfrom", selection: selectedPlatform) {
                        ForEach(MarketPlatform.allCases) { platform in
                            Text(platform.rawValue).tag(platform)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section("Information"){
                    VStack(alignment: .leading, spacing: 8) {
                        Label("🇭🇺 Használtautó.hu", systemImage: "car")
                            .font(.subheadline)
                        Text("Hungary")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Label("🇰🇿 Kolesa.kz", systemImage: "car")
                            .font(.subheadline)
                        Text("Kazakhstan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Exchange course") {
                    Text("1 HUF ~ 2 KZT")
                        .font(.caption)
                    Text("Prices are subject to change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar{
                ToolbarItem(placement: .confirmationAction){
                    Button("Done") {dismiss()}
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
