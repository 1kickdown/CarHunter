//
//  KolesaParser.swift
//  CarHunter
//
//  Created by kickdown on 21.02.2026.
//
import Foundation
import SwiftSoup

class KolesaParser {
    func searchURL(brand: String, model: String) -> String {
        let b = brand.lowercased().trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "-")
        let m = model.lowercased().trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "-")
        return "https://kolesa.kz/cars/\(b)/\(m)/"
    }
    
    func parseListings(from urlString: String, brand: String, model: String, completion: @escaping ([CarListing]) -> Void) {
        guard let url = URL(string: urlString) else { completion([]); return }
        
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.addValue("ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7", forHTTPHeaderField: "Accept-Language")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("🇰🇿 Kolesa Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                completion([])
                return
            }

            let listings = self.parseListingsFromHTML(html, brand: brand, model: model)
            completion(listings)
        }.resume()
    }
    
    private func parseListingsFromHTML(_ html: String, brand: String, model: String) -> [CarListing] {
        var listings: [CarListing] = []
        do {
            let doc = try SwiftSoup.parse(html)
            // Используем селектор "содержит в названии класса"
            let items = try doc.select("div[class*='a-card'], .list-item")
            print("🇰🇿 Kolesa элементов найдено: \(items.count)")
            
            for item in items.array() {
                let title = try item.select("a[class*='title']").text()
                let priceText = try item.select("span[class*='price']").text()
                let price = Int(priceText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
                
                let link = try item.select("a[class*='link']").attr("href")
                
                if price > 0 {
                    listings.append(CarListing(
                        title: title, price: price, year: nil, mileage: nil,
                        engineSize: nil, location: "Kazakhstan",
                        url: "https://kolesa.kz" + link, imageUrl: nil, source: "Kolesa"
                    ))
                }
            }
        } catch { print("Error: \(error)") }
        return listings
    }
}
