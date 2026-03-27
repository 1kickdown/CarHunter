//
//  HasznaltautoParser.swift
//  CarHunter
//
//  Created by kickdown on 21.02.2026.
//

import Foundation
import SwiftSoup

class HasznaltautoParser {
    func searchURL(brand: String, model: String) -> String {
        // Сайт очень чувствителен к регистру и дефисам
        let b = brand.lowercased().trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "-")
        let m = model.lowercased().trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "-")
        return "https://www.hasznaltauto.hu/szemelyauto/\(b)/\(m)"
    }
    
    func parseListings(from urlString: String, brand: String, model: String, completion: @escaping ([CarListing]) -> Void) {
        guard let url = URL(string: urlString) else { completion([]); return }
        
        let config = URLSessionConfiguration.default
        
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Заголовки, максимально приближенные к реальному iPhone Safari
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("hu-HU,hu;q=0.9,en-US;q=0.8,en;q=0.7", forHTTPHeaderField: "Accept-Language")
        request.setValue("https://www.hasznaltauto.hu/", forHTTPHeaderField: "Referer")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        request.setValue("none", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("document", forHTTPHeaderField: "Sec-Fetch-Dest")
        
        session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("🇭🇺 Hasznaltauto Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 403 {
                    print("⚠️ Все еще 403. Скорее всего, сработала защита Akamai/Cloudflare.")
                }
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8), error == nil else {
                completion([])
                return
            }
            
            // Если получили 403, но данные пришли, проверим, нет ли там сообщения о блокировке
            if html.contains("did_javascript_enabled") || html.contains("captcha") {
                print("❌ Сайт требует JavaScript или капчу. Прямой парсинг через URLSession заблокирован.")
            }
            
            let listings = self.parseListingsFromHTML(html, brand: brand, model: model)
            completion(listings)
        }.resume()
    }
    
    private func parseListingsFromHTML(_ html: String, brand: String, model: String) -> [CarListing] {
        var listings: [CarListing] = []
        do {
            let doc = try SwiftSoup.parse(html)
            
            // Пытаемся найти контейнеры объявлений по разным возможным классам
            let items = try doc.select(".talalati-sor, .hirdetes, .talalati_lista_item")
            print("🇭🇺 Hasznaltauto: Попытка парсинга \(items.count) элементов...")
            
            for item in items.array() {
                // Ищем заголовок
                let title = try item.select("h3 a, .cim, .hirdetes-cim").text()
                
                // Ищем цену (vetelar или price)
                let priceText = try item.select(".vételár, .price, .ar, [class*='price']").text()
                let price = Int(priceText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
                
                // Ищем ссылку
                let link = try item.select("h3 a, a").attr("href")
                
                if price > 0 && !title.isEmpty {
                    let fullLink = link.hasPrefix("http") ? link : "https://www.hasznaltauto.hu" + link
                    
                    // Пытаемся найти картинку
                    let imageUrl = try item.select("img").attr("src")
                    
                    listings.append(CarListing(
                        title: title,
                        price: price,
                        year: nil,
                        mileage: nil,
                        engineSize: nil,
                        location: "Hungary",
                        url: fullLink,
                        imageUrl: imageUrl.hasPrefix("http") ? imageUrl : nil,
                        source: "Hasznaltauto"
                    ))
                }
            }
            print("✅ Hasznaltauto: Успешно добавлено \(listings.count) машин")
        } catch {
            print("❌ Ошибка парсинга HTML: \(error)")
        }
        return listings
    }
}
