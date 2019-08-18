//
//  Responses.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

struct ErrorModel: Codable {
    var errorCode: Int
    
    private enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
    }
}
