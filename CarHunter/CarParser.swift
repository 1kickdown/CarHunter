//
//  CarParser.swift
//  CarHunter
//
//  Created by kickdown on 19.02.2026.
//

import Foundation
import SwiftSoup


//struct CarListing: Identifiable, Codable {
//    let id = UUID()
//    let title: String
//    let price: Int
//    let year: Int?
//    let mileage: Int?
//    let engineSize: String?
//    let location: String
//    let url: String
//    let imageUrl: String?
//    let source: String   // "Hasznaltauto" или "Kolesa"
//    
//    var priceFormatted: String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.groupingSeparator = " "
//        return (formatter.string(from: NSNumber(value: price)) ?? "\(price)") + " \(source == "Kolesa" ? "₸" : "Ft")"
//    }
//    
//    var yearString: String {
//        guard let year = year else { return "н/д" }
//        return "\(year)"
//    }
//    
//    var mileageString: String {
//        guard let mileage = mileage else { return "н/д" }
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.groupingSeparator = " "
//        return (formatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)") + " км"
//    }
//}



class CarParser {
    
    
    
    func searchURL(for car: CarModel) -> String {
        _ = "\(car.brand) \(car.model)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var url = "https://www.hasznaltauto.hu/szemelyauto/\(car.brand)/\(car.model)"
        
        url += "?ar_tol=\(car.minPrice)&ar_ig=\(car.maxPrice)"
                
        url += "&evjarat_tol=\(car.yearFrom)"
                
        return url
    }
    
    
    func searchURL(brand: String, model: String) -> String {
        let b = brand.lowercased()
        let m = model.lowercased()
        return "https://www.hasznaltauto.hu/szemelyauto/\(b)/\(m)"
    }
    
    func parseListings(from urlString: String, completion: @escaping ([CarListing]) -> Void){
        guard let url = URL(string: urlString) else{
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Ошибка загрузки: \(error?.localizedDescription ?? "Unknown")")
                completion([])
                return
            }
                    
            guard let html = String(data: data, encoding: .utf8) else {
                completion([])
                return
            }
                    
            // Парсим HTML
            let listings = self.parseListingsFromHTML(html)
                completion(listings)
        }
        
        task.resume()
    }
    
    private func parseListingsFromHTML(_ html: String) -> [CarListing] {
            var listings: [CarListing] = []
            
            do {
                let doc: Document = try SwiftSoup.parse(html)
                
                let items = try doc.select(".talalati-lista .hirdetes, .talalati-sor")
                
                for item in items.array() {
                    // Заголовок
                    let title = try item.select(".cim, .hirdetes-cim").text()
                    
                    // Цена (убераем "Ft" и пробелы)
                    let priceText = try item.select(".ar, .hirdetes-ar").text()
                    let price = Int(priceText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
                    
                    // Год выпуска
                    let yearText = try item.select(".evjarat, .hirdetes-evjarat").text()
                    let year = Int(yearText.replacingOccurrences(of: "[^0-9]", with: "")) ?? 0
                    
                    // Пробег
                    let mileageText = try item.select(".km, .hirdetes-km").text()
                    let mileage = Int(mileageText.replacingOccurrences(of: "[^0-9]", with: ""))
                    
                    // Двигатель
                    let engineText = try item.select(".motor, .hirdetes-motor").text()
                    
                    // Локация
                    let location = try item.select(".hely, .hirdetes-hely").text()
                    
                    // Ссылка на объявление
                    let link = try item.select("a").attr("href")
                    let fullLink = link.hasPrefix("http") ? link : "https://www.hasznaltauto.hu\(link)"
                    
                    // Фото
                    let img = try item.select("img").attr("src")
                    

                    let listing = CarListing(
                        title: title,
                        price: price,
                        year: year,
                        mileage: mileage,
                        engineSize: engineText,
                        location: location,
                        url: fullLink,
                        imageUrl: img.hasPrefix("http") ? img : nil,
                        source: "Hasznaltauto"   
                    )
                    
                    listings.append(listing)
                }
            } catch {
                print("Ошибка парсинга: \(error)")
            }
            
            return listings
        }
}


