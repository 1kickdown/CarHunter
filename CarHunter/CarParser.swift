//
//  CarParser.swift
//  CarHunter
//
//  Created by kickdown on 19.02.2026.
//

import Foundation
import SwiftSoup

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
                    let title = try item.select(".cim, .hirdetes-cim").text()
                    
                    let priceText = try item.select(".ar, .hirdetes-ar").text()
                    let price = Int(priceText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
                    
                    let yearText = try item.select(".evjarat, .hirdetes-evjarat").text()
                    let year = Int(yearText.replacingOccurrences(of: "[^0-9]", with: "")) ?? 0
                    
                    let mileageText = try item.select(".km, .hirdetes-km").text()
                    let mileage = Int(mileageText.replacingOccurrences(of: "[^0-9]", with: ""))
                    
                    let engineText = try item.select(".motor, .hirdetes-motor").text()
                    
                    let location = try item.select(".hely, .hirdetes-hely").text()
                    
                    let link = try item.select("a").attr("href")
                    let fullLink = link.hasPrefix("http") ? link : "https://www.hasznaltauto.hu\(link)"
                    
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
