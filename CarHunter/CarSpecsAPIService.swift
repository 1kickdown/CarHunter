//
//  CarSpecsAPIService.swift
//  CarHunter
//
//  Created by kickdown on 22.02.2026.
//

import Foundation

class CarSpecsAPIService {
    
    private let baseURL = "https://www.carqueryapi.com/api/0.3/"
    
    func fetchSpecs(for make: String, model: String, year: Int, completion: @escaping (CarSpecs?) -> Void) {
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "callback", value: "?"),
            URLQueryItem(name: "cmd", value: "getTrims"),
            URLQueryItem(name: "make", value: make),
            URLQueryItem(name: "model", value: model),
            URLQueryItem(name: "year", value: String(year))
        ]
        
        guard let url = components?.url else {
            completion(nil)
            return
        }
        
        print("🌐 CarQuery URL: \(url)")
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
 
            if let error = error {
                print("❌ CarQuery network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
  
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 CarQuery status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ CarQuery: no data received")
                completion(nil)
                return
            }
            
            // Выводим первые 200 символов ответа для отладки
            if let dataString = String(data: data, encoding: .utf8) {
                let preview = String(dataString.prefix(200))
                print("📄 CarQuery response preview: \(preview)")
            }
            
            guard let dataString = String(data: data, encoding: .utf8) else {
                print("❌ CarQuery: cannot convert data to string")
                completion(nil)
                return
            }
            
 
            var jsonString = dataString
            if jsonString.hasPrefix("?(") {
                jsonString = String(jsonString.dropFirst(2))
            }
            if jsonString.hasSuffix(");") {
                jsonString = String(jsonString.dropLast(2))
            }
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                print("❌ CarQuery: cannot convert to JSON data")
                completion(nil)
                return
            }
            
            do {

                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    print("📊 CarQuery JSON keys: \(json.keys)")
                    
                    if let trims = json["Trims"] as? [[String: Any]] {
                        print("✅ Found \(trims.count) trims")
                        
                        if let firstTrim = trims.first {
                            print("🔍 First trim keys: \(firstTrim.keys)")
                            let specs = self.parseTrim(firstTrim, make: make, model: model, year: year)
                            completion(specs)
                        } else {
                            print("⚠️ No trims found")
                            completion(nil)
                        }
                    } else {
                        print("⚠️ No Trims array in response")
                        completion(nil)
                    }
                } else {
                    print("⚠️ Invalid JSON format")
                    completion(nil)
                }
            } catch {
                print("❌ CarQuery parse error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    private func parseTrim(_ trim: [String: Any], make: String, model: String, year: Int) -> CarSpecs {
        let engineType = trim["model_engine_type"] as? String
        
        // В API объем двигателя в CC (см3), переводим в Литры
        let engineSize: Double? = {
            if let val = trim["model_engine_cc"] as? String, let dbl = Double(val) {
                return dbl / 1000.0
            }
            return nil
        }()
        
        // В логах ключ: model_engine_power_ps (это почти то же самое, что HP)
        let horsepower: Int? = {
            if let val = trim["model_engine_power_ps"] as? String {
                return Int(val)
            }
            return nil
        }()
        
        // Расход топлива в литрах на 100 км (LKM)
        let fuelCity: Double? = {
            if let val = trim["model_lkm_city"] as? String { return Double(val) }
            return nil
        }()
        
        let fuelHighway: Double? = {
            if let val = trim["model_lkm_hwy"] as? String { return Double(val) }
            return nil
        }()
        
        let transmission = trim["model_transmission_type"] as? String
        let driveType = trim["model_drive"] as? String
        let acceleration = Double(trim["model_0_to_100_kph"] as? String ?? "")
        let maxSpeed = Int(trim["model_top_speed_kph"] as? String ?? "")
        let weight = Int(trim["model_weight_kg"] as? String ?? "")

        return CarSpecs(
            engineType: engineType,
            engineSize: engineSize,
            horsepower: horsepower,
            fuelConsumptionCity: fuelCity,
            fuelConsumptionHighway: fuelHighway,
            fuelConsumptionCombined: nil,
            transmission: transmission,
            driveType: driveType,
            acceleration: acceleration,
            maxSpeed: maxSpeed,
            weight: weight,
            co2Emissions: nil,
            imageUrl: nil,
            year: year,
            make: make,
            model: model
        )
    }
}
