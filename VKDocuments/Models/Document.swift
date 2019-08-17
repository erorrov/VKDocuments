//
//  Document.swift
//  VKDocuments
//
//  Created by Егор Егоров on 14/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import Foundation

class Documents: Codable {
    
    var documentsArray: [Document]
    var count: Int
    
    init() {
        self.count = 0
        self.documentsArray = [Document]()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        
        self.documentsArray = try response.decode([Document].self, forKey: .documents)
        self.count = try response.decode(Int.self, forKey: .count)
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case documents = "items"
        case count = "count"
        case response = "response"
    }
}

struct Document: Codable {
    
    let id: Int
    var title: String
    let size: Int
    let ext: String
    let url: String
    let date: Int
    let type: Int
    let ownerID: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case size = "size"
        case ext = "ext"
        case url = "url"
        case date = "date"
        case type = "type"
        case ownerID = "owner_id"
    }
}

extension Document {
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.date))
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let monthLabels = [
            "января", "февраля", "марта",
            "апреля", "мая", "июня",
            "июля", "августа", "сентября",
            "октября", "ноября", "декабря"
        ]
        
        return String(format: "%d %@ %d", day, monthLabels[month-1], year)
    }
    
    var fileSizeString: String {
        var converted: Double = Double(self.size)
        var multiplyFactor = 0
        let tokens = ["байт", "КБ", "МБ", "ГБ"]
        
        while converted > 1024 && multiplyFactor < tokens.count {
            converted /= 1024
            multiplyFactor += 1
        }
        
        return String(format: "%d %@", Int(round(converted)), tokens[multiplyFactor])
    }
    
    var descriptionString: String {
        return String(format: "%@ - %@", self.fileSizeString, self.dateString)
    }
}

