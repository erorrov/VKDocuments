//
//  APIConstants.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import Foundation

public struct URLs {
    static let DefaultAvatar = "https://vk.com/images/camera_200.png"
    static let Base = "https://api.vk.com/method/"
}

enum HTTPMethods : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

